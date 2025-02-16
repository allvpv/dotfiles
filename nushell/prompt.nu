###
### Prompt
###

let username = if $is_work_laptop { 'allvpv' } else { $env.USER }
let hostname = if $is_work_laptop { 'm3-pro' } else { (sys host).hostname }

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

  [ $titlebar,
    $"\n(ansi cb)($username)(ansi reset)",
    $'@(ansi cb)($hostname)(ansi reset) ',
    $'[(ansi wb)($short_pwd)(ansi reset)] ',
    $venv,
    $git_prompt,
    $"exited ($exited)\n" ] | str join
}

$env.PROMPT_COMMAND = { || create_left_prompt }
$env.PROMPT_COMMAND_RIGHT = ''
$env.PROMPT_INDICATOR = match $env.USER {
  'root' => $'(ansi wb)#(ansi reset) ',
  _ => $'(ansi wb)$(ansi reset) '
}
$env.config.color_config.shape_external = 'w'
$env.config.color_config.shape_internalcall = 'wb'
