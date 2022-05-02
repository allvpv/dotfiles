function sc
  set script python3 /Users/przemek/Projects/dotfiles/fish/neovim-syncclip.py
  set endpoints 0.0.0.0:5555 xt4500:5554

  for endpoint in $endpoints
     string split ':' $endpoint | xargs $script
 end

end
