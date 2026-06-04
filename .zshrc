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

if [[ -z ${TMUX-} ]] && command -v tmux >/dev/null 2>&1; then
  exec tmux new-session -A -s main
fi

autoload -Uz compinit
mkdir -p "$HOME/.cache/zsh"
compinit -d "$HOME/.cache/zsh/zcompdump-$ZSH_VERSION"

if [[ -n ${HOMEBREW_PREFIX-} ]]; then
  [[ -r "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  [[ -r "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

if [[ -d "$HOME/go/bin" ]]; then
  path+=("$HOME/go/bin")
fi

export BUN_INSTALL="$HOME/.bun"
[[ -d "$BUN_INSTALL/bin" ]] && path=("$BUN_INSTALL/bin" $path)
[[ -d "$HOME/.opencode/bin" ]] && path=("$HOME/.opencode/bin" $path)
[[ -d "$HOME/.turso" ]] && path+=("$HOME/.turso")

export PATH
