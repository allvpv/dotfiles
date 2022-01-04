function neovide_client
  if test (count $argv) -ne 1
    echo "Provide exactly one argument: hostname:port" 1>&2
  else
    neovide --multigrid --frameless --remote-tcp=$argv[1]
  end
end
