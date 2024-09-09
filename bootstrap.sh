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

  # Prerequsites
  need_cmd "bash"
  need_cmd "read"
  need_cmd "ln"
  need_cmd "realpath"
  need_cmd "git"
  need_cmd "curl"

  # Clone repo
  echo "Cloning to ~/.dotfiles"
  backup "${HOME}/.dotfiles"
  cd "${HOME}"
  git clone "https://www.github.com/allvpv/dotfiles.git" ".dotfiles"

  # Downlaod completions
  download_completions

  # Install .bashrc
  echo "Backuping and copying ~/.bashrc"
  SYMLINK_SRC="${HOME}/.dotfiles/bashrc"
  SYMLINK_DST="${HOME}/.bashrc"
  backup "${SYMLINK_DST}"
  link

  # Install nvim config
  echo "Backuping and copying ~/.config/nvim"
  mkdir -p "${HOME}/.config"
  SYMLINK_SRC="${HOME}/.dotfiles/nvim"
  SYMLINK_DST="${HOME}/.config/nvim"
  backup "${SYMLINK_DST}"
  link

  # Install neovide config
  echo "Backuping and copying ~/.config/neovide"
  mkdir -p "${HOME}/.config"
  SYMLINK_SRC="${HOME}/.dotfiles/neovide"
  SYMLINK_DST="${HOME}/.config/neovide"
  backup "${SYMLINK_DST}"
  link

  # Install __nvim_remote and __nvim_remote_wait commands
  mkdir -p ~/.local/bin
  SYMLINK_SRC="${HOME}/.dotfiles/__nvim_remote"
  SYMLINK_DST="${HOME}/.local/bin/__nvim_remote"
  backup "${SYMLINK_DST}"
  link

  SYMLINK_SRC="${HOME}/.dotfiles/__nvim_remote_wait"
  SYMLINK_DST="${HOME}/.local/bin/__nvim_remote_wait"
  backup "${SYMLINK_DST}"
  link

  # Maybe change shell
  change_shell

  echo "Enjoy!"

  # Run shell
  $(command -v bash)
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

function download_completions {
  printf "Downloading completions"

  mkdir -p "${HOME}/.bash_completions"

  printf " [1/3]"

  # `.git` basic completion
  curl -fsSL \
    "https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash" -o \
    "${HOME}/.bash_completions/git.sh"

  printf " [2/3]"

  # `.git` prompt completion (for __git_ps1)
  curl -fsSL \
    "https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh" -o \
    "${HOME}/.bash_completions/git-prompt.sh"

  printf " [3/3]"

  # `pass` password store completion
  curl -fsSL \
    "https://raw.githubusercontent.com/zx2c4/password-store/master/src/completion/pass.bash-completion" -o \
    "${HOME}/.bash_completions/pass.sh"

  echo " Done!"
  # ...more completions are loaded in .bashrc from system directories
}

function change_shell {
  BASH_EXE="$(command -v bash)"

  ask_yn "Change default shell to '${BASH_EXE}' (y/n)?"

  if [[ $answer == "y" ]]; then
    chsh -s "${BASH_EXE}"
  fi
}

main "$@" || exit 4
