use std


###
### Path
###

# Convert path-like environment variables to a native list
$env.ENV_CONVERSIONS = ['MANPATH', 'XDG_DATA_DIRS']
  | each {{
      $in: {
          from_string: {|s| $s | split row (char esep) }
          to_string: {|v| $v | str join (char esep) }
      }
    }}
  | into record

if $nu.os-info.name == 'macos' {
  # Presence of this env var is required for `path_helper`
  if not ('MANPATH' in $env) {
    $env.MANPATH = []
  }

  load-env (
    ^/usr/libexec/path_helper -s
      | str trim
      | lines
      | parse '{name}="{value}"; export {export};'
      | select name value
      | update value { $in | split row (char esep) }
      | transpose --header-row --as-record
  )
}

std path add [
  '~/.local/bin',
  '~/.dotfiles/bin',
  '~/.bun/bin',
  '~/.cargo/bin',
  '/opt/homebrew/bin',
  '/opt/homebrew/opt/llvm/bin',
  '/opt/homebrew/opt/curl/bin',
]

# Shell-agnostic node.js version manager
if (which fnm | is-not-empty) {
  fnm env --json | from json | load-env
  std path add $"($env.FNM_MULTISHELL_PATH)/bin"
}

# Additional MANPATH
$env.MANPATH ++= ['/usr/local/man']

# Deduplicate the path variable and remove invalid entries
def --env sanitize_path [
  path = 'PATH' # The name of the path variable
] {
   let sanitized = $env
      | get $path
      | uniq
      | where ($it | path expand | path type) == 'dir' and ($it | str length) > 0

    load-env {
      $path: $sanitized
    }
}

sanitize_path 'PATH'
sanitize_path 'MANPATH'


###
### Misc
###

let is_work_laptop = '~/.this-is-work-laptop' | path exists

if $is_work_laptop {
  load-env {
    TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE: '/var/run/docker.sock',
    DOCKER_HOST: $'unix://($nu.home-path)/.colima/default/docker.sock',
    TESTCONTAINERS_RYUK_DISABLED: 'true',
    JAVA_8_HOME: (^/usr/libexec/java_home -v1.8),
    JAVA_11_HOME: (^/usr/libexec/java_home -v11),
    JAVA_17_HOME: (^/usr/libexec/java_home -v17),
    JAVA_21_HOME: (^/usr/libexec/java_home -v21)
  }
}

let username = if $is_work_laptop { 'allvpv' } else { $env.USER }
let hostname = if $is_work_laptop { 'm3-pro' } else { (sys host).hostname }

$env.LANG = 'en_US.UTF-8'

$env.LS_COLORS = [
 'di=36:ln=35:so=32:pi=33:ex=31:',
 'bd=1;30;47:',
 'cd=1;30;47:',
 'su=1;36:',
 'sg=1;36:',
 'tw=30;1;47:',
 'ow=1;30;1;47'
] | str join

# Will set JAVA_HOME to the value of JAVA_<version>_HOME
def --env switch_java [
  version # A number: The version of Java to switch to
] {
  let new_java_home_name = $'JAVA_($version)_HOME'

  if $new_java_home_name in $env {
    let new_java_home = ($env | get $new_java_home_name)
    print $"Setting JAVA_HOME to ($new_java_home_name) \(($new_java_home)\)"
    $env.JAVA_HOME = $new_java_home
  } else {
    error make {
      msg: $'No ($new_java_home_name) detected in environment',
      label: {
        text: $"Java version '($version)' taken from here",
        span: (metadata $version).span
      }
    }
  }
}


###
### Editor
###

alias vim-bin = vim

def vim [...args: glob] {
  if 'NVIM' in $env {
    __nvim_remote ...$args
  } else {
    vim-bin ...$args
  }
}

if 'NVIM' in $env {
  $env.EDITOR = '__nvim_remote_wait'
  $env.config.buffer_editor = '__nvim_remote_wait'
}

if not ('EDITOR' in $env) {
  $env.EDITOR = 'vim'
}

$env.VISUAL = $env.EDITOR
$env.SUDO_EDITOR = $env.EDITOR
$env.PAGER = 'less'
$env.LESS = '-R'


###
### Completions & external
###

if (which carapace | is-not-empty) {
  $env.config.completions.external = {
      enable: true
      max_results: 100
      completer: {|spans| carapace $spans.0 nushell ...$spans | from json }
  }
}

$env.VIRTUAL_ENV_DISABLE_PROMPT = 'true'


###
### Utilities
###

alias del = rm --trash
alias cat = open -r

alias c = cd ~/Repos

alias ga = git add
alias gbr = git branch
alias gch = git checkout
alias gcl = git clone
alias gco = git commit
alias gca = git commit --amend -C HEAD
alias gcae = git commit --amend
alias gd = git diff
alias gds = git diff --staged
alias gf = git fetch
alias gg = git grep
alias gl = git log-pretty
alias glt = git log-pretty-time
alias gpull = git pull
alias gpush = git push
alias gpushf = git push --force
alias grebranch = git rebranch
alias greset = git reset
alias grestore = git restore
alias grm = git rm
alias gsh = git show-pretty
alias gstat = git status -s
alias gsw = git switch
alias gstash = git stash

alias "git show" = echo 'Use "gsh" instead of "git show" (or ^git)'
alias "git log" = echo 'Use "gl" instead of "git log" (or ^git)'
alias "git status" = echo 'Use "gstat" instead of "git status" (or ^git)'
alias "git add" = echo 'Use "ga" instead of "git add" (or ^git)'
alias "git commit" = echo 'Use "gco" instead of "git commit" (or ^git)'
alias "git push" = echo 'Use "gpush" instead of "git push" (or ^git)'
alias "git pull" = echo 'Use "gpull" instead of "git pull" (or ^git)'


# Change dierctory to the git root
def --env g [] {
  let git_root = ^git rev-parse --show-toplevel | complete

  if $git_root.exit_code != 0 {
    error make {
      msg: $'Cannot find the git root of the current directory',
      label: {
        text: $git_root.stderr,
        span: (metadata $git_root).span
      }
    }
  } else {
    cd $git_root.stdout
  }
}

def prev [...args: glob] {
  if $nu.os-info.name == 'macos' {
    ^qlmanage -p ...$args err> /dev/null
  } else {
    print 'xdg-open or something?'
  }
}

def orient-split-to-table [] {
  let split = $in

  $split.data | each { |row| $split.columns | std iter zip-into-record $row } | flatten
}


###
### Prompt
###

def get_prompt_pwd [pwd max_segments_cnt] {
  let is_in_home = $pwd | str starts-with $nu.home-path
  let pwd = (
    if $is_in_home {
      $pwd | str replace $nu.home-path '~'
    } else {
      $pwd
    }
  )

  let segments = $pwd | path split
  let segments_cut = $segments | last $max_segments_cnt

  let segments_final = (
    if ($segments_cut | length) + 1 < ($segments | length) {
      if $is_in_home {
          ['~', '...', ...$segments_cut]
      } else {
          ['...', ...$segments_cut]
      }
    } else {
      $segments
    }
  )

  $segments_final | path join
}

def get_git_branch [] {
  try {
    let git_dir = find_git_dir
    let head_pointer = open -r $'($git_dir)/HEAD'
    let branch = $head_pointer | parse 'ref: refs/heads/{branch}' | get branch

    if ($branch | is-not-empty) {
      $branch | first | str trim
    } else {
      $head_pointer | str trim | str substring 0..10
    }
  } catch {
    ''
  }
}

def get_venv_indicator [] {
  if 'VIRTUAL_ENV' in $env {
    # I usually keep the virtual environment in the repository root
    if (pwd | str starts-with ($env.VIRTUAL_ENV | path dirname)) {
      $'(ansi g)in 🐍 (ansi reset)'
    } else {
      $'(ansi r)out 🐍 (ansi reset)'
    }
  } else {
    ''
  }
}

def find_git_dir [max_depth = 50] {
  mut pwd = pwd

  for _ in 1..$max_depth {
    let gitdir = $'($pwd)/.git'

    if ($gitdir | path exists) {
      return $gitdir
    } else if $pwd != '/' {
      $pwd = $pwd | path dirname
    } else {
      break
    }
  }

  return ''
}

def create_left_prompt [] {
  let short_pwd = get_prompt_pwd (pwd) 4
  let titlebar = if $env.TERM =~ 'xterm' {
    $'(ansi title)($short_pwd)(ansi st)'
  }
  let exited = match $env.LAST_EXIT_CODE {
    0 => $'(ansi gb)ok(ansi reset)',
    $e => $'(ansi rb)($e)(ansi reset)'
  }
  let venv = get_venv_indicator
  let branch_name = get_git_branch
  let git_prompt = if $branch_name != '' {
    $'(ansi wu){($branch_name)}(ansi reset) '
  } else {
    ''
  }

  [
    $titlebar,
    $"\n(ansi cb)($username)(ansi reset)",
    $'@(ansi cb)($hostname)(ansi reset) ',
    $'[(ansi wb)($short_pwd)(ansi reset)] ',
    $venv,
    $git_prompt,
    $"exited ($exited)\n"
  ] | str join
}

$env.PROMPT_COMMAND = { || create_left_prompt }
$env.PROMPT_COMMAND_RIGHT = ''

$env.PROMPT_INDICATOR = match $env.USER {
  'root' => $'(ansi wb)#(ansi reset) ',
  _ => $'(ansi wb)$(ansi reset) '
}

$env.config.color_config.shape_external = 'w'
$env.config.color_config.shape_internalcall = 'wb'
