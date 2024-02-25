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
