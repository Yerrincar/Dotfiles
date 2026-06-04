#!/usr/bin/env bash
# Si no es un shell interactivo, salir
[[ $- != *i* ]] && return

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

  case ":$PATH:" in
    *":$HOMEBREW_PREFIX/bin:"*) ;;
    *) export PATH="$HOMEBREW_PREFIX/bin:$PATH" ;;
  esac
  case ":$PATH:" in
    *":$HOMEBREW_PREFIX/sbin:"*) ;;
    *) export PATH="$HOMEBREW_PREFIX/sbin:$PATH" ;;
  esac
fi

if [[ -n ${HOMEBREW_PREFIX-} && -r "$HOMEBREW_PREFIX/etc/ca-certificates/cert.pem" ]]; then
  export SSL_CERT_FILE="$HOMEBREW_PREFIX/etc/ca-certificates/cert.pem"
  export REQUESTS_CA_BUNDLE="$SSL_CERT_FILE"
  export NODE_EXTRA_CA_CERTS="$SSL_CERT_FILE"
fi

case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) export PATH="$HOME/.local/bin:$PATH" ;;
esac

# If not running interactively, don't do anything
case $- in
*i*) ;;
*) return ;;
esac

# Start tmux as early as possible so the outer shell does not spend time
# loading the full interactive stack before immediately exec-ing into tmux.
if [[ -z "$TMUX" ]] && command -v tmux >/dev/null 2>&1; then
  exec tmux new-session -A -s main
fi

if [[ ${BASH_COMPLETION_ENABLE-} == 1 && -n ${HOMEBREW_PREFIX-} && -r "$HOMEBREW_PREFIX/etc/profile.d/bash_completion.sh" ]]; then
  source "$HOMEBREW_PREFIX/etc/profile.d/bash_completion.sh"
fi

# Path to the bash it configuration
export BASH_IT="$HOME/.bash_it"

if command -v go >/dev/null 2>&1; then
  export PATH="$PATH:$(go env GOPATH)/bin"
fi

alias crontab='EDITOR=vim VISUAL=vim crontab'
# Lock and Load a custom theme file.
# Leave empty to disable theming.
# location "$BASH_IT"/themes/
export BASH_IT_THEME=""

# Some themes can show whether `sudo` has a current token or not.
# Set `$THEME_CHECK_SUDO` to `true` to check every prompt:
#THEME_CHECK_SUDO='true'

# (Advanced): Change this to the name of your remote repo if you
# cloned bash-it with a remote other than origin such as `bash-it`.
# export BASH_IT_REMOTE='bash-it'

# (Advanced): Change this to the name of the main development branch if
# you renamed it or if it was changed for some reason
# export BASH_IT_DEVELOPMENT_BRANCH='master'

# Your place for hosting Git repos. I use this for private repos.
export GIT_HOSTING='git@git.domain.com'

# Don't check mail when opening terminal.
unset MAILCHECK

# Change this to your console based IRC client of choice.
export IRC_CLIENT='irssi'

# Set this to the command you use for todo.txt-cli
export TODO="t"

# Set this to the location of your work or project folders
#BASH_IT_PROJECT_PATHS="${HOME}/Projects:/Volumes/work/src"

# Set this to false to turn off version control status checking within the prompt for all themes
export SCM_CHECK=true
# Set to actual location of gitstatus directory if installed
#export SCM_GIT_GITSTATUS_DIR="$HOME/gitstatus"
# per default gitstatus uses 2 times as many threads as CPU cores, you can change this here if you must
#export GITSTATUS_NUM_THREADS=8

# Set Xterm/screen/Tmux title with only a short hostname.
# Uncomment this (or set SHORT_HOSTNAME to something else),
# Will otherwise fall back on $HOSTNAME.
#export SHORT_HOSTNAME=$(hostname -s)
export LANG=en_US.UTF-8
# Set Xterm/screen/Tmux title with only a short username.
# Uncomment this (or set SHORT_USER to something else),
# Will otherwise fall back on $USER.
#export SHORT_USER=${USER:0:8}

# If your theme use command duration, uncomment this to
# enable display of last command duration.
#export BASH_IT_COMMAND_DURATION=true
# You can choose the minimum time in seconds before
# command duration is displayed.
#export COMMAND_DURATION_MIN_SECONDS=1

# Set Xterm/screen/Tmux title with shortened command and directory.
# Uncomment this to set.
#export SHORT_TERM_LINE=true

# Set vcprompt executable path for scm advance info in prompt (demula theme)
# https://github.com/djl/vcprompt
#export VCPROMPT_EXECUTABLE=~/.vcprompt/bin/vcprompt

# (Advanced): Uncomment this to make Bash-it reload itself automatically
# after enabling or disabling aliases, plugins, and completions.
# export BASH_IT_AUTOMATIC_RELOAD_AFTER_CONFIG_CHANGE=1

# Uncomment this to make Bash-it create alias reload.
# export BASH_IT_RELOAD_LEGACY=1
# Cargar ble.sh (Bash Line Editor) sin adjuntar aún
if [[ ${BLE_ENABLE-1} == 1 && -f "$HOME/.local/share/blesh/ble.sh" ]]; then
  source "$HOME/.local/share/blesh/ble.sh" --noattach
fi

if [[ -n ${BLE_VERSION-} ]]; then
	bleopt complete_auto_complete=1
	bleopt complete_auto_delay=300
	ble-face auto_complete=fg=250
	ble-face syntax_error=fg=231
fi

if [[ -f "$HOME/.inputrc" ]]; then
  bind -f "$HOME/.inputrc"
fi

# Load Bash It only when explicitly requested. It is useful for aliases/plugins,
# but it can add several seconds to shell startup on macOS.
if [[ ${BASH_IT_ENABLE-} == 1 && -f "$BASH_IT/bash_it.sh" ]]; then
  source "$BASH_IT/bash_it.sh"
fi

#Iniciamos starship y zoxide
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
fi

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init bash)"
fi

# Adjuntar ble.sh ahora que el prompt (Starship) está inicializado
[[ ${BLE_ENABLE-1} == 1 && ${BLE_VERSION-} ]] && ble-attach

if [[ -f "$HOME/.local/bin/env" ]]; then
  . "$HOME/.local/bin/env"
fi

# bun
export BUN_INSTALL="$HOME/.bun"
if [[ -d "$BUN_INSTALL/bin" ]]; then
  export PATH="$BUN_INSTALL/bin:$PATH"
fi

# opencode
if [[ -d "$HOME/.opencode/bin" ]]; then
  export PATH="$HOME/.opencode/bin:$PATH"
fi

# Turso
if [[ -d "$HOME/.turso" ]]; then
  export PATH="$PATH:$HOME/.turso"
fi
