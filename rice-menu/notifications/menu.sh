#!/bin/bash
# Daemon-Aware Notifications Menu
# Supports both Mako and SwayNC

STATE_FILE="$HOME/.config/omarchy/notification-daemon.state"

# Get current daemon
get_current_daemon() {
    if [ -f "$STATE_FILE" ]; then
        cat "$STATE_FILE"
    else
        echo "mako"
    fi
}

CURRENT_DAEMON=$(get_current_daemon)

# Show current daemon in options
OPTIONS=" Notification System: $CURRENT_DAEMON
 Change Timeout
 Change Position
 Change Border Radius
 Test Notifications
 Toggle Do Not Disturb
 Edit Config Directly
 Back to Main Menu"

selected=$(echo "$OPTIONS" | fuzzel --dmenu --prompt=" Notifications: " --lines=8)

case "$selected" in
    *"Notification System"*)
        # Show info about current system
        notify-send "Current Notification System" "Using: $CURRENT_DAEMON\n\nTo switch, go to Advanced → Switch Notification System" -u normal
        ;;
    *"Change Timeout")
        TIMEOUTS="3000 (3 seconds)
5000 (5 seconds)
7000 (7 seconds)
10000 (10 seconds)
0 (No timeout)"

        TIMEOUT=$(echo "$TIMEOUTS" | fuzzel --dmenu --prompt=" Select Timeout: ")

        if [ -n "$TIMEOUT" ]; then
            TIME_VALUE=$(echo "$TIMEOUT" | awk '{print $1}')

            if [ "$CURRENT_DAEMON" = "mako" ]; then
                sed -i "s/^default-timeout=.*/default-timeout=$TIME_VALUE/" ~/.config/mako/config
                makoctl reload
            else
                # Update SwayNC config
                jq ".timeout = $TIME_VALUE" ~/.config/swaync/config.json > /tmp/swaync-config.tmp
                mv /tmp/swaync-config.tmp ~/.config/swaync/config.json
                swaync-client --reload-config
            fi

            notify-send "Notification Timeout" "Set to $TIME_VALUE ms"
        fi
        ;;
    *"Change Position")
        if [ "$CURRENT_DAEMON" = "mako" ]; then
            POSITIONS=" Top-Right
 Top-Left
 Top-Center
 Bottom-Right
 Bottom-Left
 Bottom-Center"

            POSITION=$(echo "$POSITIONS" | fuzzel --dmenu --prompt=" Select Position: ")

            if [ -n "$POSITION" ]; then
                POS_VALUE=$(echo "$POSITION" | xargs | tr '[:upper:]' '[:lower:]' | tr '-' '-')
                sed -i "s/^anchor=.*/anchor=$POS_VALUE/" ~/.config/mako/config
                makoctl reload
                notify-send "Notification Position" "Changed to $POS_VALUE"
            fi
        else
            # SwayNC uses different positioning
            POSITIONS=" Top Right
 Top Left
 Top Center
 Bottom Right
 Bottom Left
 Bottom Center"

            POSITION=$(echo "$POSITIONS" | fuzzel --dmenu --prompt=" Select Position: ")

            if [ -n "$POSITION" ]; then
                # Convert to SwayNC format (e.g., "top", "bottom")
                POS_VERT=$(echo "$POSITION" | awk '{print tolower($2)}')
                POS_HORIZ=$(echo "$POSITION" | awk '{print tolower($3)}')

                # Update SwayNC position in config.json
                jq ".positionX = \"$POS_HORIZ\" | .positionY = \"$POS_VERT\"" ~/.config/swaync/config.json > /tmp/swaync-config.tmp
                mv /tmp/swaync-config.tmp ~/.config/swaync/config.json
                swaync-client --reload-config

                notify-send "Notification Position" "Changed to $POSITION"
            fi
        fi
        ;;
    *"Change Border Radius")
        RADIUS="0
6
8
10
12
15
20"

        RAD=$(echo "$RADIUS" | fuzzel --dmenu --prompt=" Border Radius (px): ")

        if [ -n "$RAD" ]; then
            if [ "$CURRENT_DAEMON" = "mako" ]; then
                sed -i "s/^border-radius=.*/border-radius=$RAD/" ~/.config/mako/config
                makoctl reload
            else
                # For SwayNC, we need to update the CSS variable
                # This is more complex, so we'll just notify the user to edit manually
                notify-send "Border Radius" "For SwayNC, please edit ~/.config/swaync/style.css manually to change border-radius values"
            fi

            notify-send "Border Radius" "Set to ${RAD}px"
        fi
        ;;
    *"Test Notifications")
        TEST_OPTIONS=" Normal
 Low Priority
 Critical
 With Icon
 Long Message"

        TEST=$(echo "$TEST_OPTIONS" | fuzzel --dmenu --prompt=" Test Type: ")

        case "$TEST" in
            *"Normal")
                notify-send "Test Notification" "This is a normal priority notification" -u normal
                ;;
            *"Low")
                notify-send "Test Notification" "This is a low priority notification" -u low
                ;;
            *"Critical")
                notify-send "CRITICAL" "This is a critical notification!" -u critical
                ;;
            *"With Icon")
                notify-send -i /usr/share/pixmaps/archlinux-logo.png "Test with Icon" "Notification with Arch Linux logo icon"
                ;;
            *"Long Message")
                notify-send "Long Message Test" "This is a much longer notification message to test how notifications handle multiple lines of text and wrapping behavior in the notification display area."
                ;;
        esac
        ;;
    *"Toggle Do Not Disturb")
        if [ "$CURRENT_DAEMON" = "mako" ]; then
            if makoctl mode | grep -q "do-not-disturb"; then
                makoctl mode -r do-not-disturb
                notify-send "Do Not Disturb" "Disabled"
            else
                makoctl mode -a do-not-disturb
                notify-send "Do Not Disturb" "Enabled"
            fi
        else
            # SwayNC DND toggle
            swaync-client -d -sw
        fi
        ;;
    *"Edit Config Directly")
        if [ "$CURRENT_DAEMON" = "mako" ]; then
            alacritty -e nvim ~/.config/mako/config
        else
            # Let user choose which SwayNC config to edit
            CONFIG_CHOICE=$(echo -e " config.json\n style.css" | fuzzel --dmenu --prompt=" Select Config: ")

            if [ -n "$CONFIG_CHOICE" ]; then
                CONFIG_FILE=$(echo "$CONFIG_CHOICE" | xargs)
                alacritty -e nvim ~/.config/swaync/$CONFIG_FILE
            fi
        fi
        ;;
    *"Back to Main Menu")
        ~/.config/rice-menu/rice-control.sh
        ;;
esac
