#!/usr/bin/env bash
set -euo pipefail

WG_INTERFACE="${WG_INTERFACE:-wg0}"

notify() {
  if command -v notify-send >/dev/null 2>&1; then
    notify-send "WireGuard" "$1"
  fi
}

detect_interface() {
  local configs=()

  if [[ -n "$WG_INTERFACE" ]]; then
    printf '%s\n' "$WG_INTERFACE"
    return 0
  fi

  if compgen -G '/etc/wireguard/*.conf' >/dev/null; then
    while IFS= read -r path; do
      configs+=("$(basename "$path" .conf)")
    done < <(printf '%s\n' /etc/wireguard/*.conf)
  fi

  if [[ ${#configs[@]} -eq 1 ]]; then
    printf '%s\n' "${configs[0]}"
    return 0
  fi

  return 1
}

main() {
  local interface unit state

  if ! command -v systemctl >/dev/null 2>&1; then
    notify 'systemctl is not available'
    exit 1
  fi

  if ! command -v pkexec >/dev/null 2>&1; then
    notify 'pkexec is required to toggle WireGuard from Hyprland'
    exit 1
  fi

  if ! interface="$(detect_interface)"; then
    notify 'Could not detect a unique WireGuard interface. Set WG_INTERFACE in the script.'
    exit 1
  fi

  unit="wg-quick@${interface}.service"
  state="$(systemctl is-active "$unit" 2>/dev/null || true)"

  if [[ "$state" == 'active' ]]; then
    pkexec systemctl stop "$unit"
    notify "VPN down (${interface})"
  else
    pkexec systemctl start "$unit"
    notify "VPN up (${interface})"
  fi
}

main "$@"
