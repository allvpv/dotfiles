-------------------------
--> Filetype-specific
-------------------------
vim.g.do_filetype_lua = 1    -- Enable Lua filetype plugin

vim.api.nvim_create_autocmd('FileType', {
  pattern = {'c', 'cpp', 'java', 'lua', 'proto'},
  callback = function(args)
    vim.opt_local.shiftwidth = 4 -- Number of spaces for each indent
    vim.opt_local.tabstop = 4 -- Number of spaces that a <Tab> in the file counts for
  end
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'latex',
  callback = function(args)
    vim.opt_local.autoindent = false -- No indent automatically
    vim.opt.colorcolumn = '0'  -- No colorcolumn for Latex
  end
})
