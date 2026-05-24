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

move_workspaces() {
  local target="$1"

  for i in {1..10}; do
    hyprctl dispatch moveworkspacetomonitor "$i" "$target" >/dev/null 2>&1 || true
  done

  hyprctl dispatch workspace 1 >/dev/null 2>&1 || true
  hyprctl dispatch focusmonitor "$target" >/dev/null 2>&1 || true
}

set_external_only() {
  hyprctl keyword monitor "$MAIN_MONITOR,preferred,auto,1"
  hyprctl keyword monitor "$LAPTOP_MONITOR,disable"
  move_workspaces "$MAIN_MONITOR"
  notify "External only"
}

set_laptop_only() {
  hyprctl keyword monitor "$MAIN_MONITOR,disable"
  hyprctl keyword monitor "$LAPTOP_MONITOR,preferred,auto,1"
  move_workspaces "$LAPTOP_MONITOR"
  notify "Laptop only"
}

set_dual() {
  hyprctl keyword monitor "$MAIN_MONITOR,preferred,auto,1"
  hyprctl keyword monitor "$LAPTOP_MONITOR,preferred,auto,1"
  move_workspaces "$MAIN_MONITOR"
  notify "Dual screen"
}

if ! is_connected "$MAIN_MONITOR"; then
  set_laptop_only
  exit 0
fi

if is_enabled "$MAIN_MONITOR" && is_enabled "$LAPTOP_MONITOR"; then
  set_external_only
elif is_enabled "$MAIN_MONITOR"; then
  set_laptop_only
else
  set_dual
fi
