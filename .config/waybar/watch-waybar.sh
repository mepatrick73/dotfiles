#!/bin/bash

CONFIG=~/.config/waybar/config.jsonc
STYLE=~/.config/waybar/style.css

restart_waybar() {
    pkill -x waybar
    sleep 0.5
    waybar &
}

# Watchdog 1: restart waybar if it dies on a workspace event
ipc_watchdog() {
    local socket="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
    while true; do
        socat -u "UNIX-CONNECT:$socket" STDOUT 2>/dev/null | while IFS= read -r line; do
            if [[ "$line" == workspace* ]] || [[ "$line" == focusedmon* ]]; then
                if ! pgrep -x waybar > /dev/null; then
                    sleep 0.5
                    waybar &
                fi
            fi
        done
        # socat exited — socket closed or hyprland restarted, wait and retry
        sleep 3
    done
}

# Watchdog 2: periodic restart as backstop for frozen-but-running waybar
periodic_watchdog() {
    while true; do
        sleep 1800  # 30 minutes
        if pgrep -x waybar > /dev/null; then
            restart_waybar
        fi
    done
}

# Start waybar
waybar &

# Start watchdogs in background
ipc_watchdog &
IPC_PID=$!
periodic_watchdog &
PERIODIC_PID=$!

# Watch config/style for changes and reload
while inotifywait -e close_write "$CONFIG" "$STYLE"; do
    restart_waybar
done

# Cleanup on exit
kill $IPC_PID $PERIODIC_PID 2>/dev/null
