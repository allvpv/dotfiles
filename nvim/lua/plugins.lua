---------------
--> Plugins
---------------
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

---------------
--> TODO: Migrate to `rocks.nvim` when NVIM v0.10 becomes stable
---------------
require('lazy').setup({
    concurrency = 4,
    -- Colorschemes
    { 'ellisonleao/gruvbox.nvim',
        config = function()
            -- Default options:
            require('gruvbox').setup({
                terminal_colors = true, -- add neovim terminal colors
                undercurl = true,
                underline = true,
                bold = true,
                italic = {
                    strings = true,
                    emphasis = true,
                    comments = true,
                    operators = false,
                    folds = true,
                },
                strikethrough = true,
                invert_selection = false,
                invert_signs = false,
                invert_tabline = false,
                invert_intend_guides = false,
                inverse = true, -- invert background for search, diffs,
                                -- statuslines and errors
                contrast = 'hard', -- can be 'hard', 'soft' or empty string
                palette_overrides = {},
                overrides = {},
                dim_inactive = false,
                transparent_mode = false,
            })
        end,
    },
    { 'drewtempelmeyer/palenight.vim' },
    { 'folke/tokyonight.nvim' },
    { 'EdenEast/nightfox.nvim' },

    -- Usability
    { 'nvim-tree/nvim-web-devicons' },
    { 'ryanoasis/vim-devicons' },
    { 'lambdalisue/nerdfont.vim' },
    { 'tpope/vim-eunuch' }, -- rename, remove file, etc.
    { 'nicwest/vim-camelsnek' }, -- convert cases
    { 'nvim-telescope/telescope.nvim', branch = '0.1.x', dependencies = 'nvim-lua/plenary.nvim',
        config = function()
            local builtin = require 'telescope.builtin'

            vim.keymap.set('n', '<leader>fd', builtin.diagnostics, {})
            vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
            vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
            vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
            vim.keymap.set('n', '<leader>fc', builtin.colorscheme, {})
        end,
    },
    { 'folke/trouble.nvim', dependencies = 'nvim-tree/nvim-web-devicons' },
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    { 'nvim-telescope/telescope-file-browser.nvim',
        config = function()
            local file_browser = require('telescope').extensions.file_browser
            vim.keymap.set('n', '<leader>ff', file_browser.file_browser, {})
        end,
    },
    { 'nvim-lualine/lualine.nvim' },
    { 'folke/neoconf.nvim' },
    { 'tpope/vim-fugitive' }, -- For `git blame`
    { 'github/copilot.vim' },

    -- Filetype
    { 'jocap/rich.vim' },
    { 'ziglang/zig.vim' },
    { 'udalov/kotlin-vim' },
    { 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate' },
    { 'dag/vim-fish' },
    { 'zah/nim.vim' },
    { 'vim-scripts/lbnf.vim' },
    { 'vim-scripts/django.vim' }, -- Syntax highlighting for django templates

    -- LSP
    { 'mfussenegger/nvim-jdtls', -- Eclipse JDT <==> LSP bridge
        config = function()
            vim.api.nvim_create_autocmd('FileType', {
              pattern = {'java'},
              callback = function()
                    local specialfile = vim.fs.find(
                        {'gradlew', 'mvnw', 'pom.xml', '.git'},
                        { upward = true }
                    )

                    if #specialfile ~= 0 then
                        rootdir = vim.fs.dirname(specialfile[1])
                    else
                        rootdir = vim.fn.getcwd()
                    end

                    local projectname = vim.fn.fnamemodify(rootdir, ':p:h:t')
                    local workspace = os.getenv('HOME') .. '/.cache/jdtls/' .. projectname

                    local cmd = {
                        '/usr/bin/java',
                        '-Declipse.application=org.eclipse.jdt.ls.core.id1',
                        '-Dosgi.bundles.defaultStartLevel=4',
                        '-Declipse.product=org.eclipse.jdt.ls.core.product',
                        '-Dlog.protocol=true',
                        '-Dlog.level=ALL',
                        '-Xmx1g',
                        '--add-modules=ALL-SYSTEM',
                        '--add-opens', 'java.base/java.util=ALL-UNNAMED',
                        '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
                        '-jar', '/usr/local/Cellar/jdtls/1.38.0/libexec/plugins/org.eclipse.equinox.launcher_1.6.900.v20240613-2009.jar',
                        '-configuration', '/usr/local/Cellar/jdtls/1.38.0/libexec/config_mac',
					    '-data', workspace
                    }

                    require('jdtls').start_or_attach({
                        cmd = cmd,
                        root_dir = rootdir,
                    })
                end
            })
        end,
    },
    { 'neovim/nvim-lspconfig' }, -- Collection of configurations for built-in LSP client
    { 'hrsh7th/nvim-cmp' }, -- Autocompletion plugin
    { 'hrsh7th/cmp-nvim-lsp' }, -- LSP source for nvim-cmp
    { 'saadparwaiz1/cmp_luasnip' }, -- Snippets source for nvim-cmp
    { 'L3MON4D3/LuaSnip' }, -- Snippets plugin
    { 'simrat39/rust-tools.nvim' }, -- Adds extra functionality over rust-analyzer
    { 'mrcjkb/haskell-tools.nvim',
        version = '^3', -- Recommended
        ft = { 'haskell', 'lhaskell', 'cabal', 'cabalproject' },
    },
    {'nvim-java/nvim-java'},

    { 'folke/trouble.nvim' }, -- Show diagnostics
    { 'vhyrro/luarocks.nvim', priority = 1000, config = true },
    { 'ctrlpvim/ctrlp.vim',
        config = function()
            vim.g.ctrlp_map = '<D-p>'
            vim.g.ctrlp_cmd = 'CtrlPMixed'
            vim.g.ctrlp_clear_cache_on_exit = 0
            vim.keymap.set('t', '<D-p>', [[<C-\><C-n>:CtrlP<CR>]])
        end,
    },

    { 'jmckiern/vim-venter',
        config = function()
            vim.keymap.set('n', '<space>v', ':VenterToggle<CR>')
        end,
    },

    { 'pacha/vem-tabline',
        config = function()
            -- Don't close window, when deleting a buffer.
            vim.api.nvim_exec([[
                function! BufferCloseAndReplace()
                    let l:currentBufNum = bufnr('%')
                    let l:alternateBufNum = g:vem_tabline#tabline.get_replacement_buffer()

                    if l:alternateBufNum != 0
                        exec l:alternateBufNum . 'buffer'
                    endif

                    if bufnr('%') == l:currentBufNum
                        enew
                    endif

                    if buflisted(l:currentBufNum)
                        execute('bdelete! ' . l:currentBufNum)
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
        end,
    },

    { 'Konfekt/vim-alias',
        config = function()
            local a = vim.api.nvim_create_augroup('VimAlias', { clear = true })

            vim.api.nvim_create_autocmd('VimEnter', { group = a, command = 'Alias man Man' })
            vim.api.nvim_create_autocmd('VimEnter', { group = a, command = 'Alias ren Rename' })
            vim.api.nvim_create_autocmd('VimEnter', { group = a, command = 'Alias rm Delete' })
            vim.api.nvim_create_autocmd('VimEnter', { group = a, command = 'Alias bclose Bclose' })
            vim.api.nvim_create_autocmd('VimEnter', { group = a, command = 'Alias tele Telescope' })
        end,
    },
})

require('lualine').setup {
    options = {
        icons_enabled = true,
        theme = 'auto',
        component_separators = { left = '', right = ''},
        section_separators = { left = ' ', right = ''},
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

require('tokyonight').setup {
    style = 'moon',         -- Storm`, `moon`, `night` or `day`.
    light_style = 'day',    -- The theme is used when the background is set to light.
    transparent = false,    -- Enable this to disable setting the background color.
    terminal_colors = true, -- Configure the colors used when opening a `:terminal` in Neovim.
    dim_inactive = false,   -- Dims inactive windows
    lualine_bold = true,    -- When `true`, section headers in the lualine theme will be bold
    day_brightness = 0.3,   -- Brightness of the colors of the 'day' style
    styles = {              -- Style to be applied to different syntax groups
        comments = { italic = true },
        keywords = { italic = true },
        functions = {},
        variables = {},
        sidebars = 'dark',  -- Style for sidebars, see below
        floats = 'dark',    -- Style for floating windows
    },
    sidebars = { 'qf', 'help', 'terminal' }, -- Set a darker background on sidebar-like windows.
    hide_inactive_statusline = false,        -- Hide inactive statuslines
}

require('nightfox').setup {
    options = {
        -- Compiled file's destination location
        compile_path = vim.fn.stdpath('cache') .. '/nightfox',
        compile_file_suffix = '_compiled', -- Compiled file suffix
        transparent = false,    -- Disable setting background
        terminal_colors = true, -- Set terminal colors (vim.g.terminal_color_*) used in `:terminal`
        dim_inactive = false,   -- Non focused panes set to alternative background
        module_default = true,  -- Default enable value for modules
        styles = {              -- Style to be applied to different syntax groups
            comments = 'italic',    -- Value is any valid attr-list value `:help attr-list`
            conditionals = 'NONE',
            constants = 'NONE',
            functions = 'bold',
            keywords = 'NONE',
            numbers = 'NONE',
            operators = 'NONE',
            strings = 'NONE',
            types = 'NONE',
            variables = 'NONE',
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
    local fb_actions = require('telescope').extensions.file_browser.actions

    require('telescope').setup {
        extensions = {
            file_browser = {
                theme = 'ivy',
                -- disables netrw and use telescope-file-browser in its place
                hijack_netrw = true,
                mappings = {
                    ['i'] = {}, -- your custom insert mode mappings
                    ['n'] = { -- your custom normal mode mappings
                        ['u'] = fb_actions.goto_parent_dir,
                    },
                },
            },
        }
    }
end

SetupTelescope()

local function SetupLsp()
    local capabilities = require('cmp_nvim_lsp').default_capabilities()
    local lspconfig = require('lspconfig')
    local luasnip = require('luasnip')
    local cmp = require('cmp')

    local snipmate_loader = require('luasnip.loaders.from_snipmate')

    snipmate_loader.lazy_load {
        paths = '~/.config/nvim/snippets'
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
            -- ['<Tab>'] = cmp.mapping(function(fallback)
            --     if luasnip.expand_or_jumpable() then
            --         luasnip.expand_or_jump()
            --     else
            --         fallback()
            --     end
            -- end, { 'i', 's' }),
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

    vim.keymap.set('n', 'gD', vim.lsp.buf.implementation, {})
    vim.keymap.set('n', 'gK', vim.lsp.buf.signature_help, {})
    vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, {})
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, {})
    vim.keymap.set('n', 'g0', vim.lsp.buf.document_symbol, {})
    vim.keymap.set('n', 'gW', vim.lsp.buf.workspace_symbol, {})
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})
    vim.keymap.set('n', 'ga', vim.lsp.buf.code_action, {})
    vim.keymap.set('n', 'gn', vim.lsp.buf.rename, {})
end

SetupLsp()

local function SetupRustTools()
    local rust_tools = require('rust-tools')

    rust_tools.setup {
        tools = {
            runnables = {
                use_telescope = false,
            },
            inlay_hints = {
                auto = true,
                show_parameter_hints = true,
                parameter_hints_prefix = '≫ ',
                other_hints_prefix = '≫ ',
                highlight = 'LineNr',
            },
        },

        server = {
            settings = {
                ['rust-analyzer'] = {
                    editor = {
                        formatOnSave = true,
                    },
                    inlayHints = {
                        locationLinks = false,
                    },
                    checkOnSave = {
                        allTargets = false,
                    },
                    assist = {
                        importEnforceGranularity = true,
                        importPrefix = 'crate',
                    },
                    cargo = {
                        allFeatures = true,
                    },
                    diagnostics = {
                        enable = true,
                        experimental = {
                            enable = true,
                        },
                    },
                },
            },
            on_attach = function(client, buffer)
                -- Show diagnostic popup on cursor hover
                local au = vim.api.nvim_create_augroup('DiagnosticFloat', {
                    clear = true
                })

                vim.api.nvim_create_autocmd('CursorHold', {
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
