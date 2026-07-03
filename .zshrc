# Repo-managed zsh config.

if [[ -d "$HOME/.homebrew" ]]; then
  export HOMEBREW_PREFIX="$HOME/.homebrew"
elif [[ -d /opt/homebrew ]]; then
  export HOMEBREW_PREFIX=/opt/homebrew
elif [[ -d /usr/local/Homebrew || -d /usr/local/Cellar ]]; then
  export HOMEBREW_PREFIX=/usr/local
fi

if [[ -n ${HOMEBREW_PREFIX-} ]]; then
  export HOMEBREW_CELLAR="$HOMEBREW_PREFIX/Cellar"
  export HOMEBREW_REPOSITORY="$HOMEBREW_PREFIX/Homebrew"
  path=("$HOMEBREW_PREFIX/bin" "$HOMEBREW_PREFIX/sbin" $path)
fi

path=("/usr/local/bin" "/usr/local/sbin" $path)
path=("$HOME/.local/bin" $path)

if [[ -n ${HOMEBREW_PREFIX-} && -r "$HOMEBREW_PREFIX/etc/ca-certificates/cert.pem" ]]; then
  export SSL_CERT_FILE="$HOMEBREW_PREFIX/etc/ca-certificates/cert.pem"
  export REQUESTS_CA_BUNDLE="$SSL_CERT_FILE"
  export NODE_EXTRA_CA_CERTS="$SSL_CERT_FILE"
fi

export LANG=en_US.UTF-8
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=10000
export SAVEHIST=20000
setopt append_history hist_ignore_all_dups hist_reduce_blanks share_history

if [[ -z ${TMUX-} && -z ${NO_TMUX-} ]] && command -v tmux >/dev/null 2>&1; then
  exec tmux new-session -A -s main
fi

if [[ -r "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]]; then
  export ZSH="$HOME/.oh-my-zsh"
  ZSH_THEME=""
  plugins=(git)
  source "$ZSH/oh-my-zsh.sh"
else
  autoload -Uz compinit
  mkdir -p "$HOME/.cache/zsh"
  compinit -d "$HOME/.cache/zsh/zcompdump-$ZSH_VERSION"
fi

source_first_readable() {
  local file
  for file in "$@"; do
    if [[ -r "$file" ]]; then
      source "$file"
      return
    fi
  done
}

source_first_readable \
  "$HOME/.local/share/zsh-autosuggestions/zsh-autosuggestions.zsh" \
  "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" \
  "${HOMEBREW_PREFIX:-}/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

source_first_readable \
  "$HOME/.local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" \
  "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" \
  "${HOMEBREW_PREFIX:-}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

if [[ -d "$HOME/go/bin" ]]; then
  path+=("$HOME/go/bin")
fi

export BUN_INSTALL="$HOME/.bun"
[[ -d "$BUN_INSTALL/bin" ]] && path=("$BUN_INSTALL/bin" $path)
[[ -d "$HOME/.opencode/bin" ]] && path=("$HOME/.opencode/bin" $path)
[[ -d "$HOME/.turso" ]] && path+=("$HOME/.turso")

export PATH
