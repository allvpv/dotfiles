----------------
--> Mappings
----------------
vim.g.mapleader = ','

-- Visual mode pressing * or # searches for the current selection
-- vim.keymap.set('v', '<silent>*', ':<C-u>call VisualSelection('', '')<CR>/<C-R>=@/<CR><CR>')

-- Turn off search highlight by pressing <D-N>
vim.keymap.set({'n'}, '<D-n>', ':noh<CR>')
vim.keymap.set({'t'}, '<D-n>', '<C-\\><C-N>:noh<CR>')

vim.keymap.set('', '<Space>/', ':vsplit<CR><C-w>l') -- Window splitting with <Space>/, <Space>/-
vim.keymap.set('', '<Space>-', ':split<CR><C-w>j')

-- <C-h,j,k,l> to move between windows
vim.keymap.set('', '<C-h>', '<C-w>h')
vim.keymap.set('', '<C-j>', '<C-w>j')
vim.keymap.set('', '<C-k>', '<C-w>k')
vim.keymap.set('', '<C-l>', '<C-w>l')

-- <Space>c closes window
vim.keymap.set('', '<Space>c', '<C-w>c')

-- <C-=> makes windows equal in size
vim.keymap.set('', '<C-=>', '<C-W>=')

-- Delete and replace without yanking
vim.keymap.set({'v', 'n'}, ',d', '"_d')
vim.keymap.set('v', ',p', '"_dP')

-- Move line without moving cursor
vim.keymap.set('', '<D-e>', '<C-e>')
vim.keymap.set('', '<D-y>', '<C-y>')

MapEscapeInTerminal()

-- Simulate 'Home' and 'End' keys (unavailable on some keyboards)
vim.keymap.set({'t', 'i'}, '<D-Left>', '<Home>')
vim.keymap.set({'t', 'i'}, '<D-Right>', '<End>')

-- <Leader>cs copies the file basename to clipboard
-- <Leader>cl copies the full file path
vim.keymap.set("n", "<leader>cs", [[ :let @*=expand("%")<CR> ]], {})
vim.keymap.set("n", "<leader>cl", [[ :let @*=expand("%:p")<CR> ]], {})

-- <C-,> inserts quotation mark: „
-- <C-"> inserts quotation mark: ”
-- <C-;> inserts quotation mark: “
-- <C->> inserts quotation mark:
vim.keymap.set({'i'}, [[<C-,>]], '„')
vim.keymap.set({'i'}, [[<C-'>]], '”')
vim.keymap.set({'i'}, [[<C-;>]], '“')
vim.keymap.set({'i'}, [[<D-,>]], '«')
vim.keymap.set({'i'}, [[<D-.>]], '»')
