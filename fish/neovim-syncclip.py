import neovim
import subprocess
import sys

# VM instance of nvim
if len(sys.argv) == 3:
    address = sys.argv[1]
    port = sys.argv[2]
else:
    sys.exit(-1)

try:
    nvim = neovim.attach('tcp', address, port)
except: # silently fail if cannot connect
    sys.exit(-2)

def read_from_clipboard():
    return subprocess.check_output(
        'pbpaste', env={'LANG': 'en_US.UTF-8'}).decode('utf-8')

content = read_from_clipboard()
nvim.funcs.setreg('"', content, 'c')

