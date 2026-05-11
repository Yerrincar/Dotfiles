
#!/usr/bin/env bash
set -euo pipefail

TARGET_MONITOR="HDMI-A-1"

# Espera a que Hyprland esté listo
sleep 1

# Verifica si HDMI-A-1 está conectado
if hyprctl monitors | grep -q "$TARGET_MONITOR"; then
  echo "Monitor externo detectado. Moviendo workspaces a $TARGET_MONITOR..."

  for i in {1..10}; do
    hyprctl dispatch moveworkspacetomonitor "$i" "$TARGET_MONITOR"
  done

  # Activar el workspace 1 y dar foco
  hyprctl dispatch workspace 1
  hyprctl dispatch focusmonitor "$TARGET_MONITOR"
fi

