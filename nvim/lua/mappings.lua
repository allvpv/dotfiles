----------------
--> Mappings
----------------
vim.g.mapleader = ','

-- Turn off search highlight by pressing <D-N>
vim.keymap.set({'n'}, '<D-n>', ':noh<CR>')
vim.keymap.set({'t'}, '<D-n>', '<C-\\><C-N>:noh<CR>')

-- Window splitting with <Space>/, <Space>/-
vim.keymap.set('', '<Space>/', ':vsplit<CR><C-w>l')
vim.keymap.set('', '<Space>-', ':split<CR><C-w>j')

-- <C-h,j,k,l> to move between windows
vim.keymap.set('', '<C-h>', '<C-w>h')
vim.keymap.set('', '<C-j>', '<C-w>j')
vim.keymap.set('', '<C-k>', '<C-w>k')
vim.keymap.set('', '<C-l>', '<C-w>l')

-- <Space>c closes window
vim.keymap.set('', '<Space>c', '<C-w>c')

-- ,x closes the tab
vim.keymap.set('n', ',x', ':tabclose<CR>', {})

-- <C-x> closes the buffer
vim.keymap.set('n', '<C-x>', ':bdelete!<CR>')

-- ,j ,k to move between tabs
vim.keymap.set('n', ',j', ':tabnext<CR>', {})
vim.keymap.set('n', ',k', ':tabprev<CR>', {})

-- <C-=> makes windows equal in size
vim.keymap.set('', '<C-=>', '<C-W>=')

-- Delete and replace without yanking
vim.keymap.set('v', ',c', '"_c')
vim.keymap.set('v', ',d', '"_d')
vim.keymap.set('v', ',p', 'P')

-- Move line without moving cursor
vim.keymap.set('', '<D-e>', '<C-e>')
vim.keymap.set('', '<D-y>', '<C-y>')

-- Simulate 'Home' and 'End' keys (unavailable on some keyboards)
-- Mostly useful in the terminal mode, where a modal editing is not available
vim.keymap.set({'t', 'i'}, '<D-Left>', '<Home>')
vim.keymap.set({'t', 'i'}, '<D-Right>', '<End>')

-- <C-,> inserts quotation mark: „
-- <C-"> inserts quotation mark: ”
-- <C-;> inserts quotation mark: “
vim.keymap.set({'i'}, [[<C-,>]], '„')
vim.keymap.set({'i'}, [[<C-'>]], '”')
vim.keymap.set({'i'}, [[<C-;>]], '“')

-- Disable annoying terminal behaviour on <S-Space>
vim.keymap.set({'t'}, [[<S-Space>]], [[<Space>]])

-- Scalling
vim.keymap.set('', '<D-->', function()
    vim.g.neovide_scale_factor = vim.g.neovide_scale_factor - 0.1
end)

vim.keymap.set('', '<D-=>', function()
    vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + 0.1
end)

-- Terminal
vim.keymap.set('n', ',t', ':terminal<CR>')

-- Open file in Quick Look on macOS
if vim.loop.os_uname().sysname == "Darwin" then
  vim.keymap.set('n', ',p', ":!qlmanage -p '%:p' >/dev/null 2>/dev/null 1>&2<CR>")
end
