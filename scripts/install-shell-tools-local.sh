#!/usr/bin/env bash

set -euo pipefail

BIN_DIR="$HOME/.local/bin"
PREFIX="$HOME/.local"
OMZ_DIR="$HOME/.oh-my-zsh"
OS="$(uname -s)"
ARCH="$(uname -m)"

log() {
  printf '[local-shell-tools] %s\n' "$*"
}

have() {
  command -v "$1" >/dev/null 2>&1
}

ensure_path() {
  mkdir -p "$BIN_DIR"
  case ":$PATH:" in
    *":$BIN_DIR:"*) ;;
    *) export PATH="$BIN_DIR:$PATH" ;;
  esac
}

download_to() {
  local url="$1"
  local target="$2"

  if have curl; then
    curl -fsSL "$url" -o "$target"
  elif have wget; then
    wget -qO "$target" "$url"
  else
    log 'Missing curl or wget'
    return 1
  fi
}

latest_release_url() {
  local repo="$1"
  local pattern="$2"

  if have curl; then
    curl -fsSL "https://api.github.com/repos/$repo/releases/latest" |
      sed -n 's/.*"browser_download_url": "\([^"]*\)".*/\1/p' |
      grep -E "$pattern" |
      head -n 1 || true
  else
    wget -qO- "https://api.github.com/repos/$repo/releases/latest" |
      sed -n 's/.*"browser_download_url": "\([^"]*\)".*/\1/p' |
      grep -E "$pattern" |
      head -n 1 || true
  fi
}

make_jobs() {
  getconf _NPROCESSORS_ONLN 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || printf '2\n'
}

install_starship() {
  local triple archive_url temp_dir

  if [[ -x "$BIN_DIR/starship" ]]; then
    log "Already available: starship ($BIN_DIR/starship)"
    return
  fi

  case "$OS:$ARCH" in
    Darwin:arm64) triple='aarch64-apple-darwin' ;;
    Darwin:x86_64) triple='x86_64-apple-darwin' ;;
    Linux:aarch64|Linux:arm64) triple='aarch64-unknown-linux-gnu' ;;
    Linux:x86_64) triple='x86_64-unknown-linux-gnu' ;;
    *) log "Skipping starship: unsupported platform $OS/$ARCH"; return 1 ;;
  esac

  archive_url="$(latest_release_url starship/starship "starship-${triple}\\.tar\\.gz$")"
  if [[ -z "$archive_url" ]]; then
    log 'Could not find starship release asset'
    return 1
  fi

  log "Installing starship to $BIN_DIR"
  temp_dir="$(mktemp -d)"
  download_to "$archive_url" "$temp_dir/starship.tar.gz"
  tar xzf "$temp_dir/starship.tar.gz" -C "$temp_dir"
  install -m 0755 "$temp_dir/starship" "$BIN_DIR/starship"
  rm -rf "$temp_dir"
}

install_zoxide() {
  if [[ -x "$BIN_DIR/zoxide" ]]; then
    log "Already available: zoxide ($BIN_DIR/zoxide)"
    return
  fi

  log "Installing zoxide to $BIN_DIR"
  if have curl; then
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
  elif have wget; then
    wget -qO- https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
  else
    log 'Missing curl or wget'
    return 1
  fi
}

install_oh_my_zsh() {
  if [[ -r "$OMZ_DIR/oh-my-zsh.sh" ]]; then
    log "Already available: Oh My Zsh ($OMZ_DIR)"
    return
  fi

  if ! have git; then
    log 'Skipping Oh My Zsh: git is not installed'
    return 1
  fi

  log "Installing Oh My Zsh to $OMZ_DIR"
  git clone --depth 1 https://github.com/ohmyzsh/ohmyzsh.git "$OMZ_DIR"
}

install_zsh_plugin() {
  local name="$1"
  local repo="$2"
  local target="$OMZ_DIR/custom/plugins/$name"

  if [[ -d "$target" ]]; then
    log "Already available: $name ($target)"
    return
  fi

  if ! have git; then
    log "Skipping $name: git is not installed"
    return 1
  fi

  log "Installing $name to $target"
  git clone --depth 1 "https://github.com/$repo.git" "$target"
}

install_local_zsh_plugin() {
  local name="$1"
  local repo="$2"
  local target="$HOME/.local/share/$name"

  if [[ -d "$target" ]]; then
    log "Already available: $name ($target)"
    return
  fi

  if ! have git; then
    log "Skipping $name: git is not installed"
    return 1
  fi

  log "Installing $name to $target"
  git clone --depth 1 "https://github.com/$repo.git" "$target"
}

build_libevent_local() {
  local version temp_dir jobs

  if [[ -r "$PREFIX/include/event2/event.h" ]]; then
    log "Already available: libevent ($PREFIX)"
    return
  fi

  version='2.1.12-stable'
  jobs="$(make_jobs)"
  temp_dir="$(mktemp -d)"

  log "Building libevent $version in $PREFIX"
  download_to "https://github.com/libevent/libevent/releases/download/release-${version}/libevent-${version}.tar.gz" "$temp_dir/libevent.tar.gz"
  tar xzf "$temp_dir/libevent.tar.gz" -C "$temp_dir"
  (
    cd "$temp_dir/libevent-${version}"
    ./configure --prefix="$PREFIX" --disable-openssl
    make -j "$jobs"
    make install
  )
  rm -rf "$temp_dir"
}

build_ncurses_local() {
  local version temp_dir jobs

  if [[ -r "$PREFIX/include/ncursesw/curses.h" || -r "$PREFIX/include/curses.h" ]]; then
    log "Already available: ncurses ($PREFIX)"
    return
  fi

  version='6.5'
  jobs="$(make_jobs)"
  temp_dir="$(mktemp -d)"

  log "Building ncurses $version in $PREFIX"
  download_to "https://ftp.gnu.org/pub/gnu/ncurses/ncurses-${version}.tar.gz" "$temp_dir/ncurses.tar.gz"
  tar xzf "$temp_dir/ncurses.tar.gz" -C "$temp_dir"
  (
    cd "$temp_dir/ncurses-${version}"
    ./configure \
      --prefix="$PREFIX" \
      --enable-widec \
      --enable-pc-files \
      --with-pkg-config-libdir="$PREFIX/lib/pkgconfig" \
      --without-ada \
      --without-debug \
      --without-manpages \
      --without-progs \
      --without-tests
    make -j "$jobs"
    make install
  )
  rm -rf "$temp_dir"
}

build_tmux_local() {
  local version temp_dir jobs rpath_flags

  if [[ -x "$BIN_DIR/tmux" ]]; then
    log "Already available: tmux ($BIN_DIR/tmux)"
    return
  fi

  for tool in cc make tar; do
    if ! have "$tool"; then
      log "Cannot build tmux locally: missing $tool"
      return 1
    fi
  done

  build_libevent_local
  build_ncurses_local

  version='3.5a'
  jobs="$(make_jobs)"
  temp_dir="$(mktemp -d)"
  rpath_flags=''
  if [[ "$OS" == 'Darwin' ]]; then
    rpath_flags="-Wl,-rpath,$PREFIX/lib"
  fi

  log "Building tmux $version in $PREFIX"
  download_to "https://github.com/tmux/tmux/releases/download/${version}/tmux-${version}.tar.gz" "$temp_dir/tmux.tar.gz"
  tar xzf "$temp_dir/tmux.tar.gz" -C "$temp_dir"
  (
    cd "$temp_dir/tmux-${version}"
    PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig" \
      CPPFLAGS="-I$PREFIX/include -I$PREFIX/include/ncursesw" \
      LDFLAGS="-L$PREFIX/lib $rpath_flags" \
      ./configure --prefix="$PREFIX"
    make -j "$jobs"
    make install
  )
  rm -rf "$temp_dir"
}

install_tmux_best_effort() {
  local pattern archive_url temp_dir

  if [[ -x "$BIN_DIR/tmux" ]]; then
    log "Already available: tmux ($BIN_DIR/tmux)"
    return
  fi

  if have tmux; then
    case "$(command -v tmux)" in
      "$HOME/.homebrew"/*|/opt/homebrew/*|/usr/local/Cellar/*|/usr/local/opt/*)
        log "Ignoring Homebrew tmux while installing local tmux: $(command -v tmux)"
        ;;
      *)
        log "Already available: tmux ($(command -v tmux))"
        return
        ;;
    esac
  fi

  case "$OS:$ARCH" in
    Darwin:arm64) pattern='macos.*arm64.*tar.gz$' ;;
    Darwin:x86_64) pattern='macos.*x86_64.*tar.gz$' ;;
    *) log 'Skipping tmux standalone: no bundled fallback for this platform'; return 0 ;;
  esac

  archive_url="$(latest_release_url nelsonenzo/tmux-appimage "$pattern")"
  if [[ -z "$archive_url" ]]; then
    log 'Could not find standalone tmux release asset; trying local source build'
    build_tmux_local
    return
  fi

  log "Installing standalone tmux to $BIN_DIR"
  temp_dir="$(mktemp -d)"
  download_to "$archive_url" "$temp_dir/tmux.tar.gz"
  tar xzf "$temp_dir/tmux.tar.gz" -C "$temp_dir"
  find "$temp_dir" -type f -name tmux -perm +111 -exec install -m 0755 {} "$BIN_DIR/tmux" \; -quit
  rm -rf "$temp_dir"

  if ! [[ -x "$BIN_DIR/tmux" ]]; then
    log 'Downloaded tmux archive, but no executable tmux binary was found'
    build_tmux_local
  fi
}

main() {
  ensure_path
  install_starship || true
  install_zoxide || true
  install_oh_my_zsh || true
  install_local_zsh_plugin zsh-autosuggestions zsh-users/zsh-autosuggestions || true
  install_local_zsh_plugin zsh-syntax-highlighting zsh-users/zsh-syntax-highlighting || true
  install_zsh_plugin zsh-autosuggestions zsh-users/zsh-autosuggestions || true
  install_zsh_plugin zsh-syntax-highlighting zsh-users/zsh-syntax-highlighting || true
  install_tmux_best_effort || true
  log "Done. Make sure $BIN_DIR is in PATH before opening Ghostty."
}

main "$@"
