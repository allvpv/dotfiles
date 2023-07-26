set -x CURRENTMACHINE (head -1 ~/.config/current_machine_id)
#
#
# Editing
#

alias     vi            "nvr -s"
alias     vim           "nvr -s"
alias     urlencodeplus "python3 -c \"import urllib.parse, sys; print(urllib.parse.quote_plus(sys.stdin.read()))\""
alias     urlencode     "python3 -c \"import urllib.parse, sys; print(urllib.parse.quote(sys.stdin.read()))\""

switch (uname)
  case Darwin
    alias ls    "gls --group-directories-first --color=auto -p"
    alias grep  "grep --color=always"
    alias egrep "epgrep --color=always"
end


set -x    EDITOR             nvr -s --remote-wait
set -x    VISUAL             nvr -s  --remote-wait
set -x    SUDO_EDITOR        nvr -s  --remote-wait
# set -x    USE_BAZEL_VERSION  "6.0.0"

#
# Compilation
#

set -x    CXXFLAGS    "-O2 -Wall -Wextra"
set -x    CFLAGS      "-O2 -Wall -Wextra"
set -x    MAKEFLAGS    -j8

switch (uname)
  case Darwin
    set -x CC clang
    set -x CXX clang++
  case Linux
    set -x CC gcc
    set -x CXX g++
end

function makd
    set -lx CXXFLAGS "-g -Wall -Wextra -D_GLIBCXX_DEBUG --std=c++17"
    make $argv 2>&1
end

function makd20
    set -lx CXXFLAGS "-g -Wall -Wextra -D_GLIBCXX_DEBUG --std=c++20"
    make $argv 2>&1
end

#
# Misc
#
#

function man
    nvr -c "Man $argv"
end

function sudo
    if test "$argv" = !!
        eval command sudo $history[1]
    else
        command sudo $argv
    end
end

switch (uname)
  case Darwin
    alias prev "qlmanage -p 2> /dev/null"
end

alias pw "pkill -KILL wine"

#
# Prompt
#

set     fish_prompt_pwd_dir_length      0
set     fish_color_param                blue
set     fish_pager_color_description    green
set     fish_pager_color_progress       brwhite

#
# Custom paths
#

switch (uname)
  case Darwin
    eval (/opt/homebrew/bin/brew shellenv)

    set -ax MANPATH "/opt/homebrew/share/man"
    set -ax MANPATH "/usr/local/man"

    set -gx PNPM_HOME "/Users/przemek/Library/pnpm"
    set -gx HOMEBREW_GITHUB_API_TOKEN (cat $HOME/.local/homebrew_github)
    set -gx CLICOLOR 1
    set -gx VMCTLDIR "$HOME/VMs"

    fish_add_path "$HOME/.bin"
    fish_add_path "$HOME/.cargo/bin"
    fish_add_path "$HOME/.apps/google-cloud-sdk/bin"
    fish_add_path "/opt/homebrew/opt/ruby/bin"
    fish_add_path "/opt/homebrew/lib/ruby/gems/3.0.0/bin"
    fish_add_path "/opt/homebrew/opt/openjdk/bin"
    fish_add_path "/opt/local/bin"
    fish_add_path "/opt/homebrew/opt/llvm/bin"
    fish_add_path "/opt/homebrew/opt/make/libexec/gnubin"
    fish_add_path "$HOME/.spicetify"
    fish_add_path "$HOME/.cabal/bin"
    fish_add_path "$HOME/.ghcup/bin"
    fish_add_path "$PNPM_HOME"

    set tex_distros /usr/local/texlive/202?

    if test -n "$tex_distros"
        fish_add_path $tex_distros[-1]/bin/universal-darwin
    end

  case Linux
    fish_add_path (realpath ~)"/.local/bin/"
end

function fish_title
    echo (status current-command)' '
    pwd
end

chpwd

set -gx PNPM_HOME "/Users/przemek/Library/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
