set -x CURRENTMACHINE (head -1 ~/.config/current_machine_id)

#
#
# Editing
#

alias     vi           "nvr -s"
alias     vim          "nvr -s"

switch (uname)
  case Darwin
    alias ls "gls --group-directories-first --color=auto"
end


set -x    EDITOR       nvr -s --remote-wait
set -x    VISUAL       nvr -s  --remote-wait
set -x    SUDO_EDITOR  nvr -s  --remote-wait

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

    fish_add_path "$HOME/.cargo/bin"
    fish_add_path "/opt/homebrew/opt/ruby/bin"
    fish_add_path "/opt/homebrew/lib/ruby/gems/3.0.0/bin"
    fish_add_path "/opt/homebrew/opt/openjdk/bin"
    fish_add_path "/opt/local/bin"
    fish_add_path "/opt/homebrew/opt/llvm/bin"
    fish_add_path "/opt/homebrew/opt/make/libexec/gnubin"
    fish_add_path "/usr/local/texlive/2021/bin/universal-darwin"

    set -ax MANPATH "/opt/homebrew/share/man"
    set -ax MANPATH "/usr/local/man"

    set -gx HOMEBREW_GITHUB_API_TOKEN (cat $HOME/.local/homebrew_github)
    set -gx CLICOLOR 1

  case Linux
    fish_add_path (realpath ~)"/.local/bin/"
end

function fish_title
    echo (status current-command)' '
    pwd
end

chpwd

