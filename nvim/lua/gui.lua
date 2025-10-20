--------------------
--> GUI-specific
--------------------
vim.g.neovide_input_use_logo = true           -- Forward ⌘-key shortcuts to neovide
vim.g.neovide_remember_window_size = true     -- Remember
vim.g.neovide_cursor_animation_length = 0.15  -- Time for cursor to finish jumping
vim.g.neovide_scroll_animation_length = 0.4   -- Time for scroll to finish
vim.g.neovide_cursor_trail_size = 0           -- Cursor movement deformation
vim.opt.linespace = 0                         -- Just about right
vim.g.neovide_fullscreen = 1                  -- Start in fullscreen
vim.g.neovide_padding_left = 4                -- Minimal padding for MacOS fullscreen offset
vim.g.neovide_padding_right = 4               -- ...

vim.cmd [[ colorscheme evangelion ]]
