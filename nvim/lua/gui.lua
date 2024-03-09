--------------------
--> GUI-specific
--------------------
vim.opt.guifont = "MonaspiceXe Nerd Font:h10:w-1"

vim.g.neovide_input_use_logo = true             -- Forward ⌘-key shortcuts to neovide
vim.g.neovide_remember_window_size = true       -- Remember
vim.g.neovide_cursor_animation_length = 0.15    -- Time for cursor to finish jumping
vim.g.neovide_scroll_animation_length = 0.4     -- Time for scroll to finish
vim.g.neovide_cursor_trail_size = 0             -- Cursor movement deformation
-- vim.g.neovide_transparency=0.8
-- vim.g.neovide_window_blurred=1
vim.opt.linespace = 5                           -- Just about right

vim.cmd [[ colorscheme gruvbox ]]
