#!/usr/bin/env bash

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log() {
    printf '[dotfiles-macos-userbrew] %s\n' "$*"
}

die() {
    printf '[dotfiles-macos-userbrew] error: %s\n' "$*" >&2
    exit 1
}

have() {
    command -v "$1" >/dev/null 2>&1
}

brew_bin() {
    if have brew; then
        command -v brew
        return 0
    fi

    if [[ -x "$HOME/.homebrew/bin/brew" ]]; then
        printf '%s\n' "$HOME/.homebrew/bin/brew"
        return 0
    fi

    if [[ -x /opt/homebrew/bin/brew ]]; then
        printf '%s\n' /opt/homebrew/bin/brew
        return 0
    fi

    if [[ -x /usr/local/bin/brew ]]; then
        printf '%s\n' /usr/local/bin/brew
        return 0
    fi

    return 1
}

ensure_line() {
    local line="$1"
    local file="$2"

    touch "$file"
    if ! grep -Fqx "$line" "$file"; then
        printf '%s\n' "$line" >>"$file"
    fi
}

backup_target() {
    local target="$1"
    local backup="${target}.backup.$(date +%Y%m%d%H%M%S)"
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

setup_brew_shellenv() {
    local brew_path brew_prefix
    brew_path="$(brew_bin)" || die "brew not found. Put it in PATH or install it at ~/.homebrew/bin/brew"

    eval "$("$brew_path" shellenv)"
    brew_prefix="$("$brew_path" --prefix)"

    if [[ "$brew_prefix" == "$HOME/.homebrew" ]]; then
        ensure_line 'eval "$($HOME/.homebrew/bin/brew shellenv)"' "$HOME/.zprofile"
    elif [[ "$brew_prefix" == "/opt/homebrew" ]]; then
        ensure_line 'eval "$(/opt/homebrew/bin/brew shellenv)"' "$HOME/.zprofile"
    elif [[ "$brew_prefix" == "/usr/local" ]]; then
        ensure_line 'eval "$(/usr/local/bin/brew shellenv)"' "$HOME/.zprofile"
    fi
}

brew_install_formulae() {
    local brew_path pkg
    brew_path="$(brew_bin)"

    for pkg in "$@"; do
        if "$brew_path" list "$pkg" >/dev/null 2>&1; then
            log "Already installed: $pkg"
            continue
        fi

        log "Installing $pkg"
        "$brew_path" install "$pkg"
    done
}

brew_install_formulae_optional() {
    local brew_path pkg
    brew_path="$(brew_bin)"

    for pkg in "$@"; do
        if have "$pkg" || "$brew_path" list "$pkg" >/dev/null 2>&1; then
            log "Already available: $pkg"
            continue
        fi

        log "Trying to install $pkg"
        if ! "$brew_path" install "$pkg"; then
            log "Skipping $pkg (brew dependency failed; install a standalone binary into ~/.local/bin if needed)"
        fi
    done
}

install_tmux_release() {
    local arch version temp_dir archive_url install_dir tmux_bin release_json asset_pattern

    if have tmux; then
        log "Already installed: tmux"
        return
    fi

    arch="$(uname -m)"
    version="3.5a"
    install_dir="$HOME/.local"
    tmux_bin="$install_dir/bin/tmux"

    case "$arch" in
        arm64)
            asset_pattern='browser_download_url.*macos.*arm64.*tar.gz'
            ;;
        x86_64)
            asset_pattern='browser_download_url.*macos.*x86_64.*tar.gz'
            ;;
        *)
            log "Skipping tmux release install: unsupported architecture $arch"
            return 1
            ;;
    esac

    release_json="https://api.github.com/repos/nelsonenzo/tmux-appimage/releases/tags/${version}"
    archive_url="$(curl -fsSL "$release_json" | grep -E "$asset_pattern" | head -n 1 | cut -d '"' -f 4)"
    if [[ -z "$archive_url" ]]; then
        log "Could not find a prebuilt macOS tmux asset for $arch"
        return 1
    fi

    log "Installing tmux $version to $tmux_bin"
    temp_dir="$(mktemp -d)"
    if curl -fsSL "$archive_url" -o "$temp_dir/tmux.tar.gz" && tar xzf "$temp_dir/tmux.tar.gz" -C "$temp_dir"; then
        mkdir -p "$install_dir/bin"
        find "$temp_dir" -type f -name tmux -perm +111 -exec cp {} "$tmux_bin" \; -quit
        chmod +x "$tmux_bin"
        ensure_line 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.zprofile"
        log "Installed tmux release: $tmux_bin"
    else
        rm -rf "$temp_dir"
        return 1
    fi
    rm -rf "$temp_dir"
}

brew_install_casks_optional() {
    local brew_path pkg
    brew_path="$(brew_bin)"

    for pkg in "$@"; do
        if "$brew_path" list --cask "$pkg" >/dev/null 2>&1; then
            log "Already installed: $pkg"
            continue
        fi

        log "Trying to install cask: $pkg"
        if ! "$brew_path" install --cask "$pkg"; then
            log "Skipping cask $pkg (no admin or cask unavailable)"
        fi
    done
}

install_shell_tools() {
    local temp_config temp_dir archive_url

    if [[ -d "$HOME/.bash_it/.git" ]]; then
        log "Updating bash-it"
        git -C "$HOME/.bash_it" pull --ff-only || true
    elif [[ -d "$HOME/.bash_it" ]]; then
        log "~/.bash_it exists but is not a git checkout, leaving it untouched"
    else
        log "Installing bash-it"
        git clone --depth=1 https://github.com/Bash-it/bash-it.git "$HOME/.bash_it"
    fi

    if [[ -x "$HOME/.bash_it/install.sh" ]]; then
        temp_config="$(mktemp)"
        BASH_IT_CONFIG_FILE="$temp_config" "$HOME/.bash_it/install.sh" --silent >/dev/null 2>&1 || true
        rm -f "$temp_config"
    fi

    log "Installing ble.sh"
    temp_dir="$(mktemp -d)"
    archive_url='https://github.com/akinomyoga/ble.sh/releases/download/nightly/ble-nightly.tar.xz'
    curl -fsSL "$archive_url" -o "$temp_dir/ble-nightly.tar.xz"
    tar xJf "$temp_dir/ble-nightly.tar.xz" -C "$temp_dir"
    bash "$temp_dir/ble-nightly/ble.sh" --install "$HOME/.local/share"
    rm -rf "$temp_dir"
}

write_macos_ghostty_override() {
    local brew_path brew_prefix shell_path shell_name shell_flag path_prefix override_file

    brew_path="$(brew_bin)"
    brew_prefix="$("$brew_path" --prefix)"

    if [[ -x "$brew_prefix/bin/zsh" ]]; then
        shell_path="$brew_prefix/bin/zsh"
        shell_name="zsh"
        shell_flag="-l"
        path_prefix="$brew_prefix/bin:$brew_prefix/sbin"
    elif [[ -x /bin/zsh ]]; then
        shell_path="/bin/zsh"
        shell_name="zsh"
        shell_flag="-l"
        path_prefix="/usr/local/bin"
    elif [[ -x "$brew_prefix/bin/bash" ]]; then
        shell_path="$brew_prefix/bin/bash"
        shell_name="bash"
        shell_flag="--login"
        path_prefix="$brew_prefix/bin:$brew_prefix/sbin"
    else
        shell_path="/bin/bash"
        shell_name="bash"
        shell_flag="--login"
        path_prefix="$brew_prefix/bin:$brew_prefix/sbin"
    fi

    override_file="$HOME/.config/ghostty-local/config"
    mkdir -p "$(dirname "$override_file")"

    cat >"$override_file" <<EOF
# Generated by install-no-admin.sh
command = /bin/$shell_name -lc 'export PATH="$path_prefix:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"; exec $shell_path $shell_flag'
EOF

    log "Wrote $override_file"
}

link_configs() {
    mkdir -p "$HOME/.config"

    link_path "$REPO_DIR/nvim" "$HOME/.config/nvim"
    link_path "$REPO_DIR/ghostty" "$HOME/.config/ghostty"
    link_path "$REPO_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"
    link_path "$REPO_DIR/.bashrc" "$HOME/.bashrc"
    link_path "$REPO_DIR/.bash_profile" "$HOME/.bash_profile"
    link_path "$REPO_DIR/.profile" "$HOME/.profile"
    link_path "$REPO_DIR/.zshrc" "$HOME/.zshrc"
    link_path "$REPO_DIR/.inputrc" "$HOME/.inputrc"

    write_macos_ghostty_override
}

main() {
    local brew_path
    brew_path="$(brew_bin)" || die "brew not found. Export PATH for your ~/.homebrew/bin first."

    setup_brew_shellenv

    ensure_line 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.zprofile"

    brew_install_formulae_optional \
        git neovim ripgrep fd make curl xz gawk terraform helm \
        starship zoxide zsh zsh-autosuggestions zsh-syntax-highlighting \
        bash bash-completion@2

    if ! brew_install_formulae tmux; then
        log "Brew tmux failed; trying user-local prebuilt tmux"
        install_tmux_release || log "Skipping tmux; install it manually into ~/.local/bin/tmux"
    fi

    brew_install_casks_optional ghostty font-fira-code

    install_shell_tools
    link_configs

    log "Installation finished."
    log "Recommended next steps:"
    log "  1. Run: tmux kill-server"
    log "  2. Fully close and reopen Ghostty"
    log "  3. Open nvim and run :Lazy sync"
}

main "$@"
