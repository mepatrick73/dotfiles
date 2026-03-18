#!/bin/bash

# watch-waybar.sh — starts waybar and keeps it alive
#
# Health check mechanism:
#   We send SIGRTMIN+8 to the waybar process (a "ping"). The custom/healthcheck
#   module in config.jsonc is configured to respond to signal 8 by writing to
#   /tmp/waybar-pong. If the pong file doesn't appear within PING_TIMEOUT
#   seconds, waybar is considered frozen and is restarted.
#
#   Signal 8 (SIGRTMIN+8) is reserved for this purpose — don't assign it to
#   any other custom module.

WAYBAR_CONFIG=~/.config/waybar/config.jsonc
WAYBAR_STYLE=~/.config/waybar/style.css
WAYBAR_CONFIG_DIR=$(dirname "$WAYBAR_CONFIG")

PONG_FILE=/tmp/waybar-pong
PING_INTERVAL=15    # seconds between health checks
PING_TIMEOUT=5      # seconds to wait for a pong before declaring waybar frozen
STARTUP_GRACE=20    # seconds to wait after starting before health checks begin


# ── Waybar lifecycle ──────────────────────────────────────────────────────────

start_waybar() {
    rm -f "$PONG_FILE"
    waybar &
}

stop_waybar() {
    pkill -x waybar
    sleep 0.5
}

restart_waybar() {
    stop_waybar
    start_waybar
}


# ── Health check ──────────────────────────────────────────────────────────────

# Send a ping signal to waybar and wait for a pong response.
# Returns 0 if waybar responds, 1 if it doesn't within PING_TIMEOUT seconds.
ping_waybar() {
    local waybar_pid
    waybar_pid=$(pgrep -x waybar) || return 1   # process doesn't exist

    rm -f "$PONG_FILE"
    kill -SIGRTMIN+8 "$waybar_pid"

    local waited=0
    while [[ $waited -lt $PING_TIMEOUT ]]; do
        sleep 0.5
        waited=$(( waited + 1 ))
        [[ -f "$PONG_FILE" ]] && return 0   # got a pong
    done

    return 1   # no pong — waybar is frozen
}


# ── Config file watcher ───────────────────────────────────────────────────────

# Restart waybar when config.jsonc or style.css are saved.
watch_config() {
    while true; do
        local changed
        changed=$(inotifywait -e close_write -e moved_to --format '%f' "$WAYBAR_CONFIG_DIR" 2>/dev/null)
        if [[ "$changed" == "config.jsonc" ]] || [[ "$changed" == "style.css" ]]; then
            restart_waybar
        fi
    done
}


# ── Main ──────────────────────────────────────────────────────────────────────

start_waybar
watch_config &

sleep "$STARTUP_GRACE"

while true; do
    if ! ping_waybar; then
        restart_waybar
        sleep "$STARTUP_GRACE"
    fi
    sleep "$PING_INTERVAL"
done
