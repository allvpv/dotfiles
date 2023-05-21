function screv
  set script python3 /Users/przemek/Projects/dotfiles/fish/neovim-synccliprev.py
  set endpoints fedora_vm:5555

  for endpoint in $endpoints
     string split ':' $endpoint | xargs $script
 end

end
