function nvim_document_server
  nvim --cmd 'let g:neovim_session_type="document"' --headless --listen "localhost:33310" &
end
