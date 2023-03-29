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
  pattern = {'latex', 'tex'},
  callback = function(args)
    vim.opt_local.autoindent = false -- No indent automatically
    vim.opt_local.colorcolumn = '0'  -- No colorcolumn for Latex
    vim.opt_local.textwidth = 100    -- Auto break lines past 100 characters while typing
  end
})
