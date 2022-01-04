function fcp
    scp -P 2222 $argv[1] allvpv@localhost:~/$argv[2]
end

