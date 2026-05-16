# Ubuntu Server Setup

This setup is meant for console-only environments such as Ubuntu Server VMs in Proxmox.

It installs and links the terminal-focused subset of this repo:

- Bash config
- `tmux`
- `inputrc`
- Neovim

Recommended installer:

```sh
./install-server.sh
```

## What it installs

Base packages:

- `git`
- `neovim`
- `tmux`
- `ripgrep`
- `fd-find`
- `make`
- `curl`
- `xz-utils`
- `gawk`
- `bash-completion`
- `build-essential`
- `ca-certificates`
- `unzip`

It also tries to install, if available in the distro repositories:

- `starship`
- `zoxide`

Shell extras installed outside apt:

- `bash-it`
- `ble.sh`

Neovim note:

- Ubuntu server repositories often ship an older `nvim`
- this config needs a modern Neovim release
- `install-server.sh` now installs upstream Neovim into `~/.local/bin/nvim` when the distro package is too old

## What it links

```sh
~/.bashrc
~/.bash_profile
~/.profile
~/.inputrc
~/.tmux.conf
~/.config/nvim
```

## Why this subset

For server consoles, the most useful additions beyond Bash and Neovim are:

- `tmux`: persistent shell sessions
- `.inputrc`: faster history search in plain console shells
- `ripgrep` and `fd`: useful both directly and from Neovim

This installer intentionally does not install or link:

- `kitty`
- Hyprland config

## After install

```sh
tmux kill-server
```

Then open a new shell and start Neovim once:

```sh
nvim
```

Inside Neovim run:

```vim
:Lazy sync
```
