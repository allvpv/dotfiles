-------------------
--> Basic setup
-------------------
vim.opt.mouse = 'a'         -- Enable mouse in every mode (always)
vim.opt.number = true       -- Display line numbers
vim.opt.hidden = true       -- Do not destroy hidden buffer
vim.opt.scrolloff = 4       -- Minimal number of screen lines to keep above and below the cursor
vim.opt.history = 10000     -- Sets how many lines of history NeoVim has to remember
vim.opt.autoread = true     -- Set to auto read when a file is changed from the outside
vim.opt.numberwidth = 5     -- Thicc number bar
vim.opt.autochdir = true    -- Automatically change working directory to current file directory
vim.opt.updatetime = 300    -- Default is 4000ms = 4s = poor user experience with some plugins
vim.opt.lazyredraw = true   -- Don't redraw while executing macros (good performance config)
vim.opt.signcolumn = 'yes'  -- Prevent shifting the text each time diagnostics appear
vim.opt.colorcolumn = '100' -- Vertical line pass the 99 column limit

vim.opt.tabstop = 2         -- Number of spaces that a <Tab> in the file counts for
vim.opt.shiftwidth = 2      -- Number of spaces for each indent
vim.opt.expandtab = true    -- Use spaces instead of tabs

vim.opt.autoindent = true   -- Indent automatically
vim.opt.smartindent = true  -- Indent language sensitive
vim.opt.foldenable = false  -- Disable indent folding

vim.opt.wrap = false        -- Don't use soft wrapping
vim.opt.textwidth = 0       -- Don't insert hard breaks on specific character stop
vim.opt.wrapmargin = 0      -- Don't know really
vim.opt.linebreak = false   -- Don't break lines automatically

vim.opt.backup = false      -- Turn off backup feature
vim.opt.swapfile = false    -- File will not be swapped and will reside in memory
vim.opt.writebackup = false -- Turn off additional backuping on every write

vim.opt.hlsearch = true     -- Highlight search results
vim.opt.incsearch = true    -- Search dynamically while typing
vim.opt.smartcase = true    -- Case-insensitive search when pattern is lowercase

vim.opt.errorbells = false  -- No annoying sound on errors
vim.opt.visualbell = false  -- No annoying visual signal on erros

vim.opt.splitbelow = true   -- Split new window below actual by default
vim.opt.equalalways = true  -- Resize windows equally when layout changes

vim.opt.wildmenu = true     -- Turn on the WiLd menu
vim.opt.wildmode = 'full'   -- Turn on all features of the WiLd menu
vim.opt.wildignore = {      -- Ignore generated files
    '*.o', '*~', '*.pyc', '*/.git/*', '*/.hg/*', '*/.svn/*', '*/.DS_Store'
};

vim.opt.termguicolors = true  -- Enable truecolor palette in `tmux`
vim.opt.inccommand = 'split'  -- Preview of differences in search and replace (%s)
vim.opt.shortmess:append('c') -- Don't pass messages to |ins-completion-menu|.
vim.opt.clipboard:prepend('unnamedplus')    -- Synchronize clipboard with default register

-- Use Neovide as the clipboard provider.
--
-- This is not the best solution: i.e.: it should detect that the Neovide is
-- running as a front-end before attemting to use it as a clipboard provider.
-- *But* the remote mode is going to be revamped in the coming Neovim release,
-- thus I'm not willing to invest my time into that.
local function neovide_rpc(method, ...)
  return vim.rpcrequest(vim.g.neovide_channel_id, method, ...)
end

local function neovide_copy(lines)
  return neovide_rpc("neovide.set_clipboard", lines)
end

local function neovide_paste()
  return neovide_rpc("neovide.get_clipboard")
end

vim.g.clipboard = {
    name = "neovide",
    copy = {
        ["+"] = neovide_copy,
        ["*"] = neovide_copy,
    },
    paste = {
        ["+"] = neovide_paste,
        ["*"] = neovide_paste,
    },
    cache_enabled = 0,
}


-- By default, Vim’s backspace option is set to an empty list.
vim.opt.backspace = {
    'eol',   -- backspace over indentation
    'start', -- backspace over an end of line
    'indent' -- backspace past the position where you started Insert mode
}

-- By default, when pressing h/l or cursor keys, Vim won't move to the previous/next line
vim.opt.whichwrap =
    '<,>'.. -- cursor keys used in normal and visual mode
    '[,]'.. -- cursor keys used in insert mode
    'h,l'

-- Disable legacy builtin plugins
local disabled_built_ins = {
    '2html_plugin', 'getscript', 'getscriptPlugin', 'gzip', 'logipat', 'netrw', 'netrwPlugin',
    'netrwSettings', 'netrwFileHandlers', 'matchit', 'tar', 'tarPlugin', 'rrhelper',
    'spellfile_plugin', 'vimball', 'vimballPlugin', 'zip', 'zipPlugin', 'tutor', 'rplugin',
    'synmenu', 'optwin', 'compiler', 'bugreport',
}

for _, plugin in ipairs(disabled_built_ins) do
    vim.g["loaded_" .. plugin] = 1
end

-- Path to `python3` executable on MacOS
if vim.loop.os_uname().sysname == "Darwin" then
  vim.g.python3_host_prog = '/opt/homebrew/bin/python3'
end
