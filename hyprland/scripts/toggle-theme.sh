#!/usr/bin/env bash
set -euo pipefail

STATE_DIR="$HOME/.config/hypr-local"
WAYBAR_DIR="$HOME/.config/waybar-local"
KITTY_DIR="$HOME/.config/kitty-local"
TMUX_DIR="$HOME/.tmux-local"
NVIM_DIR="$HOME/.config/nvim-local"
STATE_FILE="$STATE_DIR/theme.mode"
HYPR_FILE="$STATE_DIR/theme.conf"
WAYBAR_FILE="$WAYBAR_DIR/theme.css"
KITTY_FILE="$KITTY_DIR/theme.conf"
TMUX_FILE="$TMUX_DIR/theme.conf"
NVIM_FILE="$NVIM_DIR/theme.lua"

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

  cat > "$NVIM_FILE" <<'EOF'
return {
  background = 'dark',
  contrast = 'hard',
  transparent_mode = true,
}
EOF
}

write_light() {
  cat > "$HYPR_FILE" <<'EOF'
general {
    col.active_border = rgba(d65d0eff)
    col.inactive_border = rgba(7c6f64aa)
}
EOF

  cat > "$WAYBAR_FILE" <<'EOF'
@define-color base rgba(251, 241, 199, 0.97);
@define-color text rgb(60, 56, 54);
@define-color border rgb(168, 153, 132);
@define-color cream rgb(60, 56, 54);
@define-color antique rgb(80, 73, 69);
@define-color yellow rgb(215, 153, 33);
@define-color peach rgb(214, 93, 14);
@define-color blue rgb(69, 133, 136);
@define-color purple rgb(177, 98, 134);
@define-color green rgb(152, 151, 26);
@define-color red rgb(204, 36, 29);
@define-color red-bright rgb(157, 0, 6);
@define-color orange rgb(214, 93, 14);
@define-color green-bright rgb(121, 116, 14);

window#waybar {
  border-bottom: 1px solid rgba(168, 153, 132, 0.55);
}

tooltip {
  color: rgb(60, 56, 54);
  border: 1px solid rgba(168, 153, 132, 0.55);
}

menu {
  background: rgb(251, 241, 199);
  color: rgb(60, 56, 54);
  border: 1px solid rgba(168, 153, 132, 0.55);
}

#workspaces button {
  color: rgba(60, 56, 54, 0.62);
  border-right: 1px solid rgba(168, 153, 132, 0.35);
}

#workspaces button.active {
  color: rgb(40, 40, 40);
  background: rgba(215, 153, 33, 0.18);
}

#workspaces button:hover {
  background: rgba(214, 93, 14, 0.14);
  color: rgb(40, 40, 40);
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
  color: rgba(60, 56, 54, 0.82);
}
EOF

  cat > "$KITTY_FILE" <<'EOF'
foreground #3c3836
background #fbf1c7
selection_foreground #fbf1c7
selection_background #665c54
cursor #3c3836
cursor_text_color #fbf1c7
url_color #458588
active_tab_foreground #282828
active_tab_background #fabd2f
inactive_tab_foreground #7c6f64
inactive_tab_background #ebdbb2
color0  #fbf1c7
color1  #cc241d
color2  #98971a
color3  #d79921
color4  #458588
color5  #b16286
color6  #689d6a
color7  #7c6f64
color8  #928374
color9  #9d0006
color10 #79740e
color11 #b57614
color12 #076678
color13 #8f3f71
color14 #427b58
color15 #3c3836
EOF

  cat > "$TMUX_FILE" <<'EOF'
set -g status-style 'fg=#3c3836,bg=#fbf1c7'
setw -g window-status-style 'fg=#7c6f64,bg=#fbf1c7'
setw -g window-status-current-style 'fg=#282828,bg=#fabd2f,bold'
set-option -g status-right '#[fg=#7c6f64,bg=#fbf1c7] %Y-%m-%d #[fg=#3c3836,bg=#fbf1c7]%H:%M '
EOF

  cat > "$NVIM_FILE" <<'EOF'
return {
  background = 'light',
  contrast = 'hard',
  transparent_mode = false,
}
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

  mkdir -p "$STATE_DIR" "$WAYBAR_DIR" "$KITTY_DIR" "$TMUX_DIR" "$NVIM_DIR"

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
