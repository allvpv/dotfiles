---------------
--> Plugins
---------------
vim.cmd 'packadd packer.nvim'

require('packer').startup(function(use)
    use 'wbthomason/packer.nvim'
    -- Colorschemes
    use 'aseom/snowcake16'
    use 'morhetz/gruvbox'
    use 'drewtempelmeyer/palenight.vim'
    use 'cocopon/iceberg.vim'
    use 'arcticicestudio/nord-vim'
    use 'rakr/vim-one'
    use 'huyvohcmc/atlas.vim'
    use 'lifepillar/vim-solarized8'
    use 'liuchengxu/space-vim-theme'
    use 'whatyouhide/vim-gotham'
    use 'dracula/vim'
    use 'arzg/vim-substrata'
    use 'rktjmp/lush.nvim'
    use 'Lokaltog/monotone.nvim'
    use 'folke/tokyonight.nvim'
    -- Usability
    use 'nvim-tree/nvim-web-devicons'
    use 'lambdalisue/nerdfont.vim'
    use 'tpope/vim-eunuch' -- rename, remove file, etc.
    use 'tpope/vim-commentary' -- comment out
    use 'nvim-lualine/lualine.nvim'
    -- Filetype
    use 'jocap/rich.vim'
    use 'ziglang/zig.vim'
    use 'nvim-treesitter/nvim-treesitter'
    use 'dag/vim-fish'

    use { 'allvpv/resize-font.nvim', config = function()
        vim.keymap.set('', '<D-=>', ':ResizeFontBigger<cr>')
        vim.keymap.set('', '<D-->', ':ResizeFontSmaller<cr>')
    end }

    use { 'ctrlpvim/ctrlp.vim', config = function()
        vim.g.ctrlp_map = '<D-p>'
        vim.g.ctrlp_cmd = 'CtrlPMixed'
        vim.g.ctrlp_clear_cache_on_exit = 0
        vim.keymap.set('t', '<D-p>', [[<C-\><C-n>:CtrlP<CR>]])
    end }

    use { 'jmckiern/vim-venter', config = function()
        vim.keymap.set('n', '<space>v', ':VenterToggle<CR>')
    end }

    use { 'lambdalisue/fern.vim', config = function()
        vim.keymap.set('n', '<D-x>', ':Fern %:p:h<CR>')
        vim.keymap.set('t', '<D-x>', [[<C-\><C-n>:Fern .<CR>]])
    end }

    use { 'lambdalisue/fern-renderer-nerdfont.vim', config = function()
        vim.g['fern#renderer'] = 'nerdfont'
    end }

    use { 'pacha/vem-tabline', config = function()
        -- Don't close window, when deleting a buffer.
        vim.api.nvim_exec([[
            function! BufferCloseAndReplace()
                let l:currentBufNum = bufnr("%")
                let l:alternateBufNum = g:vem_tabline#tabline.get_replacement_buffer()

                if l:alternateBufNum != 0
                    exec l:alternateBufNum . 'buffer'
                endif

                if bufnr("%") == l:currentBufNum
                    enew
                endif

                if buflisted(l:currentBufNum)
                    execute("bdelete! " . l:currentBufNum)
                endif
            endfunction
        ]], {})

        -- Close the buffer with replacement
        vim.api.nvim_create_user_command('Bclose', 'call BufferCloseAndReplace()', {})

        -- <D-c> to close buffer
        vim.keymap.set('n', '<D-c>', ':Bclose<CR>')
    end }

    use { 'Konfekt/vim-alias', config = function()
        local a = vim.api.nvim_create_augroup('VimAlias', { clear = true })

        vim.api.nvim_create_autocmd('VimEnter', { group = a, command = 'Alias man Man' })
        vim.api.nvim_create_autocmd('VimEnter', { group = a, command = 'Alias ren Rename' })
        vim.api.nvim_create_autocmd('VimEnter', { group = a, command = 'Alias rm Delete' })
        vim.api.nvim_create_autocmd('VimEnter', { group = a, command = 'Alias bclose Bclose' })
        vim.api.nvim_create_autocmd('VimEnter', { group = a, command = 'Alias tree Tree' })
    end }
end )

require("tokyonight").setup({
    style = "moon",         -- Storm`, `moon`, `night` or `day`.
    light_style = "day",    -- The theme is used when the background is set to light.
    transparent = false,    -- Enable this to disable setting the background color.
    terminal_colors = true, -- Configure the colors used when opening a `:terminal` in Neovim.
    dim_inactive = false,   -- Dims inactive windows
    lualine_bold = true,    -- When `true`, section headers in the lualine theme will be bold
    day_brightness = 0.3,   -- Brightness of the colors of the "day" style
    styles = {              -- Style to be applied to different syntax groups
        comments = { italic = true },
        keywords = { italic = true },
        functions = {},
        variables = {},
        sidebars = "dark",  -- Style for sidebars, see below
        floats = "dark",    -- Style for floating windows
    },
    sidebars = { "qf", "help", "terminal" }, -- Set a darker background on sidebar-like windows.
    hide_inactive_statusline = false,        -- Hide inactive statuslines

    --- You can override specific color groups to use other groups or a hex color
    --- function will be called with a ColorScheme table
    ---@param colors ColorScheme
    on_colors = function(colors)
    end,

    --- You can override specific highlights to use other groups or a hex color
    --- function will be called with a Highlights and ColorScheme table
    ---@param highlights Highlights
    ---@param colors ColorScheme
    on_highlights = function(highlights, colors)
    end,
})
