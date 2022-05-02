import neovim
import subprocess
import sys

# VM instance of nvim
if len(sys.argv) == 3:
    address = sys.argv[1]
    port = sys.argv[2]
else:
    address="0.0.0.0"
    port="5555"

try:
    nvim = neovim.attach('tcp', address, port)
except: # silently fail if cannot connect
    sys.exit(-2)

def read_from_clipboard():
    return nvim.funcs.getreg('"')

def copy_to_clipboard(content):
    return subprocess.check_output(
        'pbcopy', input=bytes(content.encode('utf-8'))).decode('utf-8')

content = read_from_clipboard()
copy_to_clipboard(content)

