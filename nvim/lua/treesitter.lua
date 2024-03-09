---------------
--> TreeSitter
---------------

require('nvim-treesitter.configs').setup {
  -- Ensure all parses are downloaded and compiled ahead. A list of parser
  -- names, or "all". Installing all the parses eats up about ~200Mb of the
  -- disk space. (Alternatively, you can `:TS[Sync]Install all` from ex line).
  -- ensure_installed = "all",
  --
  -- Automatically install missing parsers when entering buffer. Set to false
  -- if you don't have `tree-sitter` CLI installed locally. Consider setting to
  -- true if ensure_installed != "all".
  auto_install = true,
  -- Install parsers synchronously (only applied to `ensure_installed`).
  sync_install = true,

  highlight = {
    enable = true,
    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
}
