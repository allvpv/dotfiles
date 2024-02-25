systemd services, launchd services, etc...
for quick setup

### Remote nvim
```
NVIM_EXE=/usr/bin/nvim PORT=1111 envsubst < nvim.service.template >| nvim.service
systemd-analyze verify nvim.service
systemctl enable $(realpath nvim.service)
systemctl start nvim.service
systemctl status nvim.service
```

### SSH tunnel service (Mac OS)
```
LOCALPORT=1111 REMOTEPORT=1111 REMOTE=allvpv@allvpv.org envsubst < local.sshtunnel.plist.template > local.sshtunnel.plist
launchctl bootstrap gui/501 $(realpath local.sshtunnel.plist)
launchctl kickstart gui/501/local.sshtunnel
launchctl print gui/501/local.sshtunnel | egrep "path|state|runs"
```
