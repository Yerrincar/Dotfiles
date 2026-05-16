#!/usr/bin/env bash

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SKIP_PACKAGES=0
SKIP_LINKS=0
SKIP_SHELL_TOOLS=0

log() {
  printf '[dotfiles-server] %s\n' "$*"
}

warn() {
  printf '[dotfiles-server] warning: %s\n' "$*" >&2
}

die() {
  printf '[dotfiles-server] error: %s\n' "$*" >&2
  exit 1
}

have() {
  command -v "$1" >/dev/null 2>&1
}

need_sudo() {
  if [[ ${EUID} -eq 0 ]]; then
    printf ''
  elif have sudo; then
    printf 'sudo '
  else
    die 'This step requires root privileges and sudo is not available.'
  fi
}

backup_target() {
  local target="$1"
  local backup

  backup="${target}.backup.$(date +%Y%m%d%H%M%S)"
  mv "$target" "$backup"
  log "Backed up $target to $backup"
}

link_path() {
  local source="$1"
  local target="$2"
  local current

  mkdir -p "$(dirname "$target")"

  if [[ -L "$target" ]]; then
    current="$(readlink "$target")"
    if [[ "$current" == "$source" ]]; then
      log "Link already exists: $target"
      return
    fi
    backup_target "$target"
  elif [[ -e "$target" ]]; then
    backup_target "$target"
  fi

  ln -sfn "$source" "$target"
  log "Linked $target -> $source"
}

apt_install_packages() {
  local sudo_cmd pkg status=0

  sudo_cmd="$(need_sudo)"
  ${sudo_cmd}apt-get update

  for pkg in "$@"; do
    if dpkg -s "$pkg" >/dev/null 2>&1; then
      log "Already installed: $pkg"
      continue
    fi

    log "Installing $pkg"
    if ! ${sudo_cmd}apt-get install -y "$pkg"; then
      warn "Could not install $pkg"
      status=1
    fi
  done

  return $status
}

install_packages() {
  have apt-get || die 'install-server.sh currently supports Ubuntu/Debian systems with apt-get.'

  apt_install_packages \
    git neovim tmux ripgrep fd-find make curl xz-utils gawk bash-completion \
    build-essential ca-certificates unzip || true

  apt_install_packages starship zoxide || true

  mkdir -p "$HOME/.local/bin"
  if ! have fd && have fdfind && [[ ! -e "$HOME/.local/bin/fd" ]]; then
    ln -s "$(command -v fdfind)" "$HOME/.local/bin/fd"
    log 'Linked ~/.local/bin/fd to fdfind'
  fi
}

install_shell_tools() {
  local temp_config temp_dir archive_url

  if [[ -d "$HOME/.bash_it/.git" ]]; then
    log 'Updating bash-it'
    git -C "$HOME/.bash_it" pull --ff-only || warn 'Could not update bash-it'
  elif [[ -d "$HOME/.bash_it" ]]; then
    warn '~/.bash_it exists but is not a git checkout. Leaving it untouched.'
  else
    log 'Installing bash-it'
    git clone --depth=1 https://github.com/Bash-it/bash-it.git "$HOME/.bash_it"
  fi

  if [[ -x "$HOME/.bash_it/install.sh" ]]; then
    temp_config="$(mktemp)"
    BASH_IT_CONFIG_FILE="$temp_config" "$HOME/.bash_it/install.sh" --silent >/dev/null 2>&1 || true
    rm -f "$temp_config"
  fi

  log 'Installing ble.sh'
  temp_dir="$(mktemp -d)"
  archive_url='https://github.com/akinomyoga/ble.sh/releases/download/nightly/ble-nightly.tar.xz'
  curl -fsSL "$archive_url" -o "$temp_dir/ble-nightly.tar.xz"
  tar xJf "$temp_dir/ble-nightly.tar.xz" -C "$temp_dir"
  bash "$temp_dir/ble-nightly/ble.sh" --install "$HOME/.local/share"
  rm -rf "$temp_dir"
}

link_configs() {
  mkdir -p "$HOME/.config"

  link_path "$REPO_DIR/nvim" "$HOME/.config/nvim"
  link_path "$REPO_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"
  link_path "$REPO_DIR/.bashrc" "$HOME/.bashrc"
  link_path "$REPO_DIR/.bash_profile" "$HOME/.bash_profile"
  link_path "$REPO_DIR/.profile" "$HOME/.profile"
  link_path "$REPO_DIR/.inputrc" "$HOME/.inputrc"
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --skip-packages)
        SKIP_PACKAGES=1
        ;;
      --skip-links)
        SKIP_LINKS=1
        ;;
      --skip-shell-tools)
        SKIP_SHELL_TOOLS=1
        ;;
      -h|--help)
        cat <<'EOF'
Usage: ./install-server.sh [options]

Options:
  --skip-packages      Do not install apt packages
  --skip-links         Do not create/update symlinks
  --skip-shell-tools   Do not install bash-it or ble.sh
  -h, --help           Show this help
EOF
        exit 0
        ;;
      *)
        die "Unknown option: $1"
        ;;
    esac
    shift
  done
}

main() {
  parse_args "$@"

  if [[ $SKIP_PACKAGES -eq 0 ]]; then
    install_packages
  fi

  if [[ $SKIP_SHELL_TOOLS -eq 0 ]]; then
    install_shell_tools
  fi

  if [[ $SKIP_LINKS -eq 0 ]]; then
    link_configs
  fi

  log 'Installation finished.'
  log 'Recommended next steps:'
  log '  1. Run: tmux kill-server'
  log '  2. Open a new shell'
  log '  3. Open nvim and run :Lazy sync'
}

main "$@"
