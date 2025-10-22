#!/bin/bash
# Animations Controller

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

OPTIONS="Toggle On/Off
Animation Speed
Back"

selected=$(echo "$OPTIONS" | fuzzel --dmenu --prompt="Animations: " --lines=3)

case "$selected" in
    *Toggle*)
        current=$(hyprctl getoption animations:enabled -j | grep -o '"int": [01]' | awk '{print $2}')
        if [ "$current" = "1" ]; then
            hyprctl keyword animations:enabled false
            notify-send "Animations" "Animations disabled"
        else
            hyprctl keyword animations:enabled true
            notify-send "Animations" "Animations enabled"
        fi
        ;;

    *Speed*)
        SPEED_OPTIONS="Very Fast (0.5x time)
Fast (0.75x time)
Normal (1x time)
Slow (1.5x time)
Very Slow (2x time)
Custom (0.1-3.0)"
        speed=$(echo "$SPEED_OPTIONS" | fuzzel --dmenu --prompt="Animation Speed: " --lines=6)
        case "$speed" in
            *"Very Fast"*) 
                hyprctl keyword animations:speed 2.0
                notify-send "Animation Speed" "Set to Very Fast (2x speed)"
                ;;
            *Fast*) 
                hyprctl keyword animations:speed 1.33
                notify-send "Animation Speed" "Set to Fast (1.33x speed)"
                ;;
            *Normal*) 
                hyprctl keyword animations:speed 1.0
                notify-send "Animation Speed" "Set to Normal (1x speed)"
                ;;
            *"Slow"*) 
                hyprctl keyword animations:speed 0.67
                notify-send "Animation Speed" "Set to Slow (0.67x speed)"
                ;;
            *"Very Slow"*) 
                hyprctl keyword animations:speed 0.5
                notify-send "Animation Speed" "Set to Very Slow (0.5x speed)"
                ;;
            *Custom*)
                custom=$(echo "" | fuzzel --dmenu --prompt="Enter speed multiplier (0.1-3.0): ")
                # Validate it's a number and in range
                if echo "$custom" | grep -qE '^[0-9]+\.?[0-9]*$' && \
                   awk -v val="$custom" 'BEGIN{exit !(val>=0.1 && val<=3.0)}'; then
                    hyprctl keyword animations:speed "$custom"
                    notify-send "Animation Speed" "Set to ${custom}x speed (custom)"
                else
                    notify-send "Invalid Input" "Please enter a number between 0.1 and 3.0"
                fi
                ;;
        esac
        ;;

    *Back)
        exec "$SCRIPT_DIR/menu.sh"
        ;;
esac
