#!/bin/bash
# Notification Daemon Switcher
# Switches between Mako and SwayNC notification systems

STATE_FILE="$HOME/.config/omarchy/notification-daemon.state"
AUTOSTART_FILE="$HOME/.config/hypr/autostart.conf"

# Ensure state file directory exists
mkdir -p "$(dirname "$STATE_FILE")"

# Function to get current daemon
get_current_daemon() {
    if [ -f "$STATE_FILE" ]; then
        cat "$STATE_FILE"
    else
        # Default to mako if no state file exists
        echo "mako"
    fi
}

# Function to set daemon state
set_daemon_state() {
    echo "$1" > "$STATE_FILE"
}

# Function to stop all notification daemons
stop_all_daemons() {
    # Stop mako
    if pgrep -x mako > /dev/null; then
        killall mako 2>/dev/null
    fi

    # Stop swaync
    if pgrep -x swaync > /dev/null; then
        killall swaync 2>/dev/null
    fi

    sleep 0.5
}

# Function to start daemon
start_daemon() {
    local daemon="$1"

    case "$daemon" in
        "mako")
            /usr/bin/mako &
            ;;
        "swaync")
            /usr/bin/swaync &
            ;;
    esac

    sleep 0.5
}

# Function to update autostart
update_autostart() {
    local daemon="$1"

    # Remove existing notification daemon lines
    sed -i '/# Notification daemon/d' "$AUTOSTART_FILE"
    sed -i '/exec-once.*mako/d' "$AUTOSTART_FILE"
    sed -i '/exec-once.*swaync/d' "$AUTOSTART_FILE"

    # Add new daemon to autostart
    echo "" >> "$AUTOSTART_FILE"
    echo "# Notification daemon" >> "$AUTOSTART_FILE"

    case "$daemon" in
        "mako")
            echo "exec-once = /usr/bin/mako" >> "$AUTOSTART_FILE"
            ;;
        "swaync")
            echo "exec-once = /usr/bin/swaync" >> "$AUTOSTART_FILE"
            ;;
    esac
}

# Main switching logic
if [ "$1" = "switch" ]; then
    current_daemon=$(get_current_daemon)

    # Determine target daemon
    if [ "$current_daemon" = "mako" ]; then
        target_daemon="swaync"
    else
        target_daemon="mako"
    fi

    # Show confirmation
    CONFIRM=$(echo -e "Yes\nNo" | fuzzel --dmenu --prompt=" Switch to $target_daemon? ")

    if [ "$CONFIRM" != "Yes" ]; then
        exit 0
    fi

    notify-send "Notification System" "Switching to $target_daemon..." -t 2000

    # Stop all daemons
    stop_all_daemons

    # Update state
    set_daemon_state "$target_daemon"

    # Update autostart
    update_autostart "$target_daemon"

    # Start new daemon
    start_daemon "$target_daemon"

    # Send success notification
    notify-send "Notification System" "Switched to $target_daemon successfully" -u normal

elif [ "$1" = "status" ]; then
    # Just return the current daemon
    get_current_daemon

elif [ "$1" = "init" ]; then
    # Initialize the system based on what's currently running
    if pgrep -x swaync > /dev/null; then
        set_daemon_state "swaync"
        update_autostart "swaync"
    else
        set_daemon_state "mako"
        update_autostart "mako"
    fi
    echo "Initialized notification system state"

else
    # Show current status and options
    current_daemon=$(get_current_daemon)

    if [ "$current_daemon" = "mako" ]; then
        other_daemon="SwayNC"
    else
        other_daemon="Mako"
    fi

    OPTIONS=" Current: $current_daemon
 Switch to $other_daemon
 Back"

    selected=$(echo "$OPTIONS" | fuzzel --dmenu --prompt=" Notification System: ")

    case "$selected" in
        *"Switch to"*)
            "$0" switch
            ;;
        *"Back")
            ~/.config/rice-menu/advanced/menu.sh
            ;;
    esac
fi
