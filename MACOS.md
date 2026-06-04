# macOS Setup

This guide installs the tools needed for the configs in this repo and links the config files into the standard macOS locations.

Preferred setup:

```sh
./install.sh
```

The rest of this file explains the same pieces manually.

## 1. Install Xcode Command Line Tools

```sh
xcode-select --install
```

## 2. Install Homebrew

If you do not already have it:

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## 3. Install the main tools

```sh
brew install git neovim tmux ripgrep fd make
brew install --cask ghostty
```

If Homebrew tells you to add shell integration, do it. On Apple Silicon this is usually:

```sh
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
eval "$(/opt/homebrew/bin/brew shellenv)"
```

On Intel Macs it is usually:

```sh
echo 'eval "$(/usr/local/bin/brew shellenv)"' >> "$HOME/.zprofile"
eval "$(/usr/local/bin/brew shellenv)"
```

Optional but useful:

```sh
brew install terraform helm
brew install starship zoxide
brew install bash bash-completion@2
brew install --cask font-fira-code
```

Install the extra Bash tools expected by `.bashrc`:

```sh
git clone https://github.com/Bash-it/bash-it.git "$HOME/.bash_it"
"$HOME/.bash_it/install.sh" --silent
curl -L https://github.com/akinomyoga/ble.sh/releases/download/nightly/ble-nightly.tar.xz \
  | tar xJf - -C /tmp
bash /tmp/ble-nightly/ble.sh --install ~/.local/share
```

Notes for these shell tools:

- `bash-it` is loaded from `~/.bash_it/bash_it.sh`
- `ble.sh` is loaded from `~/.local/share/blesh/ble.sh`
- if `~/.bashrc` is symlinked to this repo, do not let installers append lines to it manually afterward; this repo already contains the `ble.sh` sourcing logic
- Homebrew `bash` plus `bash-completion@2` is recommended if you want better Bash completion support on macOS than the system `/bin/bash`
- the macOS Ghostty/tmux config in this repo is set up to use Homebrew Bash when available
- `install.sh` writes a local Ghostty override to `~/.config/ghostty-local/config` so the machine-specific shell path does not modify the repo-managed config tree

Notes:

- `ripgrep`, `fd`, and `make` are needed by the Neovim setup
- `terraform` is useful because the config uses `terraform_fmt`
- `helm` is useful if you want the full Helm workflow
- `starship` and `zoxide` are used by `.bashrc`
- `bash-it` and `ble.sh` are also used by `.bashrc`
- Ghostty is configured with `font-family = Fira Code`, so install that font if you want the same look
- the Bash files in this repo also bootstrap the Homebrew path for Bash shells opened from Ghostty

## 4. Clone the dotfiles repo

```sh
mkdir -p "$HOME/Projects"
git clone <your-repo-url> "$HOME/Projects/Dotfiles"
```

## 5. Link the configs

```sh
mkdir -p "$HOME/.config"
ln -sfn "$HOME/Projects/Dotfiles/nvim" "$HOME/.config/nvim"
ln -sfn "$HOME/Projects/Dotfiles/ghostty" "$HOME/.config/ghostty"
ln -sfn "$HOME/Projects/Dotfiles/tmux/.tmux.conf" "$HOME/.tmux.conf"
ln -sfn "$HOME/Projects/Dotfiles/.bashrc" "$HOME/.bashrc"
ln -sfn "$HOME/Projects/Dotfiles/.bash_profile" "$HOME/.bash_profile"
ln -sfn "$HOME/Projects/Dotfiles/.profile" "$HOME/.profile"
ln -sfn "$HOME/Projects/Dotfiles/.inputrc" "$HOME/.inputrc"
```

Create the local Ghostty override for Homebrew Bash:

```sh
mkdir -p "$HOME/.config/ghostty-local"
if [ -x /opt/homebrew/bin/bash ]; then
  printf 'command = /opt/homebrew/bin/bash --login\n' > "$HOME/.config/ghostty-local/config"
elif [ -x /usr/local/bin/bash ]; then
  printf 'command = /usr/local/bin/bash --login\n' > "$HOME/.config/ghostty-local/config"
else
  printf 'command = /bin/bash --login\n' > "$HOME/.config/ghostty-local/config"
fi
```

## 6. Start Neovim once

Open Neovim:

```sh
nvim
```

Then run:

```vim
:Lazy sync
```

This will install/update the plugins.

Your config also uses Mason, so language servers and external tools will install from inside Neovim.

## 7. macOS terminal note for Ctrl-S / Ctrl-Q

Terminal apps on Unix-like systems can intercept `<C-s>` and `<C-q>` for flow control.

Quick check:

```sh
stty -a | grep ixon
```

Disable it for the current shell session:

```sh
stty -ixon
```

Persist it in `zsh`:

```sh
echo 'stty -ixon' >> "$HOME/.zshrc"
```

## 8. Notes about these configs

- Ghostty reads `~/.config/ghostty/config`, which is symlinked to this repo
- `tmux` auto-selects clipboard integration using `pbcopy` on macOS
- Ghostty launches Homebrew Bash on macOS via `~/.config/ghostty-local/config`
- `tmux` panes also prefer Homebrew Bash on macOS
- `.bashrc` auto-attaches to tmux when opening an interactive shell and `tmux` is installed
- `.bashrc` is now guarded so optional tools such as `bash-it`, `ble.sh`, `starship`, and `zoxide` do not break startup if they are missing
- the Neovim config is already adapted for macOS-only fallbacks where needed

## 9. Recommended first checks

```sh
nvim --version
tmux -V
ghostty --version
```

Inside Neovim you can also run:

```vim
:checkhealth
:Mason
```
