#!/bin/bash
# Opacity Management

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

OPTIONS="Active Window Opacity
Inactive Window Opacity
Back"

selected=$(echo "$OPTIONS" | fuzzel --dmenu --prompt="Opacity: " --lines=3)

case "$selected" in
    *Active*)
        OPACITY_OPTIONS="Fully Opaque (1.0)
Slightly Transparent (0.95)
Semi-Transparent (0.9)
Transparent (0.85)
Very Transparent (0.8)
Custom (0.1-1.0)"
        opacity=$(echo "$OPACITY_OPTIONS" | fuzzel --dmenu --prompt="Active Opacity: " --lines=6)
        case "$opacity" in
            *"Fully Opaque"*) 
                hyprctl keyword decoration:active_opacity 1.0
                notify-send "Active Opacity" "Set to 1.0 (fully opaque)"
                ;;
            *Slightly*) 
                hyprctl keyword decoration:active_opacity 0.95
                notify-send "Active Opacity" "Set to 0.95"
                ;;
            *Semi*) 
                hyprctl keyword decoration:active_opacity 0.9
                notify-send "Active Opacity" "Set to 0.9"
                ;;
            *"Transparent"*) 
                hyprctl keyword decoration:active_opacity 0.85
                notify-send "Active Opacity" "Set to 0.85"
                ;;
            *"Very Transparent"*) 
                hyprctl keyword decoration:active_opacity 0.8
                notify-send "Active Opacity" "Set to 0.8"
                ;;
            *Custom*)
                custom=$(echo "" | fuzzel --dmenu --prompt="Enter opacity (0.1-1.0): ")
                # Validate it's a number and in range
                if echo "$custom" | grep -qE '^0?\.[0-9]+$|^1\.0$' && \
                   awk -v val="$custom" 'BEGIN{exit !(val>=0.1 && val<=1.0)}'; then
                    hyprctl keyword decoration:active_opacity "$custom"
                    notify-send "Active Opacity" "Set to $custom (custom)"
                else
                    notify-send "Invalid Input" "Please enter a decimal between 0.1 and 1.0"
                fi
                ;;
        esac
        ;;

    *Inactive*)
        OPACITY_OPTIONS="Fully Opaque (1.0)
Slightly Transparent (0.9)
Semi-Transparent (0.8)
Transparent (0.7)
Very Transparent (0.6)
Custom (0.1-1.0)"
        opacity=$(echo "$OPACITY_OPTIONS" | fuzzel --dmenu --prompt="Inactive Opacity: " --lines=6)
        case "$opacity" in
            *"Fully Opaque"*) 
                hyprctl keyword decoration:inactive_opacity 1.0
                notify-send "Inactive Opacity" "Set to 1.0 (fully opaque)"
                ;;
            *Slightly*) 
                hyprctl keyword decoration:inactive_opacity 0.9
                notify-send "Inactive Opacity" "Set to 0.9"
                ;;
            *Semi*) 
                hyprctl keyword decoration:inactive_opacity 0.8
                notify-send "Inactive Opacity" "Set to 0.8"
                ;;
            *"Transparent"*) 
                hyprctl keyword decoration:inactive_opacity 0.7
                notify-send "Inactive Opacity" "Set to 0.7"
                ;;
            *"Very Transparent"*) 
                hyprctl keyword decoration:inactive_opacity 0.6
                notify-send "Inactive Opacity" "Set to 0.6"
                ;;
            *Custom*)
                custom=$(echo "" | fuzzel --dmenu --prompt="Enter opacity (0.1-1.0): ")
                # Validate it's a number and in range
                if echo "$custom" | grep -qE '^0?\.[0-9]+$|^1\.0$' && \
                   awk -v val="$custom" 'BEGIN{exit !(val>=0.1 && val<=1.0)}'; then
                    hyprctl keyword decoration:inactive_opacity "$custom"
                    notify-send "Inactive Opacity" "Set to $custom (custom)"
                else
                    notify-send "Invalid Input" "Please enter a decimal between 0.1 and 1.0"
                fi
                ;;
        esac
        ;;

    *Back)
        exec "$SCRIPT_DIR/menu.sh"
        ;;
esac
