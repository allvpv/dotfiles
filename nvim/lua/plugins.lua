---------------
--> Plugins
---------------
vim.cmd 'packadd packer.nvim'

require('packer').startup(function(use)
    use 'wbthomason/packer.nvim'
    use 'udalov/kotlin-vim'
    -- Colorschemes
    use 'aseom/snowcake16'
    use 'ellisonleao/gruvbox.nvim'
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
    use "EdenEast/nightfox.nvim"
    -- Usability
    use 'nvim-tree/nvim-web-devicons'
    use 'ryanoasis/vim-devicons'
    use 'lambdalisue/nerdfont.vim'
    use 'tpope/vim-eunuch' -- rename, remove file, etc.
    use 'tpope/vim-commentary' -- comment out

    use { 'f-person/auto-dark-mode.nvim',
        config = function()
            local auto_dark_mode = require 'auto-dark-mode'

            auto_dark_mode.setup({
                update_interval = 4000,
                set_dark_mode = function()
                    vim.cmd [[ colorscheme duskfox ]]
                end,
                set_light_mode = function()
                    vim.cmd [[ colorscheme dawnfox ]]
                end,
            })

            auto_dark_mode.init()
        end
    }

    use { 'nvim-telescope/telescope.nvim', tag = '0.1.0', requires = 'nvim-lua/plenary.nvim',
        config = function()
            local builtin = require 'telescope.builtin'

            vim.keymap.set('n', '<leader>fd', builtin.diagnostics, {})
            vim.keymap.set('n', '<leader>fn', builtin.find_files, {})
            vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
            vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
            vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
            vim.keymap.set('n', '<leader>fc', builtin.colorscheme, {})
            vim.keymap.set('n', '<leader>fm', builtin.man_pages, {})
        end
    }

    use { 'nvim-telescope/telescope-fzy-native.nvim',
        config = function()
            require('telescope').load_extension('fzy_native')
        end
    }

    use { 'nvim-telescope/telescope-file-browser.nvim',
        config = function()
            local file_browser = require('telescope').extensions.file_browser
            vim.keymap.set('n', '<leader>ff', file_browser.file_browser, {})
        end
    }

    -- Filetype
    use 'jocap/rich.vim'
    use 'ziglang/zig.vim'
    use 'nvim-treesitter/nvim-treesitter'
    use 'dag/vim-fish'
    use 'zah/nim.vim'
    use 'vim-scripts/lbnf.vim'
    use 'vim-scripts/django.vim' -- syntax highlighting for django templates

    use 'nvim-lualine/lualine.nvim'
    use 'neovim/nvim-lspconfig' -- Collection of configurations for built-in LSP client
    use 'hrsh7th/nvim-cmp' -- Autocompletion plugin
    use 'hrsh7th/cmp-nvim-lsp' -- LSP source for nvim-cmp
    use 'saadparwaiz1/cmp_luasnip' -- Snippets source for nvim-cmp
    use 'L3MON4D3/LuaSnip' -- Snippets plugin
    use 'simrat39/rust-tools.nvim' -- Adds extra functionality over rust analyzer
    use 'github/copilot.vim' -- GitHub Copilot

    use { '/Users/przemek/Working/resize-font.nvim',
        config = function()
            local resize_font = require 'resize-font'

            -- setup is optional; default resize step is '0.3'
            resize_font.setup {
                resize_step = 0.3,
            }

            -- prefered way of setting the keymap
            vim.keymap.set('', '<D-->', resize_font.smaller)
            vim.keymap.set('', '<D-=>', resize_font.bigger)
        end
    }

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

        -- Easy buffer switching
        vim.keymap.set('n', '<D-k>', '<Plug>vem_prev_buffer-')
        vim.keymap.set('n', '<D-j>', '<Plug>vem_next_buffer-')
        vim.keymap.set('t', '<D-k>', [[<C-\><C-n><Plug>vem_prev_buffer-]])
        vim.keymap.set('t', '<D-j>', [[<C-\><C-n><Plug>vem_next_buffer-]])

        -- Easy buffer repositioning
        vim.keymap.set('n', '<D-C-k>', '<Plug>vem_move_buffer_left-')
        vim.keymap.set('n', '<D-C-j>', '<Plug>vem_move_buffer_right-')

        -- Close the buffer with replacement
        vim.api.nvim_create_user_command('Bclose', 'call BufferCloseAndReplace()', {})

        -- <D-c> to close buffer
        vim.keymap.set('n', '<D-c>', ':Bclose<CR>')

        vim.g.vem_tabline_show_icon = 1
    end }

    use { 'Konfekt/vim-alias', config = function()
        local a = vim.api.nvim_create_augroup('VimAlias', { clear = true })

        vim.api.nvim_create_autocmd('VimEnter', { group = a, command = 'Alias man Man' })
        vim.api.nvim_create_autocmd('VimEnter', { group = a, command = 'Alias ren Rename' })
        vim.api.nvim_create_autocmd('VimEnter', { group = a, command = 'Alias rm Delete' })
        vim.api.nvim_create_autocmd('VimEnter', { group = a, command = 'Alias bclose Bclose' })
        vim.api.nvim_create_autocmd('VimEnter', { group = a, command = 'Alias tele Telescope' })
    end }
end )

require('lualine').setup {
    options = {
        icons_enabled = true,
        theme = 'auto',
        component_separators = { left = '', right = ''},
        section_separators = { left = '', right = ''},
        disabled_filetypes = {
            statusline = {},
            winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = false,
        refresh = {
            statusline = 1000,
            tabline = 1000,
            winbar = 1000,
        }
    },
    sections = {
        lualine_a = {'mode'},
        lualine_b = {'branch', 'diff', 'diagnostics'},
        lualine_c = {'filename'},
        lualine_x = {'encoding', 'fileformat', 'filetype'},
        lualine_y = {'progress'},
        lualine_z = {'location'}
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {'filename'},
        lualine_x = {'location'},
        lualine_y = {},
        lualine_z = {}
    },
    tabline = {},
    winbar = {},
    inactive_winbar = {},
    extensions = {}
}

require("tokyonight").setup {
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
}

require('nightfox').setup {
    options = {
        -- Compiled file's destination location
        compile_path = vim.fn.stdpath("cache") .. "/nightfox",
        compile_file_suffix = "_compiled", -- Compiled file suffix
        transparent = false,    -- Disable setting background
        terminal_colors = true, -- Set terminal colors (vim.g.terminal_color_*) used in `:terminal`
        dim_inactive = false,   -- Non focused panes set to alternative background
        module_default = true,  -- Default enable value for modules
        styles = {              -- Style to be applied to different syntax groups
            comments = "italic",    -- Value is any valid attr-list value `:help attr-list`
            conditionals = "NONE",
            constants = "NONE",
            functions = "bold",
            keywords = "NONE",
            numbers = "NONE",
            operators = "NONE",
            strings = "NONE",
            types = "NONE",
            variables = "NONE",
        },
        inverse = {             -- Inverse highlight for different types
            match_paren = false,
            visual = false,
            search = false,
        },
        modules = {             -- List of various plugins and additional options
        },
    },
    palettes = {},
    specs = {},
    groups = {},
}

local function SetupTelescope()
    local fb_actions = require("telescope").extensions.file_browser.actions

    require('telescope').setup {
        extensions = {
            file_browser = {
                theme = "ivy",
                -- disables netrw and use telescope-file-browser in its place
                hijack_netrw = true,
                mappings = {
                    ["i"] = {}, -- your custom insert mode mappings
                    ["n"] = { -- your custom normal mode mappings
                        ["u"] = fb_actions.goto_parent_dir,
                    },
                },
            },
        }
    }
end

SetupTelescope()

local function SetupLsp()
    local capabilities = require("cmp_nvim_lsp").default_capabilities()
    local lspconfig = require('lspconfig')
    local luasnip = require('luasnip')
    local cmp = require('cmp')

    local snipmate_loader = require("luasnip.loaders.from_snipmate")

    snipmate_loader.lazy_load {
        paths = "~/.config/nvim/snippets"
    }

    -- Add additional capabilities supported by nvim-cmp
    for _, lsp in ipairs({'clangd', 'rust_analyzer', 'pyright', 'tsserver'}) do
        lspconfig[lsp].setup {
            capabilities = capabilities,
        }
    end

    cmp.setup {
        snippet = {
            expand = function(args)
                luasnip.lsp_expand(args.body)
            end,
        },
        mapping = cmp.mapping.preset.insert({
            ['<C-d>'] = cmp.mapping.scroll_docs(-4),
            ['<C-f>'] = cmp.mapping.scroll_docs(4),
            ['<C-Space>'] = cmp.mapping.complete(),
            ['<CR>'] = cmp.mapping.confirm {
                behavior = cmp.ConfirmBehavior.Replace,
                select = true,
            },
            ['<Tab>'] = cmp.mapping(function(fallback)
                if luasnip.expand_or_jumpable() then
                    luasnip.expand_or_jump()
                else
                    fallback()
                end
            end, { 'i', 's' }),
            ['<S-Tab>'] = cmp.mapping(function(fallback)
                if luasnip.jumpable(-1) then
                    luasnip.jump(-1)
                else
                    fallback()
                end
            end, { 'i', 's' }),
        }),
        sources = {
            { name = 'nvim_lsp' },
            { name = 'luasnip' },
        },
    }

    vim.keymap.set("n", "gD", vim.lsp.buf.implementation, keymap_opts)
    vim.keymap.set("n", "gK", vim.lsp.buf.signature_help, keymap_opts)
    vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, keymap_opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, keymap_opts)
    vim.keymap.set("n", "g0", vim.lsp.buf.document_symbol, keymap_opts)
    vim.keymap.set("n", "gW", vim.lsp.buf.workspace_symbol, keymap_opts)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, keymap_opts)
    vim.keymap.set("n", "ga", vim.lsp.buf.code_action, keymap_opts)
    vim.keymap.set("n", "gn", vim.lsp.buf.rename, keymap_opts)
end

SetupLsp()

function SetupRustTools()
    local rust_tools = require("rust-tools")

    rust_tools.setup {
        tools = {
            runnables = {
                use_telescope = false,
            },
            inlay_hints = {
                auto = true,
                show_parameter_hints = true,
                parameter_hints_prefix = "≫ ",
                other_hints_prefix = "≫ ",
                highlight = "LineNr",
            },
        },

        server = {
            settings = {
                ["rust-analyzer"] = {
                    editor = {
                        formatOnSave = true,
                    },
                    inlayHints = {
                        locationLinks = false,
                    },
                    checkOnSave = {
                        allTargets = false,
                    },
                },
            },
            on_attach = function(client, buffer)
                -- Show diagnostic popup on cursor hover
                local au = vim.api.nvim_create_augroup("DiagnosticFloat", {
                    clear = true
                })

                vim.api.nvim_create_autocmd("CursorHold", {
                    callback = function()
                        vim.diagnostic.open_float(nil, {
                            focusable = false
                        })
                    end,
                    group = au,
                })
            end,
        },
    }
end

SetupRustTools()
