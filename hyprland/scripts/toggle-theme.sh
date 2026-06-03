#!/usr/bin/env bash
set -euo pipefail

STATE_DIR="$HOME/.config/hypr-local"
WAYBAR_DIR="$HOME/.config/waybar-local"
KITTY_DIR="$HOME/.config/kitty-local"
TMUX_DIR="$HOME/.tmux-local"
STATE_FILE="$STATE_DIR/theme.mode"
HYPR_FILE="$STATE_DIR/theme.conf"
WAYBAR_FILE="$WAYBAR_DIR/theme.css"
KITTY_FILE="$KITTY_DIR/theme.conf"
TMUX_FILE="$TMUX_DIR/theme.conf"

notify() {
  if command -v notify-send >/dev/null 2>&1; then
    notify-send "Theme" "$1"
  fi
}

write_dark() {
  cat > "$HYPR_FILE" <<'EOF'
# Dark mode uses the repo defaults.
EOF

  cat > "$WAYBAR_FILE" <<'EOF'
/* Dark mode uses the repo defaults. */
EOF

  cat > "$KITTY_FILE" <<'EOF'
foreground #e8e8e8
background #050505
selection_foreground #050505
selection_background #d8d8d8
cursor #f0f0f0
cursor_text_color #050505
url_color #dcdcdc
active_tab_foreground #ffffff
active_tab_background #050505
inactive_tab_foreground #9a9a9a
inactive_tab_background #050505
color0  #0a0a0a
color1  #8a8a8a
color2  #b0b0b0
color3  #d0d0d0
color4  #9c9c9c
color5  #c0c0c0
color6  #d8d8d8
color7  #eeeeee
color8  #4c4c4c
color9  #9a9a9a
color10 #c4c4c4
color11 #e2e2e2
color12 #b4b4b4
color13 #d0d0d0
color14 #ececec
color15 #ffffff
EOF

  cat > "$TMUX_FILE" <<'EOF'
set -g status-style 'fg=#e8e8e8,bg=#050505'
setw -g window-status-style 'fg=#8a8a8a,bg=#050505'
setw -g window-status-current-style 'fg=#ffffff,bg=#141414,bold'
set-option -g status-right '#[fg=#a8a8a8,bg=#050505] %Y-%m-%d #[fg=#d8d8d8,bg=#050505]%H:%M '
EOF
}

write_light() {
  cat > "$HYPR_FILE" <<'EOF'
general {
    col.active_border = rgba(00000066)
    col.inactive_border = rgba(cfcfcfaa)
}
EOF

  cat > "$WAYBAR_FILE" <<'EOF'
@define-color base rgba(248, 248, 248, 0.97);
@define-color text rgb(20, 20, 20);
@define-color border rgb(190, 190, 190);
@define-color cream rgb(25, 25, 25);
@define-color antique rgb(45, 45, 45);
@define-color yellow rgb(35, 35, 35);
@define-color peach rgb(55, 55, 55);
@define-color blue rgb(30, 30, 30);
@define-color purple rgb(70, 70, 70);
@define-color green rgb(35, 35, 35);
@define-color red rgb(45, 45, 45);
@define-color red-bright rgb(0, 0, 0);
@define-color orange rgb(35, 35, 35);
@define-color green-bright rgb(0, 0, 0);

window#waybar {
  border-bottom: 1px solid rgba(0, 0, 0, 0.10);
}

tooltip {
  color: rgb(20, 20, 20);
  border: 1px solid rgba(0, 0, 0, 0.10);
}

menu {
  background: rgb(245, 245, 245);
  color: rgb(20, 20, 20);
  border: 1px solid rgba(0, 0, 0, 0.10);
}

#workspaces button {
  color: rgba(0, 0, 0, 0.55);
  border-right: 1px solid rgba(0, 0, 0, 0.06);
}

#workspaces button.active {
  color: rgb(0, 0, 0);
  background: rgba(0, 0, 0, 0.03);
}

#workspaces button:hover {
  background: rgba(0, 0, 0, 0.05);
  color: rgb(0, 0, 0);
}

#custom-power-menu,
#custom-menu,
#custom-mpris,
#network,
#pulseaudio,
#pulseaudio.microphone,
#battery,
#custom-weather,
#custom-screenrecord,
#custom-notification,
#backlight,
#cpu,
#memory,
#temperature,
#tray,
#clock,
#power-profiles-daemon {
  color: rgba(0, 0, 0, 0.72);
}
EOF

  cat > "$KITTY_FILE" <<'EOF'
foreground #0a0a0a
background #f5f5f5
selection_foreground #f5f5f5
selection_background #2a2a2a
cursor #0a0a0a
cursor_text_color #f5f5f5
url_color #111111
active_tab_foreground #0a0a0a
active_tab_background #f5f5f5
inactive_tab_foreground #555555
inactive_tab_background #f5f5f5
color0  #0a0a0a
color1  #141414
color2  #1f1f1f
color3  #2a2a2a
color4  #161616
color5  #222222
color6  #2e2e2e
color7  #3c3c3c
color8  #2a2a2a
color9  #101010
color10 #1b1b1b
color11 #262626
color12 #131313
color13 #1f1f1f
color14 #2b2b2b
color15 #4a4a4a
EOF

  cat > "$TMUX_FILE" <<'EOF'
set -g status-style 'fg=#1a1a1a,bg=#f0f0f0'
setw -g window-status-style 'fg=#5a5a5a,bg=#f0f0f0'
setw -g window-status-current-style 'fg=#111111,bg=#dcdcdc,bold'
set-option -g status-right '#[fg=#4a4a4a,bg=#f0f0f0] %Y-%m-%d #[fg=#1a1a1a,bg=#f0f0f0]%H:%M '
EOF
}

reload_kitty() {
  if command -v kitty >/dev/null 2>&1; then
    kitty @ load-config "$HOME/.config/kitty/kitty.conf" >/dev/null 2>&1 || true
  fi
}

reload_tmux() {
  if command -v tmux >/dev/null 2>&1; then
    tmux source-file "$HOME/.tmux.conf" >/dev/null 2>&1 || true
  fi
}

reload_theme() {
  hyprctl reload >/dev/null 2>&1 || true
  pkill waybar >/dev/null 2>&1 || true
  nohup waybar -c "$HOME/.config/waybar/config.jsonc" -s "$HOME/.config/waybar/style.round.css" >/dev/null 2>&1 &
}

main() {
  local mode requested_mode

  mkdir -p "$STATE_DIR" "$WAYBAR_DIR" "$KITTY_DIR" "$TMUX_DIR"

  mode="dark"
  if [[ -f "$STATE_FILE" ]]; then
    mode="$(<"$STATE_FILE")"
  fi

  requested_mode="${1:-toggle}"

  if [[ "$requested_mode" == 'toggle' ]]; then
    if [[ "$mode" == 'dark' ]]; then
      requested_mode='light'
    else
      requested_mode='dark'
    fi
  fi

  if [[ "$requested_mode" == 'light' ]]; then
    write_light
    printf 'light\n' > "$STATE_FILE"
    notify 'Light mode'
  else
    write_dark
    printf 'dark\n' > "$STATE_FILE"
    notify 'Dark mode'
  fi

  reload_theme
  reload_kitty
  reload_tmux
}

main "$@"
