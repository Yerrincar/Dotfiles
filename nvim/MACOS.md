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
