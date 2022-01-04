function nvim_general_server
  nvim --cmd 'let g:neovim_session_type="general"' --headless --listen "localhost:33300" &
end
