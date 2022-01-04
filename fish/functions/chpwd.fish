function chpwd --on-variable PWD --description 'handler of changing $PWD'
  if not status --is-command-substitution ; and status --is-interactive
    $HOME/.config/fish/neovim-autocd.py >/dev/null 2>&1 < /dev/null &
  end
end
