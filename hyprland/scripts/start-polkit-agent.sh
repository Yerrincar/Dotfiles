#!/usr/bin/env bash
set -euo pipefail

for agent in \
  /usr/libexec/hyprpolkitagent \
  /usr/libexec/lxqt-policykit-agent \
  /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 \
  /usr/libexec/polkit-gnome-authentication-agent-1
do
  if [[ -x "$agent" ]]; then
    exec "$agent"
  fi
done

if command -v notify-send >/dev/null 2>&1; then
  notify-send 'Hyprland' 'No polkit agent found for pkexec prompts'
fi
