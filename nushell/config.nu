use std

###
### OS-specific
###
if $nu.os-info.name == "macos" {
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
  "~/.local/bin",
  "~/.bun/bin",
  "~/.cargo/bin",
  "/opt/homebrew/bin",
  "/opt/homebrew/opt/llvm/bin",
  "/opt/homebrew/opt/curl/bin"
]

# Additional MANPATH
if ("/usr/local/man" | path exists)  {
  $env.MANPATH ++= ["/usr/local/man"]
}

# Deduplicate the path variable and remove invalid entries
def --env sanitize_path [
  path = "PATH" # The name of the path variable
] {
   let sanitized = $env
      | get $path
      | uniq
      | where ($it | path type) == "dir"

    load-env {
      $path: $sanitized
    }
}

sanitize_path "PATH"
sanitize_path "MANPATH"

###
### Misc
###

$env.LANG = "en_US.UTF-8"

if ("~/.this-is-work-laptop" | path exists) {
  $env.TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE = "/var/run/docker.sock"
  $env.DOCKER_HOST = "unix://$HOME/.colima/default/docker.sock"
  $env.TESTCONTAINERS_RYUK_DISABLED = "true"

  $env.JAVA_8_HOME = ^/usr/libexec/java_home -v1.8
  $env.JAVA_11_HOME = ^/usr/libexec/java_home -v11
  $env.JAVA_17_HOME = ^/usr/libexec/java_home -v17
  $env.JAVA_21_HOME = ^/usr/libexec/java_home -v21
}

# Will set JAVA_HOME to the value of JAVA_<version>_HOME
def --env switch_java [
  version # A number: The version of Java to switch to
] {
  let new_java_home_name = $"JAVA_($version)_HOME"

  if $new_java_home_name in $env {
    let new_java_home = ($env | get $new_java_home_name)
    print $"Setting JAVA_HOME to ($new_java_home_name) \(($new_java_home)\)"
    $env.JAVA_HOME = $new_java_home
  } else {
    error make {
      msg: $"No ($new_java_home_name) detected in environment",
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
  if "NVIM" in $env {
    __nvim_remote ...$args
  } else {
    vim-bin ...$args
  }
}

alias c = cd ~/Repos

# Change dierctory to the git root
def --env g [] {
  let git_root = ^git rev-parse --show-toplevel | complete

  if $git_root.exit_code != 0 {
    error make {
      msg: $"Cannot find the git root of the current directory",
      label: {
        text: $git_root.stderr,
        span: (metadata $git_root).span
      }
    }
  } else {
    cd $git_root.stdout
  }
}


###
### Utilities
###

alias rm = rm --trash

###
### Prompt (starship)
###

let username = (
  if ("~/.this-is-work-laptop" | path exists) {
    "allvpv"
  } else {
    $env.USER
  }
)

let hostname = (
  if ("~/.this-is-work-laptop" | path exists) {
    "m3-pro"
  } else {
    (sys host).hostname
  }
)

$env.STARSHIP_SHELL = "nu"

def create_left_prompt [] {
  let exited = match $env.LAST_EXIT_CODE {
    0 => $"(ansi gb)ok(ansi reset)",
    $e => $"(ansi rb)($e)(ansi reset)"
  }

  let short_pwd = pwd | str replace ('~' | path expand) '~'
  let titlebar = if $env.TERM =~ "xterm*" {
    $"(ansi title)($short_pwd)(ansi st)"
  }

  let branch_name = if (which git | length | $in > 0) {
    ^git branch --show-current | complete | get stdout | str trim
  } else {
    ""
  }

  let git_prompt = if $branch_name != "" {
    $"(ansi wu){($branch_name)}(ansi reset) "
  } else {
    ""
  }

  [ $titlebar,
    $"\n(ansi cb)($username)(ansi reset)",
    $"@(ansi cb)($hostname)(ansi reset) ",
    $"[(ansi wb)($short_pwd)(ansi reset)] ",
    $git_prompt,
    $"exited ($exited)\n" ] | str join
}

$env.PROMPT_COMMAND = { || create_left_prompt }
$env.PROMPT_COMMAND_RIGHT = ""
$env.PROMPT_INDICATOR = match $env.USER {
  "root" => $"(ansi wb)#(ansi reset) ",
  _ => $"(ansi wb)\$(ansi reset) "
}
$env.config.color_config.shape_external = "w"
$env.config.color_config.shape_internalcall = "wb"
