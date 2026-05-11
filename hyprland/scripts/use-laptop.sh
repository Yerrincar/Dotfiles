#!/bin/bash


#!/bin/bash

while true; do
    connected=$(hyprctl monitors -j | jq -r '.[].name' | grep -c HDMI-A-1)
    if [[ "$connected" -eq 0 ]]; then
        hyprctl keyword monitor "eDP-1,1920x1080@60,0x0,1"
    fi
    sleep 5
done
 
