return { -- Highlight, edit, and navigate code
  'nvim-treesitter/nvim-treesitter',
  branch = 'master',
  lazy = false,
  main = 'nvim-treesitter.configs',
  cmd = { 'TSInstall', 'TSUpdate', 'TSUpdateSync', 'TSInstallInfo' },
  build = ':TSUpdate',
  -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
  opts = {
    ensure_installed = {
      'python',
      'javascript',
      'typescript',
      'regex',
      'terraform',
      'sql',
      'dockerfile',
      'toml',
      'json',
      'java',
      'groovy',
      'go',
      'gitignore',
      'graphql',
      'helm',
      'yaml',
      'make',
      'cmake',
      'bash',
      'tsx',
      'css',
      'html',
    },
    -- Neovim bundles these parsers and runtime queries. Installing stale copies
    -- through nvim-treesitter can override the bundled parser and crash on macOS.
    ignore_install = { 'lua', 'vim', 'vimdoc', 'query', 'markdown', 'markdown_inline' },
    -- Autoinstall languages that are not installed
    auto_install = true,
    highlight = {
      enable = true,
      -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
      --  If you are experiencing weird indenting issues, add the language to
      --  the list of additional_vim_regex_highlighting and disabled languages for indent.
      additional_vim_regex_highlighting = { 'ruby' },
    },
    indent = { enable = true, disable = { 'ruby' } },
  },
  -- There are additional nvim-treesitter modules that you can use to interact
  -- with nvim-treesitter. You should go explore a few and see what interests you:
  --
  --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
  --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
  --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
}
