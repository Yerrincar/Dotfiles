#!/usr/bin/env bash
set -euo pipefail

export PATH="$HOME/.local/bin:$HOME/.cargo/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

notify() {
  if command -v notify-send >/dev/null 2>&1; then
    notify-send "Screenshot" "$1"
  fi
}

if command -v hyprshot >/dev/null 2>&1; then
  exec hyprshot -m region --clipboard-only
fi

if command -v grimblast >/dev/null 2>&1; then
  exec grimblast --notify copysave area
fi

notify 'Missing hyprshot or grimblast for region screenshot'
exit 1
