alias vim-bin = vim

def vim [...args] {
  if "NVIM" in $env {
    __nvim_remote ...$args
  } else {
    vim-bin ...$args
  }
}

if ("~/.this-is-work-laptop" | path expand | path exists) {
  $env.TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE = "/var/run/docker.sock"
  $env.DOCKER_HOST = "unix://$HOME/.colima/default/docker.sock"
  $env.TESTCONTAINERS_RYUK_DISABLED = "true"

  $env.JAVA_8_HOME = ^/usr/libexec/java_home -v1.8
  $env.JAVA_11_HOME = ^/usr/libexec/java_home -v11
  $env.JAVA_17_HOME = ^/usr/libexec/java_home -v17
  $env.JAVA_21_HOME = ^/usr/libexec/java_home -v21
}


def --env switch_java [java_version] {
  let java_var = $"JAVA_($java_version)_HOME"

  if $java_var in $env {
    let java_path = ($env | get $java_var)
    print $"Setting JAVA_HOME to ($java_var) \(($java_path)\)"
    $env.JAVA_HOME = $java_path
  } else {
    error make {
      msg: $"No ($java_var) detected in environment",
      label: {
        text: $"'($java_version)' taken from here",
        span: (metadata $java_version).span
      }
    }
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
