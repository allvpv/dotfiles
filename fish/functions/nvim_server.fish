function nvim_server
  if test (count $argv) -ne 2
    echo "Provide exactly two argument: hostname:port (1) and the value of session variable (2)" 1>&2
  else
    nvim --cmd 'let g:neovim_session_type="$argv[2]"' --headless --listen "$argv[1]" &
  end
end
