#!/usr/bin/env bash
# -e            Exit on command fail
# -u            Treats reference to unset variables as error
# -f            Disable filename globbing
# -o pipefail   Whole pipeline fails if any command fails
set -euf -o pipefail

function check_cmd {
  command -v "$1" > /dev/null 2>&1
}

function need_cmd {
  if ! check_cmd "$1"; then
    echo "need '$1' (command not found)"
    exit 5
  fi
}

function main {
  if [[ -z "$BASH_VERSION" ]]; then
    echo "wrong shell (run this in bash)"
    exit 1
  fi

  PATH_BASH_VERSINFO=$(bash -c 'echo $BASH_VERSINFO')

  if [[ "${PATH_BASH_VERSINFO:-0}" -lt 5 ]]; then
    echo "Error! 'bash' executable in your \$PATH is obsolete: $(bash -c 'echo $BASH_VERSION')."
    echo "Please update 'bash' or fix your \$PATH."
    exit 2
  fi

  need_cmd "bash"
  need_cmd "read"
  need_cmd "ln"
  need_cmd "realpath"
  need_cmd "git"
  need_cmd "curl"

  echo "Cloning to ~/.dotfiles"
  backup "${HOME}/.dotfiles"
  cd "${HOME}"
  git clone "https://www.github.com/allvpv/dotfiles.git" ".dotfiles"

  case $OSTYPE in
    darwin*)
      NUSHELL_CONFIG_DIR="$HOME/Library/Application Support/nushell"
      ;;
    *)
      NUSHELL_CONFIG_DIR="$HOME/.config/nushell"
      ;;
  esac

  echo "Backuping and copying 'config.nu'"
  SYMLINK_SRC="${HOME}/.dotfiles/nushell/config.nu"
  SYMLINK_DST="${NUSHELL_CONFIG_DIR}/config.nu"
  backup "${SYMLINK_DST}"
  link

  echo "Backuping and copying ~/.bashrc"
  SYMLINK_SRC="${HOME}/.dotfiles/bashrc"
  SYMLINK_DST="${HOME}/.bashrc"
  backup "${SYMLINK_DST}"
  link

  echo "Backuping and copying ~/.bash_profile"
  SYMLINK_SRC="${HOME}/.dotfiles/bashrc"
  SYMLINK_DST="${HOME}/.bash_profile"
  backup "${SYMLINK_DST}"
  link

  echo "Backuping and copying ~/.config/nvim"
  mkdir -p "${HOME}/.config"
  SYMLINK_SRC="${HOME}/.dotfiles/nvim"
  SYMLINK_DST="${HOME}/.config/nvim"
  backup "${SYMLINK_DST}"
  link

  echo "Backuping and copying ~/.config/neovide"
  mkdir -p "${HOME}/.config"
  SYMLINK_SRC="${HOME}/.dotfiles/neovide"
  SYMLINK_DST="${HOME}/.config/neovide"
  backup "${SYMLINK_DST}"
  link

  echo "Enjoy!"
}

function backup {
  unlink "${1}" >/dev/null 2>&1 || true

  if [[ -e "${1}" || -h "${1}" ]]; then
    BACKUP_SUFFIX="$(date "+%Y_%m_%d__%H_%M_%S")"
    BACKUP_DST="${1}_${BACKUP_SUFFIX}"

    ask_yn "Backup ${1} to ${BACKUP_DST} (y/n)?"

    if [[ $answer == "y" ]]; then
      mv "${1}" "${BACKUP_DST}"
    else
      echo "Aborting!"
      exit 3
    fi
  fi
}

function ask_yn {
  while true; do
    read -p "${1} " answer

    if [[ "$answer" == "N" || "$answer" == "n" ]]; then
      answer="n"
      return
    elif [[ "$answer" == "Y" || "$answer" == "y" ]]; then
      answer="y"
      return
    fi
  done
}

function link {
  local SYMLINK_SRC_FULL="$(realpath "${SYMLINK_SRC}")"
  ln -s "${SYMLINK_SRC_FULL}" "${SYMLINK_DST}"
}

main "$@" || exit 4
