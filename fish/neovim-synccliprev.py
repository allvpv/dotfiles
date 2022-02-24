import neovim
import subprocess

# VM instance of nvim
nvim = neovim.attach('tcp', address="0.0.0.0", port="5555")

def read_from_clipboard():
    return nvim.funcs.getreg('"')

def copy_to_clipboard(content):
    return subprocess.check_output(
        'pbcopy', input=bytes(content.encode('utf-8'))).decode('utf-8')

content = read_from_clipboard()
copy_to_clipboard(content)

