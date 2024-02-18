#
# Bail out on non-interactive session
#
case $- in
  *i*) ;;
    *) return;;
esac

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

HISTCONTROL="erasedups:ignoreboth"       # Avoid duplicate entries
HISTIGNORE="exit:ls:bg:fg:history:clear" # Don't record some commands

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
# Misc
#

# This defines where cd looks for targets
CDPATH="."

if [[ "$OSTYPE" == "darwin"* && -d "/opt/homebrew/share/man" ]]; then
  export MANPATH="/opt/homebrew/share/man:$MANPATH"
fi

if [[ -d "/usr/local/man" ]]; then
  export MANPATH="/usr/local/man:$MANPATH"
fi

export CLICOLOR=1
export LANG=en_US.UTF-8

HAS_NVR=$((command -v nvr &> /dev/null); echo $?)

if [[ -z $SSH_CONNECTION && -n $VIMRUNTIME && $HAS_NVR -eq 0 ]]; then
  function man {
    nvr -c "Man $@"
  }

  alias vim='nvr -s'
  alias vi='nvr -s'

   export EDITOR='nvr -s --remote-wait'
else
   export EDITOR='nvim'
fi

export VISUAL=${EDITOR}
export SUDO_EDITOR=${EDITOR}

export PAGER='less'
export LESS='-R'

#
# Completions
#
#

function load_completion_directory {
  shopt -s nullglob

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

  # For some Linux distros, notably Debian
  if [[ -f $COMPL ]]; then
    . $COMPL
  else
    load_completion_directory "/usr/share/bash-completion/completions"
  fi
}


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


#
# Prompt
#

# Automatically trim long paths in the prompt (requires Bash 4.x)
PROMPT_DIRTRIM=4

# Git prompt format:
# '%': there are untracked files
# '<': this repo is behind of remote
# '<': this repo is ahead of remote
# '=': there is no difference between remote and local
export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
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
      local CODE="${__term_bold_brown}${retcode}${__term_reset}"
    else
      local CODE="${__term_bold_green}ok${__term_reset}"
    fi
  fi

  local GIT=$(__git_ps1)

  if [[ -n "$GIT" ]]; then
    GIT="${__term_underline}{${GIT:2:-1}}${__term_reset} "
  fi

  PS1="
${TITLEBAR}\
${__term_bold_magenta}\u${__term_reset}@${__term_bold_blue}\h${__term_reset} \
[${__term_bold}\w${__term_reset}] ${GIT}\
exited ${CODE}
\\[${__term_bold_yellow}\\]\$\\[${__term_reset}\\] \
"
  # Immediately flush history to the history file
  history -a
}

PROMPT_COMMAND="__prompt_command"

# Aliases
alias nvmac='neovide --frame buttonless --remote-tcp=localhost:5557'
alias lah='ls -lah'

if [[ "$OSTYPE" == "darwin"* && -d "/opt/homebrew/share/man" ]]; then
  alias prev='qlmanage -p 2> /dev/null'
fi


#
# Utilities
#

# Pipe to this to get URL-escaped output
function urlify {
  jq -sRr @uri
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

# Delete: Move files to trash in RamFS
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

function hardclear {
  for i in {1..10000}; do
    printf "_"
  done

  for i in {1..10000}; do
    printf " "
  done
}

function get_distro {
  if [[ -f /etc/os-release ]]; then
    printf "$(source /etc/os-release && echo "${PRETTY_NAME}")"
  elif [[ $OSTYPE == "darwin"* ]] && command -v sw_vers &> /dev/null; then
    printf "$(sw_vers -productName) $(sw_vers -productVersion) ($(uname -s))"
  else
    uname -o
  fi
}

function uptime_try_pretty {
  if uptime -p &> /dev/null; then
    uptime -p
  else
    uptime
  fi
}

function print_banner {
  printf "${__term_purple}
            ▓▓▓▓▓▓▓   ▓▓▓        ▓▓▓    ▓▓▓     ▓▓▓ ▓▓▓▓▓▓▓▓▓  ▓▓▓     ▓▓▓
          ▓▓▓   ▓▓▓  ▓▓▓        ▓▓▓    ▓▓▓     ▓▓▓ ▓▓▓    ▓▓▓ ▓▓▓     ▓▓▓
         ▓▓▓   ▓▓▓  ▓▓▓        ▓▓▓    ▓▓▓     ▓▓▓ ▓▓▓    ▓▓▓ ▓▓▓     ▓▓▓
       ▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓        ▓▓▓    ▓▓▓     ▓▓▓ ▓▓▓▓▓▓▓▓▓  ▓▓▓     ▓▓▓
      ▓▓▓     ▓▓▓ ▓▓▓        ▓▓▓     ▓▓▓   ▓▓▓  ▓▓▓         ▓▓▓   ▓▓▓
     ▓▓▓     ▓▓▓ ▓▓▓        ▓▓▓      ▓▓▓▓▓▓▓   ▓▓▓          ▓▓▓▓▓▓▓
    ▓▓▓     ▓▓▓ ▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓    ▓▓▓            ▓▓▓▓${__term_reset}

    ${__term_bold_blue}Distro:${__term_reset} $(get_distro)"; printf "
      ${__term_bold_blue}IPv4:${__term_reset} $(curl -s4 icanhazip.com)"; printf "
      ${__term_bold_blue}IPv6:${__term_reset} $(curl -s6 icanhazip.com)"; printf "
    ${__term_bold_blue}Uptime:${__term_reset} $(uptime_try_pretty)
"
}

print_banner
load_completions
