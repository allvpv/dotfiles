#!/usr/bin/env python3
# neovim-autocd.py
import neovim
import os

instance=os.environ['NVIM_LISTEN_ADDRESS'].split(':')

nvim = neovim.attach('tcp', address=instance[0], port=instance[1])
nvim.vars['__autocd_cwd'] = os.getcwd()
nvim.command('execute "lcd" fnameescape(g:__autocd_cwd)')
del nvim.vars['__autocd_cwd']
