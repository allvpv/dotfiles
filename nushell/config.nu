use std


###
### OS-specific
###

if $nu.os-info.name == 'macos' {
  # Presence of this env var is required for `path_helper`
  $env.MANPATH = []

  load-env (
    ^/usr/libexec/path_helper -s
      | str trim
      | lines
      | parse '{name}="{value}"; export {export};'
      | select name value
      | transpose --header-row --as-record
  )
}


###
### Path
###

std path add [
  '~/.local/bin',
  '~/.bun/bin',
  '~/.cargo/bin',
  '/opt/homebrew/bin',
  '/opt/homebrew/opt/llvm/bin',
  '/opt/homebrew/opt/curl/bin'
]

# Additional MANPATH
$env.MANPATH ++= ['/usr/local/man']

# Deduplicate the path variable and remove invalid entries
def --env sanitize_path [
  path = 'PATH' # The name of the path variable
] {
   let sanitized = $env
      | get $path
      | uniq
      | where ($it | path type) == 'dir'

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
    TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE: "/var/run/docker.sock",
    DOCKER_HOST: $"unix://($nu.home-path)/.colima/default/docker.sock",
    TESTCONTAINERS_RYUK_DISABLED: "true",
    JAVA_8_HOME: (^/usr/libexec/java_home -v1.8),
    JAVA_11_HOME: (^/usr/libexec/java_home -v11),
    JAVA_17_HOME: (^/usr/libexec/java_home -v17),
    JAVA_21_HOME: (^/usr/libexec/java_home -v21)
  }
}

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

def vim [...args] {
  if 'NVIM' in $env {
    __nvim_remote ...($args | each { path expand })
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

$env.config.completions.external = {
    enable: true
    max_results: 100
    completer: {|spans| carapace $spans.0 nushell ...$spans | from json }
}

$env.VIRTUAL_ENV_DISABLE_PROMPT = 'true'


###
### Utilities
###

alias del = rm --trash

alias c = cd ~/Repos

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


source prompt.nu
