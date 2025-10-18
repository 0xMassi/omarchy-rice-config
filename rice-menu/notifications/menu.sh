#!/bin/bash
# Notifications Menu

OPTIONS=" Change Timeout
 Change Position
 Change Border Radius
 Test Notifications
 Toggle Do Not Disturb
 Edit Config Directly
 Back to Main Menu"

selected=$(echo "$OPTIONS" | fuzzel --dmenu --prompt=" Notifications: " --lines=7)

case "$selected" in
    *"Change Timeout")
        TIMEOUTS="3000 (3 seconds)
5000 (5 seconds)
7000 (7 seconds)
10000 (10 seconds)
0 (No timeout)"
        
        TIMEOUT=$(echo "$TIMEOUTS" | fuzzel --dmenu --prompt=" Select Timeout: ")
        
        if [ -n "$TIMEOUT" ]; then
            TIME_VALUE=$(echo "$TIMEOUT" | awk '{print $1}')
            sed -i "s/^default-timeout=.*/default-timeout=$TIME_VALUE/" ~/.config/mako/config
            makoctl reload
            notify-send "Notification Timeout" "Set to $TIME_VALUE ms"
        fi
        ;;
    *"Change Position")
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
            sed -i "s/^border-radius=.*/border-radius=$RAD/" ~/.config/mako/config
            makoctl reload
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
                notify-send -i emblem-default "Test with Icon" "Notification with an icon"
                ;;
            *"Long Message")
                notify-send "Long Message Test" "This is a much longer notification message to test how notifications handle multiple lines of text and wrapping behavior in the notification display area."
                ;;
        esac
        ;;
    *"Toggle Do Not Disturb")
        if makoctl mode | grep -q "do-not-disturb"; then
            makoctl mode -r do-not-disturb
            notify-send "Do Not Disturb" "Disabled"
        else
            makoctl mode -a do-not-disturb
            notify-send "Do Not Disturb" "Enabled"
        fi
        ;;
    *"Edit Config Directly")
        alacritty -e nvim ~/.config/mako/config
        ;;
    *"Back to Main Menu")
        ~/.config/rice-menu/rice-control.sh
        ;;
esac
