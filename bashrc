####
####  Prelude
####

case $- in
  *i*) ;;
    *) return;;
esac

if [[ "${BASH_VERSINFO:-0}" -lt 5 ]]; then
  echo "You are using obsolete version of bash: ${BASH_VERSION}"
  echo "This happens on MacOS (3.2.57 by default)"
  return
fi

# Prevent file overwrite on stdout redirection.
# Use `>|` to force redirection to an existing file
set -o noclobber
# Enable history expansion with space
# E.g. typing !!<space> will replace the !! with your last command
bind Space:magic-space

shopt -s checkwinsize         # Update window size after every command
shopt -s globstar             # Turn on recursive globbing (** to recurse all directories)
shopt -u nocaseglob           # Case-sensitive globbing
shopt -u nullglob             # Glob that does not match expands to zero arguments
shopt -u extglob              # Extended globbing
shopt -s autocd               # Prepend cd to directory names automatically
shopt -s interactive_comments # Recognize comments in interactive shell
shopt -s dirspell             # Correct spelling errors during tab-completion
shopt -s cdspell              # Correct spelling errors in arguments supplied to cd

# readline-specific options
bind "set completion-ignore-case off"       # Case-sensitve completions matching
bind "set show-all-if-ambiguous off"        # Don't display matches at first tab press
bind "set show-all-if-unmodified on"        # Words which have more than one completion and the
                                            # possible completions don't share a common prefix
                                            # cause the matches to be listed at first tab press
bind "set menu-complete-display-prefix on"  # Expand to prefix when '<Tab>' autocompleting
bind "set mark-symlinked-directories on"    # Add a slash when autocompleting symlinks to dirs
bind "set colored-stats on"                 # Colorize the output of tab completion


####
####  Colors
####

__term_bold=$'\e[1m'
__term_underline=$'\e[4m'
__term_reset=$'\e[0m'

function define_colors {
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

define_colors; unset -f define_colors


####
####  History
####

shopt -s histappend   # Append to the history file, don't overwrite it
shopt -s cmdhist      # Save multi-line commands as one command
shopt -s histreedit   # Re-edit the command line for failing history expansions
shopt -s histverify   # Re-edit the result of history expansions
shopt -s lithist      # Save history with newlines instead of ; where possible

# Unlimited history size.
HISTSIZE=
HISTFILESIZE=
HISTCONTROL="erasedups:ignoreboth"       # Avoid duplicate entries

# Enable incremental history search with arrows
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
bind '"\e[C": forward-char'
bind '"\e[D": backward-char'

# Enable forward history search: <C-S> to complete <C-R>
stty -ixon

# History timestamp format when using `history` command
HISTTIMEFORMAT="${__term_red}[%d.%m.%Y] ${__term_purple}[%T]${__term_reset} "


####
####  External tools
####

if [[ $OSTYPE == "darwin"* ]]; then
    # Presence of this env var is required for `path_helper`
    export MANPATH="$MANPATH"

    [[ -x /usr/libexec/path_helper ]] && eval "$(/usr/libexec/path_helper -s)"
    [[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
    [[ -x /usr/local/bin/brew ]] && eval "$(/usr/local/bin/brew shellenv)"
    [[ -s /opt/homebrew/opt/nvm/nvm.sh ]] && . /opt/homebrew/opt/nvm/nvm.sh

    # Use built-in MacOS files preview from terminal
    alias prev='qlmanage -p 2> /dev/null'
fi


[[ -f "${HOME}/.ghcup/env" ]] && source "${HOME}/.ghcup/env"
[[ -f "${HOME}/.cargo/env" ]] && source "${HOME}/.cargo/env"

export NVM_DIR="$HOME/.nvm"


####
####  Path
####

function path_remove {
  [[ "$PATH" == "$1" ]] && PATH="" # if it's the only thing
  PATH=${PATH//":$1:"/":"} # in the middle
  PATH=${PATH/#"$1:"/} # at the beginning
  PATH=${PATH/%":$1"/} # at the end
}

function prepend_path {
  if [[ -d "$1" ]]; then
    path_remove "$1"
    export PATH="$1:$PATH"
  fi
}

function append_path {
  if [[ -d "$1" ]]; then
    path_remove "$1"
    export PATH="$PATH:$1"
  fi
}

prepend_path "$HOME/.local/bin"
prepend_path "$HOME/.bun/bin"
prepend_path "/opt/homebrew/bin"
prepend_path "/opt/homebrew/opt/llvm/bin"
prepend_path "/opt/homebrew/opt/curl/bin"

unset -f prepend_path append_path path_remove


####
####  Misc
####

[[ -d /usr/local/man ]] && export MANPATH="/usr/local/man:$MANPATH"

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

export LANG=en_US.UTF-8


####
####  CLI tools
####

# This defines where cd looks for targets
CDPATH="."

case $OSTYPE in
  darwin*)
      # Use GNU realpath if available
      if command -v grealpath &> /dev/null; then
        alias realpath='grealpath'
      fi

      ;;
  *)
      if ls --version 2>/dev/null | grep -q coreutils; then # Has GNU ls
        alias ls='ls --color=auto'
      fi

      ;;
esac

export LSCOLORS="gxfxcxdxbxAhahGxGxaHAH"
export CLICOLOR=1

export LS_COLORS="\
di=36:ln=35:so=32:pi=33:ex=31:\
bd=1;30;47:\
cd=1;30;47:\
su=1;36:\
sg=1;36:\
tw=30;1;47:\
ow=1;30;1;47"

# Aliases
alias lah='ls -lah'
alias lh='ls -lh'
alias la='ls -la'
alias c="cd $HOME/Repos"
alias g="__cd_git"


####
####  Editor
####

if [[ -n $NVIM ]]; then
  alias vim='__nvim_remote'
  alias vi='__nvim_remote'

  export EDITOR='__nvim_remote_wait'
fi

export VISUAL=${EDITOR}
export SUDO_EDITOR=${EDITOR}

export PAGER='less'
export LESS='-R'


####
####  Completions
####

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

  local completions_entrypoint="/usr/share/bash-completion/bash_completion"

  # For some Linux distros, notably Debian
  if [[ -f $completions_entrypoint ]]; then
    . $completions_entrypoint
  else
    load_completion_directory "/usr/share/bash-completion/completions"
  fi

}

load_completions; unset -f load_completions


####
#### Prompt
####

if [[ ! -f "${HOME}/.this-is-work-laptop" ]]; then
  function hostname {
    echo "$HOSTNAME"
  }

  function username {
    echo "$USER"
  }
fi


# Hash the hostname and get random color based on hostname.
function __gen_machine_color {
  local colors=(
    "$__term_bold_red"
    "$__term_bold_white"
    "$__term_bold_yellow"
    "$__term_bold_magenta"
    "$__term_bold_teal"
    "$__term_bold_blue"
    "$__term_bold_green"
  )

  local hostname_new="$(hostname)"

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

# Automatically trim long paths in the prompt
PROMPT_DIRTRIM=4

function __prompt_command {
  local retcode=$?

  if [ -n "$retcode" ]; then
    if [ $retcode != 0 ]; then
      retcode="${__term_bold_red}${retcode}${__term_reset}"
    else
      retcode="${__term_bold_green}ok${__term_reset}"
    fi
  fi

  # Git prompt format:
  # '<': this repo is behind of remote
  # '<': this repo is ahead of remote
  # '=': there is no difference between remote and local
  local GIT_PS1_SHOWUPSTREAM="auto"

  local git=$(__git_ps1)

  if [[ -n "$git" ]]; then
    git="${__term_underline}{${git:2:-1}}${__term_reset} "
  fi

  # Set terminal titlebar to current directory
  local titlebar=""

  case $TERM in
    xterm*)
        titlebar="\033]7;file://$HOSTNAME/$PWD\033\\"
        ;;
  esac

  local machine_color=$(__gen_machine_color)

  PS1="
${titlebar}\
${machine_color}$(username)${__term_reset}@${machine_color}$(hostname)${__term_reset} \
[${__term_bold}\w${__term_reset}] ${git}\
exited ${retcode}
\\[${__term_bold}\\]\$\\[${__term_reset}\\] \
"
  # Immediately flush history to the history file
  history -a
}

PROMPT_COMMAND="__prompt_command"


####   ▌ ▐·▪  .▄▄ ·
####  ▪█·█▌██ ▐█ ▀.
####  ▐█▐█•▐█·▄▀▀▀█▄
####   ███ ▐█▌▐█▄▪▐█
####  . ▀  ▀▀▀ ▀▀▀▀

# Open remote Neovim on another machine via SSH and connect a GUI to it.
function vis {
  # Use SSH tunnel to secure the unencrypted remote Neovim protocol.
  # Hacky solution using sleep 2 for sync, but hey, it works!
  local curl_payload
  local python_payload
  local free_remote_port
  local free_local_port

  read -r -d '' curl_payload << EOF
echo "hello from the other side"
cd /tmp
curl -OL https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.tar.gz
tar xzf nvim-linux64.tar.gz
EOF

  ssh "$1" -- "$curl_payload"

  read -r -d '' python_payload << EOF
import socket
s = socket.socket()
s.bind(('', 0))
print(s.getsockname()[1])
s.close()
EOF

  free_remote_port=$(ssh "$1" -- python3 -c "\"${python_payload}\"")
  free_local_port=$(python3 -c "${python_payload}")

  echo "Selected local port: ${free_local_port}"
  echo "Selected remote port: ${free_remote_port}"

  (
    trap 'echo Cleanup! && kill $(jobs -p) >/dev/null 2>&1' EXIT

    ssh -L ${free_local_port}:127.0.0.1:${free_remote_port} "$1" -N &
    # Ensure Neovim is executed within a bash interactive session.
    # This allows Neovim to have all the necessary `$PATH` variables set, etc.
    ssh "$1" -- bash -i -c -- \
      \'/tmp/nvim-linux64/bin/nvim --headless --listen 127.0.0.1:${free_remote_port}\' &

    sleep 3
    neovide --title-hidden --frame none --remote-tcp=127.0.0.1:${free_local_port} --no-fork &

    for job in $(jobs -p); do
      wait $job >/dev/null 2>&1 || true
    done
  )
}


####
#### Custom utility functions
####

# Pipe to this to get URL-escaped output
function urlencode {
  jq -sRr @uri
}

function grepuuid {
  grep -n -E '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}'
}

function compressdir {
  tar -czvf "$1".tar.gz "$1"
}

# Backup file with timestamp
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

function __cd_git {
  local git_root=$(git rev-parse --show-toplevel 2>/dev/null)
  cd "$git_root"
}


###
### Banner
###

function print_banner {
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
      ${__term_bold}IPv4:${__term_reset} $(curl -s4 --max-time 0.5 ip.allvpv.org)"; printf "
      ${__term_bold}IPv6:${__term_reset} $(curl -s6 --max-time 0.5 ip.allvpv.org)"; printf "
    ${__term_bold}Uptime:${__term_reset} $(__uptime_try_pretty)
"

  unset -f __get_distro __uptime_try_pretty
}

print_banner; unset -f print_banner
