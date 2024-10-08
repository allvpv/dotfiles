#
# Bail out on non-interactive session
#

case $- in
  *i*) ;;
    *) return;;
esac

if [[ "${BASH_VERSINFO:-0}" -lt 5 ]]; then
  echo "You are using obsolete version of bash: ${BASH_VERSION}"
  echo "This happens on MacOS (3.2.57 by default)"
  return
fi

#
# Shell options
#

# Prevent file overwrite on stdout redirection.
# Use `>|` to force redirection to an existing file
set -o noclobber
# Update window size after every command
shopt -s checkwinsize
# Enable history expansion with space
# E.g. typing !!<space> will replace the !! with your last command
bind Space:magic-space
# Turn on recursive globbing (enables ** to recurse all directories)
shopt -s globstar 2> /dev/null
# Case-sensitive globbing
shopt -u nocaseglob
# Better globbing
shopt -u nullglob extglob

# `readline`-specific options
bind "set completion-ignore-case off"       # Case-sensiitve matching
bind "set show-all-if-ambiguous off"        # Don't display matches at first tab press
bind "set show-all-if-unmodified on"        # Words which have more than one completion and the
                                            # possible completions don't share a common prefix
                                            # cause the matches to be listed at first tab press
bind "set menu-complete-display-prefix on"  # Expand to prefix when '<Tab>' autocompleting
bind "set mark-symlinked-directories on"    # Add a slash when autocompleting symlinks to dirs

#
# History
#

## Command history configuration
if [ -z "$HISTFILE" ]; then
  HISTFILE=$HOME/.bash_history
fi

shopt -s histappend   # Append to the history file, don't overwrite it
shopt -s cmdhist      # Save multi-line commands as one command
shopt -s histreedit   # Re-edit the command line for failing history expansions
shopt -s histverify   # Re-edit the result of history expansions
shopt -s lithist      # Save history with newlines instead of ; where possible
shopt -s autocd       # Prepend cd to directory names automatically
shopt -s dirspell     # Correct spelling errors during tab-completion
shopt -s cdspell      # Correct spelling errors in arguments supplied to cd
shopt -s cdable_vars  # Define a variable containing a path and you will be able to
                      # cd into it regardless of the directory you're in
shopt -s interactive_comments # Recognize comments in interactive shell

# Unlimited history size.
export HISTSIZE=
export HISTFILESIZE=

export HISTCONTROL="erasedups:ignoreboth"       # Avoid duplicate entries
export HISTIGNORE="exit:ls:bg:fg:history:clear" # Don't record some commands

# Enable incremental history search with arrows
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
bind '"\e[C": forward-char'
bind '"\e[D": backward-char'

# Enable forward history search: <C-S> to complete <C-R>
stty -ixon

# History format
# ISO 8601 timestamp:
#  %F equivalent to %Y-%m-%d
#  %T equivalent to %H:%M:%S (24-hours format)
HISTTIMEFORMAT=$'\033[31m[%d.%m.%Y] \033[36m[%T]\033[0m '

#
# Set $PATH and other environment variables
#

# MacOS: It is possible that `MANPATH` is not set at this point. But we need
# this variable exported *before* `/usr/libexec/path_helper` is executed
export MANPATH="$MANPATH"

[[ -x /usr/libexec/path_helper ]] && eval "$(/usr/libexec/path_helper -s)"
[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
[[ -x /usr/local/bin/brew ]] && eval "$(/usr/local/bin/brew shellenv)"
[[ -d "/usr/local/man" ]] && export MANPATH="/usr/local/man:$MANPATH"
[[ -f "${HOME}/.ghcup/env" ]] && source "${HOME}/.ghcup/env"
[[ -f "${HOME}/.cargo/env" ]] && source "${HOME}/.cargo/env"

function check_path {
  case ":${PATH}:" in
      *:"${1}":*)
          return 1;;
      *)
          return 0;;
  esac
}

function prepend_path {
  if [[ -d "$1" ]] && check_path "$1"; then
    export PATH="$1:$PATH"
  fi
}

function append_path {
  if [[ -d "$1" ]] && check_path "$1"; then
    export PATH="$PATH:$1"
  fi
}

prepend_path "$HOME/.local/bin"
append_path "/usr/sbin"
append_path "/sbin"
prepend_path "$HOME/Library/Python/3.9/bin"
prepend_path "$HOME/.bun/bin"

unset -f prepend_path append_path

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

#
# Misc
#
if [[ -f "${HOME}/.this-is-work-laptop" ]]; then
  export TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE=/var/run/docker.sock
  export DOCKER_HOST=unix://$HOME/.colima/default/docker.sock
  export TESTCONTAINERS_RYUK_DISABLED=true

  export JAVA_8_HOME=$(/usr/libexec/java_home -v1.8)
  export JAVA_11_HOME=$(/usr/libexec/java_home -v11)
  export JAVA_17_HOME=$(/usr/libexec/java_home -v17)
  export JAVA_21_HOME=$(/usr/libexec/java_home -v21)

  function switch_java {
    local NEW_JAVA_HOME=JAVA_${1}_HOME
    export JAVA_HOME=${!NEW_JAVA_HOME}
  }

  switch_java 21

  source "${HOME}/.work-services.sh"
fi

# This defines where cd looks for targets
CDPATH="."

export LANG=en_US.UTF-8

if command -v grealpath &> /dev/null; then
  alias realpath='grealpath'
fi

function set_editor {
  if [[ -n $NVIM ]]; then
    function man {
      nvim --server $NVIM --remote-send "Man $@"
    }

    alias vim='__nvim_remote'
    alias vi='__nvim_remote'

    export EDITOR='__nvim_remote_wait'
  fi

  export VISUAL=${EDITOR}
  export SUDO_EDITOR=${EDITOR}
}

set_editor; unset -f set_editor

export PAGER='less'
export LESS='-R'

#
# Completions
#

function load_completion_directory {
  if [[ -d "$1" && -n "$(ls -A "$1")" ]]; then
    for completion in "$1"/*; do
      . ${completion}
    done
  fi
}

function load_completions {
  load_completion_directory ~/.bash_completions
  load_completion_directory /opt/homebrew/etc/bash_completion.d/

  local COMPL="/usr/share/bash-completion/bash_completion"

  function have() {
    type $1 &>/dev/null
  }

  # For some Linux distros, notably Debian
  if [[ -f $COMPL ]]; then
    . $COMPL
  else
    load_completion_directory "/usr/share/bash-completion/completions"
  fi

}

load_completions; unset -f load_completions


#
# Colors
#

function gencolors {
  __term_bold=$'\e[1m'
  __term_underline=$'\e[4m'
  __term_reset=$'\e[0m'

  local -a normal_colors=(black brown green olive navy purple teal silver)
  local -a bright_colors=(gray red lime yellow blue magenta cyan white)

  local index
  for ((index = 0; index < 8; index++)); do
    printf -v "__term_${normal_colors[index]}" %s '\e[0;3'"$index"'m'
    printf -v "__term_bold_${normal_colors[index]}" %s '\e[3'"$index"';1m'
    printf -v "__term_underline_${normal_colors[index]}" %s '\[\e[3'"$index"';4m'
    printf -v "__term_${bright_colors[index]}" %s '\e[0;'"9$index"'m'
    printf -v "__term_bold_${bright_colors[index]}" %s '\e['"9$index"';1m'
    printf -v "__term_underline_${bright_colors[index]}" %s '\e['"9$index"';4m'
  done
}

gencolors; unset -f gencolors

# Colored hostname. Hash the hostname and get "random" color based on hostname.
# Distinguishing machines made easier!

colors=(
  "$__term_bold_red"
  "$__term_bold_white"
  "$__term_bold_yellow"
  "$__term_bold_magenta"
  "$__term_bold_teal"
  "$__term_bold_blue"
  "$__term_bold_green"
)

function __gen_machine_color {
  local hostname_new='\h'
  local hostname_new="${hostname_new@P}"

  if [[ "$__hostname" != "$hostname_new" ]]; then
    __hostname="$hostname_new"
    __hostname_color_nr=$(awk '{
      for(i = 0; i < 256; i++)
          CHR_TO_NUM[sprintf("%c", i)] = i;

      p = 257;
      m = 1000000000 + 9;

      hash = 0;
      p_pow = 1;

      len = split($0, buf, "");

      for (i = 1; i <= len; ++i) {
          hash = (hash + (CHR_TO_NUM[buf[i]] + 1) * p_pow) % m;
          p_pow = (p_pow * p) % m;
      }

      printf("%d", hash % 7);
    }' <<< ${__hostname});
  fi

  printf ${colors[__hostname_color_nr]}
}

# Linux-specific
export LS_COLORS="\
di=36:ln=35:so=32:pi=33:ex=31:\
bd=1;30;47:\
cd=1;30;47:\
su=1;36:\
sg=1;36:\
tw=30;1;47:\
ow=1;30;1;47"

# BSD-specific
export LSCOLORS="gxfxcxdxbxAhahGxGxaHAH"

# Enable colored output on MacOS
export CLICOLOR=1

# Enable colored `ls` on Linux
if ls --version 2>/dev/null | grep -q coreutils; then # Has GNU ls
  alias ls='ls --color=auto'
fi

#
# Prompt
#

# Automatically trim long paths in the prompt (requires Bash 4.x)
PROMPT_DIRTRIM=4

# Git prompt format:
# [DISABLED] '%': there are untracked files
# '<': this repo is behind of remote
# '<': this repo is ahead of remote
# '=': there is no difference between remote and local
# export GIT_PS1_SHOWDIRTYSTATE=1
# export GIT_PS1_SHOWUNTRACKEDFILES=1
export GIT_PS1_SHOWUPSTREAM="auto"

# Set terminal titlebar to current directory
case $TERM in
  xterm*)
      TITLEBAR="\033]0;\w\007"
      ;;
  *)
      TITLEBAR=""
      ;;
esac

function __prompt_command {
  local retcode=$?

  if [ -n "$retcode" ]; then
    if [ $retcode != 0 ]; then
      local CODE="${__term_bold_red}${retcode}${__term_reset}"
    else
      local CODE="${__term_bold_green}ok${__term_reset}"
    fi
  fi

  local GIT=$(__git_ps1)

  if [[ -n "$GIT" ]]; then
    GIT="${__term_underline}{${GIT:2:-1}}${__term_reset} "
  fi

  local machine_color=$(__gen_machine_color)

  PS1="
${TITLEBAR}\
${machine_color}\u${__term_reset}@${machine_color}\h${__term_reset} \
[${__term_bold}\w${__term_reset}] ${GIT}\
exited ${CODE}
\\[${__term_bold}\\]\$\\[${__term_reset}\\] \
"
  # Immediately flush history to the history file
  history -a
}

PROMPT_COMMAND="__prompt_command"

#
# Open remote Neovim on another machine (using SSH) and attach GUI to it
# through SSH tunnel. (Tunnel bypases firewalls and helps with the fact that
# remote Neovim protocol is unencrypted).
#
# This thing is hacky and uses `sleep 2` for synchronization LOL. But it works!
#
function vis {
  local CURL_PAYLOAD
  local PYTHON_PAYLOAD
  local FREE_REMOTE_PORT
  local FREE_LOCAL_PORT

  read -r -d '' CURL_PAYLOAD << EOF
echo "hello from the other side"
cd /tmp
curl -OL https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.tar.gz
tar xzf nvim-linux64.tar.gz
EOF

  ssh "$1" -- "$CURL_PAYLOAD"

  read -r -d '' PYTHON_PAYLOAD << EOF
import socket
s = socket.socket()
s.bind(('', 0))
print(s.getsockname()[1])
s.close()
EOF

  FREE_REMOTE_PORT=$(ssh "$1" -- python3 -c "\"${PYTHON_PAYLOAD}\"")
  FREE_LOCAL_PORT=$(python3 -c "${PYTHON_PAYLOAD}")

  echo "Selected local port: ${FREE_LOCAL_PORT}"
  echo "Selected remote port: ${FREE_REMOTE_PORT}"

  (
    trap 'echo Cleanup! && kill $(jobs -p) >/dev/null 2>&1' EXIT

    ssh -L ${FREE_LOCAL_PORT}:127.0.0.1:${FREE_REMOTE_PORT} "$1" -N &
    # Remember to execute Neovim inside bash interactive session.
    # (Neovim deserves to have all the `$PATH`s already set, etc.).
    ssh "$1" -- bash -i -c -- \
      \'/tmp/nvim-linux64/bin/nvim --headless --listen 127.0.0.1:${FREE_REMOTE_PORT}\' &

    sleep 3
    neovide --title-hidden --frame none --remote-tcp=127.0.0.1:${FREE_LOCAL_PORT} --no-fork &

    for job in $(jobs -p); do
      wait $job >/dev/null 2>&1 || true
    done
  )
}


# Aliases

alias nvmac='neovide --title-hidden --frame none --remote-tcp=localhost:5557'

alias lah='ls -lah'
alias lh='ls -lh'
alias la='ls -la'

if [[ "$OSTYPE" == "darwin"* ]]; then
  alias prev='qlmanage -p 2> /dev/null'
fi

if command -v dnf5 &> /dev/null; then
  alias dnf='dnf5'
fi


#
# Utilities
#

# Pipe to this to get URL-escaped output
function urlify {
  jq -sRr @uri
}

function grepuuid {
  grep -n -E '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}'
}

# Extract:  Extract most know archives with one command
function extract {
  if [ -f "$1" ] ; then
    case "$1" in
    *.tar.bz2)   tar xjf "$1"     ;;
    *.tar.gz)    tar xzf "$1"     ;;
    *.bz2)       bunzip2 "$1"     ;;
    *.rar)       unrar e "$1"     ;;
    *.gz)        gunzip "$1"      ;;
    *.tar)       tar xf "$1"      ;;
    *.tbz2)      tar xjf "$1"     ;;
    *.tgz)       tar xzf "$1"     ;;
    *.zip)       unzip "$1"       ;;
    *.Z)         uncompress "$1"  ;;
    *.7z)        7z x "$1"        ;;
    *)     echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

function compressdir {
  tar -czvf "$1".tar.gz "$1"
}

# Backup: Backup file with timestamp
function backup {
  local filename filetime
  filename=$1
  filetime=$(date +%Y%m%d_%H%M%S)
  cp -a "${filename}" "${filename}_${filetime}"
}

# Delete: Move files to trash inside /tmp
function del {
  local trashtime=$(date +%Y%m%d_%H%M%S)
  mkdir -p /tmp/.trash/${trashtime} && mv "$@" /tmp/.trash/${trashtime}/
}

function rm {
  printf "${__term_bold_red}Use 'del' or '$(which rm)'${term_reset}"
}

# FindPid: Find out the pid of a specified process
function findpid {
  lsof -tc "$@"
}

# Swap two filenames
# TODO: use some tool that does single platform-dependent syscall for that
function swap {
  local random=$RANDOM

  if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: swap file1 file2" 1>&2
    return
  fi

  mv "$1" "$1.$random"
  mv "$2" "$1"
  mv "$1.$random" "$2"
}

function hardclear {
  for i in {1..10000}; do
    printf "_"
  done

  for i in {1..10000}; do
    printf " "
  done
}

function __get_distro {
  if [[ -f /etc/os-release ]]; then
    printf "$(source /etc/os-release && echo "${PRETTY_NAME}")"
  elif [[ $OSTYPE == "darwin"* ]] && command -v sw_vers &> /dev/null; then
    printf "$(sw_vers -productName) $(sw_vers -productVersion) ($(uname -s))"
  else
    uname -o
  fi
}

function __uptime_try_pretty {
  if uptime -p &> /dev/null; then
    uptime -p
  else
    uptime
  fi
}

function print_banner {
  local machine_color=$(__gen_machine_color)

  printf "${machine_color}
            ▓▓▓▓▓▓▓   ▓▓▓        ▓▓▓    ▓▓▓     ▓▓▓ ▓▓▓▓▓▓▓▓▓  ▓▓▓     ▓▓▓
          ▓▓▓   ▓▓▓  ▓▓▓        ▓▓▓    ▓▓▓     ▓▓▓ ▓▓▓    ▓▓▓ ▓▓▓     ▓▓▓
         ▓▓▓   ▓▓▓  ▓▓▓        ▓▓▓    ▓▓▓     ▓▓▓ ▓▓▓    ▓▓▓ ▓▓▓     ▓▓▓
       ▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓        ▓▓▓    ▓▓▓     ▓▓▓ ▓▓▓▓▓▓▓▓▓  ▓▓▓     ▓▓▓
      ▓▓▓     ▓▓▓ ▓▓▓        ▓▓▓     ▓▓▓   ▓▓▓  ▓▓▓         ▓▓▓   ▓▓▓
     ▓▓▓     ▓▓▓ ▓▓▓        ▓▓▓      ▓▓▓▓▓▓▓   ▓▓▓          ▓▓▓▓▓▓▓
    ▓▓▓     ▓▓▓ ▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓    ▓▓▓            ▓▓▓▓${__term_reset}

    ${__term_bold}Distro:${__term_reset} $(__get_distro)"; printf "
      ${__term_bold}IPv4:${__term_reset} $(curl -s4 --max-time 1 ip.allvpv.org)"; printf "
      ${__term_bold}IPv6:${__term_reset} $(curl -s6 --max-time 1 ip.allvpv.org)"; printf "
    ${__term_bold}Uptime:${__term_reset} $(__uptime_try_pretty)
"
}

print_banner; unset -f print_banner
