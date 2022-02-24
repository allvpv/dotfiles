import neovim
import subprocess

# VM instance of nvim
nvim = neovim.attach('tcp', address="0.0.0.0", port="5555")

def read_from_clipboard():
    return subprocess.check_output(
        'pbpaste', env={'LANG': 'en_US.UTF-8'}).decode('utf-8')

content = read_from_clipboard()
print(content)
nvim.funcs.setreg('"', content, 'c')

