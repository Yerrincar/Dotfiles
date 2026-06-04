# macOS notes

This config is portable to macOS as-is.

Recommended bootstrap:

```sh
xcode-select --install
brew install neovim ripgrep fd git make
```

Tooling notes:

- `telescope-fzf-native.nvim` builds with `make`
- `LuaSnip` regex support builds with `make install_jsregexp`
- Treesitter parsers build/update locally
- `fff.nvim` downloads a prebuilt binary or falls back to a local build
- `terraform_fmt` expects the `terraform` CLI if you use Terraform files

Terminal note:

- Some macOS terminal setups intercept `<C-s>` and `<C-q>` for flow control
- This config adds macOS-only fallbacks: `<leader>w`, `<leader>W`, and `<leader>Q`
- This is usually a shell/TTY setting, not something specific to Terminal.app
- Quick check: `stty -a | grep ixon`
- Fix for the current shell session: `stty -ixon`
- To keep that change across sessions, add `stty -ixon` to `~/.zshrc`

Treesitter parser mismatch:

- If opening Lua/Vim help files fails with `Invalid field name "operator"`, remove stale parsers that override Neovim's bundled parsers
- From Neovim, run `:TSUninstall lua vim vimdoc query markdown markdown_inline`, then `:Lazy sync`
- If Neovim cannot open far enough to run commands, use `rm -f ~/.local/share/nvim/lazy/nvim-treesitter/parser/{lua,vim,vimdoc,query,markdown,markdown_inline}.so`, then start Neovim and run `:Lazy sync`
