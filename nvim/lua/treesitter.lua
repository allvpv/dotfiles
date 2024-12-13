---------------
--> TreeSitter
---------------

require('nvim-treesitter.configs').setup {
  ---- Ensure all parsers are downloaded and compiled ahead. A list of parser
  ---- names, or "all". Installing all the parsers eats up about ~200MB of disk
  ---- space. (Or you can `:TS[Sync]Install all` in Ex mode).
  -- ensure_installed = "all",

  -- Install parsers synchronously (applies to `ensure_installed`).
  sync_install = true,

  -- Automatically install missing parsers when entering buffer. Set to false
  -- if you don't have `tree-sitter` CLI installed locally. Consider setting to
  -- true if ensure_installed != "all".
  auto_install = true,

  highlight = {
    enable = true,
    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
}
