#!/usr/bin/env bash
# -e            Exit on command fail
# -u            Treats reference to unset variables as error
# -f            Disable filename globbing
# -o pipefail   Whole pipeline fails if any command fails
set -euf -o pipefail

# ── Colors ──────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
RESET='\033[0m'

# ── Logging ─────────────────────────────────────────────────────────
info()    { printf "${BLUE}[info]${RESET}    %s\n" "$*"; }
success() { printf "${GREEN}[ok]${RESET}      %s\n" "$*"; }
warn()    { printf "${YELLOW}[warn]${RESET}    %s\n" "$*"; }
error()   { printf "${RED}[error]${RESET}   %s\n" "$*" >&2; }
step()    { printf "\n${BOLD}── %s ──${RESET}\n" "$*"; }

# ── Helpers ─────────────────────────────────────────────────────────
check_cmd() {
  command -v "$1" > /dev/null 2>&1
}

need_cmd() {
  if ! check_cmd "$1"; then
    error "Required command '$1' not found in PATH"
    exit 5
  fi
}

ask_yn() {
  while true; do
    read -p "$1 " answer
    case "$answer" in
      [Yy]) answer="y"; return ;;
      [Nn]) answer="n"; return ;;
    esac
  done
}

backup() {
  unlink "${1}" >/dev/null 2>&1 || true

  if [[ -e "${1}" || -h "${1}" ]]; then
    local backup_suffix
    backup_suffix="$(date "+%Y_%m_%d__%H_%M_%S")"
    local backup_dst="${1}_${backup_suffix}"

    ask_yn "  Backup ${1} to ${backup_dst}? (y/n)"

    if [[ $answer == "y" ]]; then
      mv "${1}" "${backup_dst}"
      info "Backed up to ${backup_dst}"
    else
      error "Aborting!"
      exit 3
    fi
  fi
}

symlink() {
  local src="$1"
  local dst="$2"

  info "${dst} -> ${src}"
  local src_full
  src_full="$(realpath "${src}")"
  backup "${dst}"
  ln -s "${src_full}" "${dst}"
}

# ── Main ────────────────────────────────────────────────────────────
main() {
  if [[ -z "$BASH_VERSION" ]]; then
    error "Wrong shell — run this in bash"
    exit 1
  fi

  local bash_major
  bash_major=$(bash -c 'echo $BASH_VERSINFO')

  if [[ "${bash_major:-0}" -lt 5 ]]; then
    error "'bash' in \$PATH is too old: $(bash -c 'echo $BASH_VERSION'). Need >= 5."
    exit 2
  fi

  # ── Required commands ───────────────────────────────────────────
  step "Checking required commands"
  need_cmd "bash"
  need_cmd "read"
  need_cmd "ln"
  need_cmd "realpath"
  need_cmd "git"
  need_cmd "curl"
  need_cmd "nu"
  need_cmd "nvim"
  need_cmd "neovide"
  need_cmd "fzf"
  need_cmd "tree-sitter"
  need_cmd "diffr"

  success "All required commands present"

  # ── Clone repo ──────────────────────────────────────────────────
  step "Cloning dotfiles"
  backup "${HOME}/.dotfiles"
  cd "${HOME}"
  git clone "https://www.github.com/allvpv/dotfiles.git" ".dotfiles"
  success "Cloned to ~/.dotfiles"

  local dotdir="${HOME}/.dotfiles"

  # ── Nushell config dir ──────────────────────────────────────────
  local nushell_config_dir
  case $OSTYPE in
    darwin*) nushell_config_dir="$HOME/Library/Application Support/nushell" ;;
    *)       nushell_config_dir="$HOME/.config/nushell" ;;
  esac
  mkdir -p "${nushell_config_dir}"

  # ── Symlinks ────────────────────────────────────────────────────
  step "Creating symlinks"

  symlink "${dotdir}/nushell/config.nu" "${nushell_config_dir}/config.nu"
  symlink "${dotdir}/bashrc"            "${HOME}/.bashrc"
  symlink "${dotdir}/bashrc"            "${HOME}/.bash_profile"
  symlink "${dotdir}/gitconfig"         "${HOME}/.gitconfig"

  mkdir -p "${HOME}/.config"
  symlink "${dotdir}/nvim"    "${HOME}/.config/nvim"
  symlink "${dotdir}/neovide" "${HOME}/.config/neovide"

  # ── Empty overrides file ────────────────────────────────────────
  step "Creating nushell overrides"
  local overrides="${dotdir}/nushell/overrides.nu"
  if [[ ! -f "${overrides}" ]]; then
    touch "${overrides}"
    success "Created empty ${overrides}"
  else
    info "${overrides} already exists, skipping"
  fi

  # ── macOS-specific setup ────────────────────────────────────────
  if [[ "$OSTYPE" == darwin* ]]; then
    step "macOS-specific setup"

    # Key repeat rate
    info "Setting fast key repeat rate (InitialKeyRepeat=10, KeyRepeat=1)"
    sudo defaults write -g InitialKeyRepeat -int 10
    sudo defaults write -g KeyRepeat -int 1

    # Change default shell to nushell
    if check_cmd "nu"; then
      local nu_path
      nu_path="$(command -v nu)"
      info "Changing default shell to ${nu_path}"

      if ! grep -qF "${nu_path}" /etc/shells; then
        info "Adding ${nu_path} to /etc/shells"
        echo "${nu_path}" | sudo tee -a /etc/shells > /dev/null
      fi

      sudo chsh -s "${nu_path}" "$USER"
    else
      warn "Skipping shell change — 'nu' not found in PATH"
    fi
  fi

  # ── Done ────────────────────────────────────────────────────────
  printf "\n${GREEN}${BOLD}All done! Enjoy!${RESET}\n"
}

main "$@" || exit 4
