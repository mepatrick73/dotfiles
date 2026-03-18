#!/bin/bash

# power-menu.sh — session power actions via wofi
#
# Triggered by mod+shift+R in hyprland.conf.
# Uses wofi in dmenu mode so the list is fixed (no app indexing).
# --cache-file /dev/null prevents wofi from reordering entries by usage.

options="  Lock\n  Logout\n  Suspend\n  Reboot\n  Shutdown"

choice=$(echo -e "$options" | wofi \
    --dmenu \
    --prompt "Power" \
    --width 220 \
    --height 250 \
    --cache-file /dev/null)

case "$choice" in
    *Lock)     hyprlock ;;
    *Logout)   hyprctl dispatch exit ;;
    *Suspend)  systemctl suspend ;;
    *Reboot)   systemctl reboot ;;
    *Shutdown) systemctl poweroff ;;
esac
