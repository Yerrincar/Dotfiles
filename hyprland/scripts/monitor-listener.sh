#!/bin/bash

# Escucha eventos de Hyprland sobre monitores
socat -U - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line; do
  if [[ "$line" == monitoradded* ]]; then
    ~/.config/hypr/scripts/move-workspaces-external.sh
  fi
done

