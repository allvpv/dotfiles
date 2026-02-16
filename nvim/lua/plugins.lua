---------------
--> Lazy
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
--> Helpers
---------------
local function GetGitRoot()
    local handle = io.popen('git rev-parse --show-toplevel')
    local result = handle:read("*a"):gsub("\n", "")
    handle:close()

    if #result ~= 0 then
        return result
    else
        return nil
    end
end

---------------
--> Plugins
---------------
require('lazy').setup({
    -- The default is unlimited, causing problems on constraint environments
    concurrency = 4,
    -- Colorschemes
    { "allvpv/evangelion.nvim" },
    { "rktjmp/lush.nvim" },
    { "rktjmp/shipwright.nvim" },
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
    { "rose-pine/neovim", name = "rose-pine" },
    { 'drewtempelmeyer/palenight.vim' },
    { 'folke/tokyonight.nvim',
        config = function()
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
        end
    },
    { 'EdenEast/nightfox.nvim',
        config = function()
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
                    inverse = {
                        match_paren = false,
                        visual = false,
                        search = false,
                    },
                    modules = {
                    },
                },
                palettes = {},
                specs = {},
                groups = {},
            }
        end
    },
    -- Usability
    { 'nvim-tree/nvim-web-devicons' },
    { 'ryanoasis/vim-devicons' },
    { 'lambdalisue/nerdfont.vim' },
    { 'tpope/vim-eunuch' }, -- rename, remove file, etc.
    { 'folke/trouble.nvim', dependencies = 'nvim-tree/nvim-web-devicons' },
    { 'nvim-lualine/lualine.nvim',
        config = function()
            require('lualine').setup {
                options = {
                  always_divide_middle = false,
                  globalstatus = false,
                  theme = "evangelion",
                  component_separators = { left = "", right = "" },
                  section_separators = { left = "░▒▓", right = "▓▒░" },
                },
                sections = {
                    lualine_a = {'mode'},
                    lualine_b = {'branch',
                      {
                        "diagnostics",
                        sources = { "nvim_diagnostic" },
                        symbols = { error = " ", warn = " ", info = " " },
                        diagnostics_color = {
                          error = { fg = "#151515" },
                          warn =  { fg = "#151515" },
                          info =  { fg = "#151515" },
                        },
                      },
                    },
                    lualine_c = {
                      { 'filename' },
                      { 'filetype' },
                      { 'diff' },
                      { 'searchcount' },
                      { 'progress' },
                      { 'location' },
                    },
                    lualine_x = {},
                    lualine_y = {},
                    lualine_z = {},
                },
                inactive_sections = {
                    lualine_a = {{ 'filename' }},
                    lualine_b = {},
                    lualine_c = {},
                    lualine_x = {},
                    lualine_y = {},
                    lualine_z = {{ 'location' }},
                },
                tabline = {},
                winbar = {},
                inactive_winbar = {},
                extensions = {}
            }
        end
    },
    { 'tpope/vim-fugitive',
        config = function()
            vim.keymap.set('n', ',gg', ':Git ', {})
        end
    },
    { 'sindrets/diffview.nvim',
        config = function()
          vim.keymap.set('n', ',gd', ':DiffviewOpen<CR>', {})
          vim.keymap.set('n', ',gh', ':DiffviewFileHistory<CR>', {})
        end
    },
    -- LLM
    { 'github/copilot.vim',
      config = function()
        vim.g.copilot_node_command = "/opt/homebrew/bin/node"
      end
    },
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
    { 'mfussenegger/nvim-jdtls' },
    { 'neovim/nvim-lspconfig' }, -- collection of configurations for built-in LSP client
    { 'saghen/blink.cmp',
      version = '1.*',
      opts = {
        -- All presets have the following mappings:
        -- C-space: Open menu or open docs if already open
        -- C-n/C-p or Up/Down: Select next/previous item
        -- C-e: Hide menu
        -- C-k: Toggle signature help (if signature.enabled = true)
        keymap = { preset = 'enter' },

        -- (Default) Only show the documentation popup when manually triggered
        completion = {
          documentation = {
            auto_show = true
          }
        },

        -- Default list of enabled providers defined so that you can extend it
        -- elsewhere in your config, without redefining it, due to `opts_extend`
        sources = {
          default = { 'lsp', 'path', 'snippets', 'buffer' },
        },

        fuzzy = { implementation = "prefer_rust_with_warning" }
      },
      opts_extend = { "sources.default" }
    },
    { 'mrcjkb/haskell-tools.nvim',
        version = '^3', -- Recommended
        ft = { 'haskell', 'lhaskell', 'cabal', 'cabalproject' },
    },
    { 'nvim-tree/nvim-tree.lua',
        config = function()
            local nvim_tree = require('nvim-tree')
            local api = require('nvim-tree.api')

            nvim_tree.setup({
                on_attach = function(bufnr)
                    local function opts(desc)
                      return {
                          desc = "nvim-tree: " .. desc,
                          buffer = bufnr,
                          noremap = true,
                          silent = true,
                          nowait = true
                      }
                    end

                    -- mappings inside nvim-tree
                    api.config.mappings.default_on_attach(bufnr)
                    vim.keymap.set("n", "<D-CR>", api.tree.change_root_to_node, opts("CD"))
                    vim.keymap.set("n", "?", api.tree.toggle_help, opts("Help"))
                end,
                update_focused_file = {
                  enable = true,
                },
                view = {
                  width = 60,
                },
                actions = {
                  open_file = {
                      quit_on_open = false,
                  }
                },
                filters = {
                  enable = true,
                  git_ignored = false,
                  dotfiles = true,
                  git_clean = false,
                  no_buffer = false,
                  no_bookmark = false,
                },
                git = {
                  enable = false,
                }
            })

            -- Open file in a current working directory
            vim.keymap.set('n', ',f', function()
                require('nvim-tree.api').tree.toggle({
                    path = vim.fn.getcwd(),
                    find_file = true,
                })
            end, {})

            -- Open file in the tree of the current git repository:
            -- Slower than the ',f' mapping
            vim.keymap.set('n', ',r', function()
                local gitroot = GetGitRoot()

                if gitroot then
                    rootdir = gitroot
                else
                    rootdir = vim.fn.getcwd()
                end

                require('nvim-tree.api').tree.toggle({
                    path = rootdir,
                    find_file = true,
                })
            end, {})
        end
    },
    { 'folke/trouble.nvim' }, -- Show diagnostics
    { 'nvim-mini/mini.clue',
      config = function()
        local miniclue = require('mini.clue')

        miniclue.setup({
          triggers = {
            { mode = 'n', keys = '<Leader>' },
            { mode = 'x', keys = '<Leader>' },
            { mode = 'n', keys = '[' },
            { mode = 'n', keys = ']' },
            { mode = 'i', keys = '<C-x>' },
            { mode = 'n', keys = 'g' },
            { mode = 'x', keys = 'g' },
            { mode = 'n', keys = "'" },
            { mode = 'n', keys = '`' },
            { mode = 'x', keys = "'" },
            { mode = 'x', keys = '`' },
            { mode = 'n', keys = '"' },
            { mode = 'x', keys = '"' },
            { mode = 'i', keys = '<C-r>' },
            { mode = 'c', keys = '<C-r>' },
            { mode = 'n', keys = '<C-w>' },
            { mode = 'n', keys = 'z' },
            { mode = 'x', keys = 'z' },
          },

          clues = {
            -- Enhance this by adding descriptions for <Leader> mapping groups
            miniclue.gen_clues.square_brackets(),
            miniclue.gen_clues.builtin_completion(),
            miniclue.gen_clues.g(),
            miniclue.gen_clues.marks(),
            miniclue.gen_clues.registers(),
            miniclue.gen_clues.windows(),
            miniclue.gen_clues.z(),
          },

          window = {
            delay = 0,
            config = {
              width = 'auto'
            }
          }
        })
      end,
    },
    { 'vhyrro/luarocks.nvim', priority = 1000, config = true },
    { 'ibhagwan/fzf-lua',
      dependencies = { 'nvim-tree/nvim-web-devicons' },
      config = function()
        local fzf_lua = require('fzf-lua')
        local actions = require('fzf-lua.actions')
        local utils = require('fzf-lua.utils')

        fzf_lua.setup({
            keymap = {
                builtin = {
                    ['<D-p>'] = 'toggle-preview',
                },
            },
            winopts = {
                border = 'thicc',
                preview = {
                    layout = 'vertical',
                    vertical = 'down:40%',
                },
            },
            files = {
                formatter = "path.filename_first",
            },
            oldfiles = {
                prompt = 'OldFiles❯ ',
                formatter = "path.filename_first",
            },
            git = {
                files = {
                    prompt = 'GitFiles❯ ',
                    color_icons = true,
                    formatter = "path.filename_first",
                },
            },
            grep = {
              rg_glob_fn = function(query, opts)
                local regex, flags = query:match("^(.-)%s%-%-(.*)$")
                return (regex or query), flags
              end
            },
            buffers = {
                prompt = 'Buffers❯ ',
                formatter = "path.filename_first",
                file_icons = true,
                actions = default_file_actions,
                ignore_current_buffer = true,
                no_term_buffers = false,
            },
            fzf_colors = true,
        })

        local git_grep = function(should_resume)
          fzf_lua.live_grep({
            cmd = "git grep --line-number --column --color=always",
            prompt = 'GitGrep❯ ',
            fn_transform_cmd = function(query, cmd, _)
              local new_cmd = string.format("%s %s", cmd, query)
              return new_cmd, search_query
            end,
            cwd = vim.loop.cwd(),
            resume = should_resume
          })
        end

        local rip_grep = function(should_resume)
          fzf_lua.live_grep({
            prompt = 'RipGrep❯ ',
            multiprocess = true,
            cwd = vim.loop.cwd(),
            resume = should_resume
          })
        end

        local terminal_buffers = function()
          fzf_lua.buffers({
            filter = IsTermBuffer,
            prompt = 'Terminals❯ ',
            ignore_current_buffer = true,
            no_term_buffers = false,
            filter = utils.is_term_buffer,
          })
        end

        vim.keymap.set('n', '<D-l>', fzf_lua.buffers, {})
        vim.keymap.set('n', '<D-k>', terminal_buffers, {})
        vim.keymap.set('n', '<D-;>', fzf_lua.lsp_finder, {})
        vim.keymap.set('n', '<D-f>', fzf_lua.git_files, {})
        vim.keymap.set('n', '<D-d>', fzf_lua.oldfiles, {})
        vim.keymap.set('n', '<D-s>', fzf_lua.files, {})
        vim.keymap.set('n', '<D-a>', fzf_lua.lsp_live_workspace_symbols, {})
        vim.keymap.set('n', '<D-g>', function() git_grep(false) end, {})
        vim.keymap.set('n', '<D-C-g>', function() git_grep(true) end, {})
        vim.keymap.set('n', '<D-\\>', function() rip_grep(false) end, {})
        vim.keymap.set('n', '<D-C-\\>', function() rip_grep(true) end, {})

        vim.api.nvim_create_user_command('Diag', fzf_lua.diagnostics_document, {})
        vim.api.nvim_create_user_command('DiagAll', fzf_lua.diagnostics_workspace, {})

      end
    },
    { 'jmckiern/vim-venter',
        config = function()
            vim.keymap.set('n', '<space>v', ':VenterToggle<CR>')
        end,
    },
    { 'Konfekt/vim-alias',
        config = function()
            local a = vim.api.nvim_create_augroup('VimAlias', { clear = true })

            vim.api.nvim_create_autocmd('VimEnter', { group = a, command = 'Alias man Man' })
            vim.api.nvim_create_autocmd('VimEnter', { group = a, command = 'Alias ren Rename' })
            vim.api.nvim_create_autocmd('VimEnter', { group = a, command = 'Alias rm Delete' })
            vim.api.nvim_create_autocmd('VimEnter', { group = a, command = 'Alias bclose Bclose' })
            vim.api.nvim_create_autocmd('VimEnter', { group = a, command = 'Alias fzf FzfLua' })
        end,
    },
    { 'nvzone/typr',
      dependencies = "nvzone/volt",
      opts = {},
      cmd = { "Typr", "TyprStats" },
    }
})

---------------
--> LSP configuration
---------------
-- grr: vim.lsp.buf.references
-- gri: vim.lsp.buf.implementation
-- grn: vim.lsp.buf.rename
-- gO: vim.lsp.buf.document_symbol
-- <C-S>: vim.lsp.buf.signature_help
vim.keymap.set('n', 'grd', vim.lsp.buf.definition, {})
vim.keymap.set('n', 'grf', vim.lsp.buf.format, {})

vim.diagnostic.config({ virtual_text = true })

vim.lsp.config("jdtls", {
  settings = {
    java = {
      configuration = {
        runtimes = {
          {
            name = "JavaSE-11",
            path = vim.env.JAVA_11_HOME,
          },
          {
            name = "JavaSE-17",
            path = vim.env.JAVA_17_HOME,
          },
          {
            name = "JavaSE-21",
            path = vim.env.JAVA_21_HOME,
          }
        }
      }
    }
  }
})

vim.lsp.config["tinymist"] = {
    settings = {
      formatterMode = "typstyle"
    }
}

-- Enable LSP servers
for _, server in ipairs({
  'basedpyright',
  'ts_ls',
  'rust_analyzer',
  'gopls',
  'clangd',
  'html',
  'cssls',
  'bashls',
  'lua_ls',
  'jdtls',
  'tinymist'
}) do
  vim.lsp.enable(server)
end
