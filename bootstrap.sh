#!/usr/bin/env bash
# -e            Exit on command fail
# -u            Treats reference to unset variables as error
# -f            Disable filename globbing
# -o pipefail   Whole pipeline fails if any command fails
set -euf -o pipefail

if ! command -v bash >/dev/null 2>&1; then
  echo "Cannot detect 'bash' executable"
  exit 1
fi

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

function backup {
  if [[ -e "${1}" || -h ${1} ]]; then
    BACKUP_SUFFIX=$(date "+%Y_%m_%d__%H_%M_%S")
    BACKUP_DST="${1}_${BACKUP_SUFFIX}"

    ask_yn "Backup ${1} to ${BACKUP_DST} (y/n)?"

    if [[ $answer == "y" ]]; then
      mv "${1}" "${BACKUP_DST}"
    else
      echo "Aborting!"
      exit 2
    fi
  fi
}

function link {
  local SYMLINK_SRC_REL=$(realpath --relative-to="${SYMLINK_REL}" "${SYMLINK_SRC}")
  ln -s "${SYMLINK_SRC_REL}" "${SYMLINK_DST}"
}

function copy {
  cp "${SRC}" "${DST}"
}

function download_completions {
  printf "Downloading some completions:"

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
  BASH_EXE=$(command -v bash)

  ask_yn "Change default shell to '${BASH_EXE}' (y/n)?"

  if [[ $answer == "y" ]]; then
    chsh -s ${BASH_EXE}
  fi
}

# Clone repo
echo "Cloning to ~/.dotfiles"
backup "${HOME}/.dotfiles"
cd ${HOME}
git clone "https://www.github.com/allvpv/dotfiles.git" ".dotfiles"

# Downlaod completions
download_completions

# Install .bashrc
echo "Backuping and copying ~/.bashrc"
SRC="${HOME}/.dotfiles/bashrc"
DST="${HOME}/.bashrc"
backup "${DST}"
copy

# Install nvim config
echo "Backuping and copying ~/.config/nvim"
mkdir -p "${HOME}/.config"
SYMLINK_REL="${HOME}/.config"
SYMLINK_SRC="${HOME}/.dotfiles/nvim"
SYMLINK_DST="${HOME}/.config/nvim"
backup "${SYMLINK_DST}"
link

# Maybe change shell
change_shell

echo "Enjoy!"

# Run shell
$(command -v bash)
