#!/bin/bash

# watch-waybar.sh — starts waybar and keeps it alive
#
# Health check mechanism:
#   We check /proc/net/unix for an ESTABLISHED connection from waybar to
#   Hyprland's socket2 event socket. If that connection is gone, waybar has
#   lost its IPC subscription and will no longer update workspaces/windows,
#   so we restart it.

WAYBAR_CONFIG=~/.config/waybar/config.jsonc
WAYBAR_STYLE=~/.config/waybar/style.css
WAYBAR_CONFIG_DIR=$(dirname "$WAYBAR_CONFIG")

CHECK_INTERVAL=10   # seconds between IPC connectivity checks
STARTUP_GRACE=5     # seconds to wait after starting before checks begin


# ── Waybar lifecycle ──────────────────────────────────────────────────────────

start_waybar() {
    waybar &
    disown
}

stop_waybar() {
    pkill -x waybar
    sleep 0.5
}

restart_waybar() {
    stop_waybar
    start_waybar
}


# ── IPC health check ──────────────────────────────────────────────────────────

# Returns 0 if there is an ESTABLISHED connection to Hyprland's socket2 event
# socket (meaning waybar is subscribed and receiving workspace/window events).
check_ipc() {
    local socket2="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
    [[ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]] || return 1
    grep -q " 03 [0-9]* ${socket2}$" /proc/net/unix 2>/dev/null
}


# ── Config file watcher ───────────────────────────────────────────────────────

# Restart waybar when config.jsonc or style.css are saved.
watch_config() {
    while true; do
        local changed
        changed=$(inotifywait -e close_write -e moved_to --format '%f' "$WAYBAR_CONFIG_DIR" 2>/dev/null)
        if [[ "$changed" == "config.jsonc" ]] || [[ "$changed" == "style.css" ]]; then
            restart_waybar
            sleep "$STARTUP_GRACE"
        fi
    done
}


# ── Main ──────────────────────────────────────────────────────────────────────

start_waybar
watch_config &

sleep "$STARTUP_GRACE"

while true; do
    if ! pgrep -x waybar > /dev/null; then
        start_waybar
        sleep "$STARTUP_GRACE"
    elif ! check_ipc; then
        restart_waybar
        sleep "$STARTUP_GRACE"
    fi
    sleep "$CHECK_INTERVAL"
done
