#!/bin/bash
# Shadows Configuration

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

OPTIONS="Toggle On/Off
Shadow Size
Shadow Intensity
Back"

selected=$(echo "$OPTIONS" | fuzzel --dmenu --prompt="Shadows: " --lines=4)

case "$selected" in
    *Toggle*)
        current=$(hyprctl getoption decoration:shadow:enabled -j | grep -o '"int": [01]' | awk '{print $2}')
        if [ "$current" = "1" ]; then
            hyprctl keyword decoration:shadow:enabled false
            notify-send "Shadows" "Shadows disabled"
        else
            hyprctl keyword decoration:shadow:enabled true
            notify-send "Shadows" "Shadows enabled"
        fi
        ;;

    *Size*)
        SIZE_OPTIONS="Small (4)
Medium (8)
Large (12)
Huge (16)
Custom (0-30)"
        size=$(echo "$SIZE_OPTIONS" | fuzzel --dmenu --prompt="Shadow Size: " --lines=5)
        case "$size" in
            *Small*) 
                hyprctl keyword decoration:shadow:range 4
                notify-send "Shadow Size" "Set to Small (4)"
                ;;
            *Medium*) 
                hyprctl keyword decoration:shadow:range 8
                notify-send "Shadow Size" "Set to Medium (8)"
                ;;
            *Large*) 
                hyprctl keyword decoration:shadow:range 12
                notify-send "Shadow Size" "Set to Large (12)"
                ;;
            *Huge*) 
                hyprctl keyword decoration:shadow:range 16
                notify-send "Shadow Size" "Set to Huge (16)"
                ;;
            *Custom*)
                custom=$(echo "" | fuzzel --dmenu --prompt="Enter shadow range (0-30): ")
                if [ -n "$custom" ] && [ "$custom" -ge 0 ] && [ "$custom" -le 30 ] 2>/dev/null; then
                    hyprctl keyword decoration:shadow:range "$custom"
                    notify-send "Shadow Size" "Set to $custom (custom)"
                else
                    notify-send "Invalid Input" "Please enter a number between 0 and 30"
                fi
                ;;
        esac
        ;;

    *Intensity*)
        INT_OPTIONS="Soft (1)
Normal (2)
Strong (3)
Very Strong (4)
Custom (1-4)"
        intensity=$(echo "$INT_OPTIONS" | fuzzel --dmenu --prompt="Shadow Intensity: " --lines=5)
        case "$intensity" in
            *Soft*) 
                hyprctl keyword decoration:shadow:render_power 1
                notify-send "Shadow Intensity" "Set to Soft (1)"
                ;;
            *Normal*) 
                hyprctl keyword decoration:shadow:render_power 2
                notify-send "Shadow Intensity" "Set to Normal (2)"
                ;;
            *Strong*) 
                hyprctl keyword decoration:shadow:render_power 3
                notify-send "Shadow Intensity" "Set to Strong (3)"
                ;;
            *"Very Strong"*) 
                hyprctl keyword decoration:shadow:render_power 4
                notify-send "Shadow Intensity" "Set to Very Strong (4)"
                ;;
            *Custom*)
                custom=$(echo "" | fuzzel --dmenu --prompt="Enter render power (1-4): ")
                if [ -n "$custom" ] && [ "$custom" -ge 1 ] && [ "$custom" -le 4 ] 2>/dev/null; then
                    hyprctl keyword decoration:shadow:render_power "$custom"
                    notify-send "Shadow Intensity" "Set to $custom (custom)"
                else
                    notify-send "Invalid Input" "Please enter a number between 1 and 4"
                fi
                ;;
        esac
        ;;

    *Back)
        exec "$SCRIPT_DIR/menu.sh"
        ;;
esac
