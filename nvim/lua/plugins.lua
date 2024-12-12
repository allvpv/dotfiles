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

local function gitroot()
    local handle = io.popen('git rev-parse --show-toplevel')
    local result = handle:read("*a"):gsub("\n", "")
    handle:close()

    if #result ~= 0 then
        return result
    else
        return nil
    end
end

require('lazy').setup({
    -- The default is unlimited, causing problems on constraint environments
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
        end
    },
    { 'tpope/vim-fugitive',
        config = function()
            vim.keymap.set('n', ',g', ':Git ', {})
        end
    },
    { 'sindrets/diffview.nvim',
        config = function()
            vim.keymap.set('n', ',d', ':DiffviewOpen<CR>', {})
            vim.keymap.set('n', ',c', ':tabclose<CR>', {})
        end
    },
     -- LLM
    { 'github/copilot.vim' },
    { 'yetone/avante.nvim',
      event = 'VeryLazy',
      lazy = false,
      version = false,
      opts = {
          -- debug = false,
          provider = "copilot",
          auto_suggestions_provider = "copilot",
          system_prompt = [[
Behave as if you're assisting a top-tier software developer. Prioritize using
the libraries, conventions, and patterns already present in the codebase. Avoid
writing overly verbose code. Keep your code concise, and add brief comments
when necessary.
]],
          copilot = {
            endpoint = "https://api.githubcopilot.com",
            model = "gpt-4",
            allow_insecure = false,
            timeout = 60000,
            temperature = 0,
            max_tokens = 4096,
          },
          behaviour = {
            auto_suggestions = true,
            auto_apply_diff_after_generation = false,
          },
          history = {
            storage_path = vim.fn.stdpath("state") .. "/avante",
          },
          highlights = {
            diff = {
              current = "DiffText",
              incoming = "DiffAdd",
            },
          },
          windows = {
            position = "right",
            wrap = true, -- similar to vim.o.wrap
            width = 30, -- default % based on available width in vertical layout
            height = 30, -- default % based on available height in horizontal layout
            sidebar_header = {
              align = "center", -- left, center, right for title
              rounded = true,
            },
            input = {
              prefix = "> ",
            },
            edit = {
              border = "rounded",
            },
          },
          diff = {
            autojump = true,
          },
          hints = {
            enabled = true,
          },
      },
      build = "make",
      dependencies = {
        'nvim-treesitter/nvim-treesitter',
        'stevearc/dressing.nvim',
        'nvim-lua/plenary.nvim',
        'MunifTanjim/nui.nvim',
        'github/copilot.vim',
        { 'MeanderingProgrammer/render-markdown.nvim',
          opts = {
            file_types = { "markdown", "Avante" },
          },
          ft = { "markdown", "Avante" },
        },
      },
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
    { 'nvim-java/nvim-java' }, -- Eclipse JDT <==> LSP bridge
    --- collection of configurations for built-in LSP client
    { 'neovim/nvim-lspconfig', dependencies = 'nvim-java/nvim-java' },
    { 'hrsh7th/nvim-cmp' }, -- Autocompletion plugin
    { 'hrsh7th/cmp-nvim-lsp' }, -- LSP source for nvim-cmp
    { 'simrat39/rust-tools.nvim',  -- Adds extra functionality over rust-analyzer
        config = function()
            require('rust-tools').setup {
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
                  width = 80,
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
            vim.keymap.set('n', ',f', ':NvimTreeToggle<CR>', {})

            -- Open file in the tree of the current git repository:
            -- Slower than the ',f' mapping
            vim.keymap.set('n', ',r', function()
                local gitroot = gitroot()

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
    { 'vhyrro/luarocks.nvim', priority = 1000, config = true },
    { "ibhagwan/fzf-lua",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      config = function()
        local actions = require("fzf-lua.actions")
        local fzf_lua = require("fzf-lua")

        fzf_lua.setup({
            keymap = {
                builtin = {
                    ["<D-p>"] = "toggle-preview",
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
                cmd =  [[ gfind . -type f -not -path '*/\.git/*' -printf '%P\n' ]],
                actions = {
                  ["ctrl-g"] = false,
                },
                formatter = "path.filename_first",
            },
            oldfiles = {
                formatter = "path.filename_first",
            },
            git = {
                files = {
                    color_icons = true,
                    formatter = "path.filename_first",
                },
            },
            buffers = {
                actions = {
                  ["ctrl-x"] = false,
                  -- ["<D-c>"] = { fn = actions.buf_del, reload = true },
                },
            },
            fzf_colors = true,
        })

        local git_grep = function(suffix)
            local command = "git grep --color=always -n <query>" .. suffix

            fzf_lua.fzf_live(
              command,
              {
                fzf_opts = {
                  ['--delimiter'] = ':',
                },
                actions = fzf_lua.defaults.actions.files,
                git_icons = false,
                file_icons = true,
                color_icons = true,
                previewer = 'builtin',
                fn_transform = function(x)
                    return fzf_lua.make_entry.file(x, opts)
                end,
                cwd = vim.loop.cwd(),
              }
            )
        end

        vim.keymap.set('n', '<D-l>', fzf_lua.buffers, {})
        vim.keymap.set('n', '<D-;>', fzf_lua.lsp_finder, {})
        vim.keymap.set('n', '<D-f>', fzf_lua.git_files, {})
        vim.keymap.set('n', '<D-d>', fzf_lua.oldfiles, {})
        vim.keymap.set('n', '<D-s>', fzf_lua.files, {})
        vim.keymap.set('n', '<D-g>', function() git_grep("") end, {})
        vim.keymap.set('n', '<D-t>', function() git_grep(" :/") end, {})

      end
    },
    { 'jmckiern/vim-venter',
        config = function()
            vim.keymap.set('n', '<space>v', ':VenterToggle<CR>')
        end,
    },
    { 'pacha/vem-tabline',
        config = function()
            -- Don't close a window when deleting a buffer.
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
            vim.api.nvim_create_autocmd('VimEnter', { group = a, command = 'Alias fzf FzfLua' })
        end,
    },
})

local function GetJavaRuntimes()
    local runtimes = {}

    for line in io.popen("set"):lines() do
      javaNum, javaPath = line:match("^JAVA_([\\d]+)_HOME=(.*)")

      if envName then
          runtimes[#runtimes + 1] = {
              name = "Java " .. javaNum,
              path = javaPath,
              default = false,
          }
      end
    end


    defaultJavaPath = os.getenv("JAVA_HOME")

    if defaultJavaPath then
        runtimes[#runtimes + 1] = {
            name = "Java (default)",
            path = defaultJavaPath,
            default = true,
        }
    end

    return runtimes
end

local function SetupLsp()
    local nvim_java = require('java')

    nvim_java.setup({
      root_markers = {
        'settings.gradle',
        'settings.gradle.kts',
        'pom.xml',
        'build.gradle',
        'mvnw',
        'gradlew',
        'build.gradle',
        'build.gradle.kts',
        '.git',
      },
      java_test = {
        enable = true,
      },
      java_debug_adapter = {
        enable = true,
      },
      spring_boot_tools = {
        enable = true,
      },
      jdk = {
        auto_install = false,
      },
      notifications = {
        dap = true,
      },
      verification = {
        invalid_order = true,
        duplicate_setup_calls = true,
        invalid_mason_registry = true,
      },
    })

    local capabilities = require('cmp_nvim_lsp').default_capabilities()
    local lspconfig = require('lspconfig')
    local cmp = require('cmp')

    -- Add additional capabilities supported by nvim-cmp
    for _, lsp in ipairs({'clangd', 'rust_analyzer', 'pyright', 'ts_ls'}) do
        lspconfig[lsp].setup {
            capabilities = capabilities,
        }
    end

    lspconfig.jdtls.setup({
        settings = {
            java = {
                configuration = {
                    runtimes = GetJavaRuntimes(),
                }
            }
        }
    })

    cmp.setup {
        mapping = cmp.mapping.preset.insert({
            ['<C-d>'] = cmp.mapping.scroll_docs(-4),
            ['<C-f>'] = cmp.mapping.scroll_docs(4),
            ['<C-Space>'] = cmp.mapping.complete(),
            ['<CR>'] = cmp.mapping.confirm {
                behavior = cmp.ConfirmBehavior.Replace,
                select = true,
            }
        }),
        sources = {
            { name = 'nvim_lsp' },
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
