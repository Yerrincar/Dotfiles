#!/usr/bin/env bash
set -euo pipefail

MAIN_MONITOR="HDMI-A-1"
LAPTOP_MONITOR="eDP-1"

is_enabled() {
  hyprctl monitors -j | jq -e --arg name "$1" '.[] | select(.name == $name)' >/dev/null
}

is_connected() {
  if hyprctl monitors all -j >/dev/null 2>&1; then
    hyprctl monitors all -j | jq -e --arg name "$1" '.[] | select(.name == $name)' >/dev/null
  else
    is_enabled "$1"
  fi
}

notify() {
  if command -v notify-send >/dev/null 2>&1; then
    notify-send "Hyprland monitors" "$1"
  fi
}

if ! is_connected "$MAIN_MONITOR"; then
  notify "Main monitor ($MAIN_MONITOR) is not connected"
  exit 0
fi

if is_enabled "$LAPTOP_MONITOR"; then
  # Dual mode is ON -> turn it OFF (external-only)
  hyprctl keyword monitor "$LAPTOP_MONITOR,disable"
  hyprctl dispatch focusmonitor "$MAIN_MONITOR" || true
  notify "Dual-screen OFF (external only)"
else
  # Dual mode is OFF -> turn it ON (external + laptop)
  hyprctl keyword monitor "$MAIN_MONITOR,preferred,auto,1"
  hyprctl keyword monitor "$LAPTOP_MONITOR,preferred,auto,1"
  notify "Dual-screen ON (external + laptop)"
fi
