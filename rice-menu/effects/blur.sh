#!/bin/bash
# Blur Settings Controller

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

OPTIONS="Toggle On/Off
Blur Strength
Blur Quality
Back"

selected=$(echo "$OPTIONS" | fuzzel --dmenu --prompt="Blur Settings: " --lines=4)

case "$selected" in
    *Toggle*)
        current=$(hyprctl getoption decoration:blur:enabled -j | grep -o '"int": [01]' | awk '{print $2}')
        if [ "$current" = "1" ]; then
            hyprctl keyword decoration:blur:enabled false
            notify-send "Blur" "Blur disabled"
        else
            hyprctl keyword decoration:blur:enabled true
            notify-send "Blur" "Blur enabled"
        fi
        ;;

    *Strength*)
        SIZE_OPTIONS="Light (3)
Medium (5)
Strong (7)
Maximum (10)
Custom (1-20)"
        size=$(echo "$SIZE_OPTIONS" | fuzzel --dmenu --prompt="Blur Strength: " --lines=5)
        case "$size" in
            *Light*) 
                hyprctl keyword decoration:blur:size 3
                notify-send "Blur Strength" "Set to Light (3)"
                ;;
            *Medium*) 
                hyprctl keyword decoration:blur:size 5
                notify-send "Blur Strength" "Set to Medium (5)"
                ;;
            *Strong*) 
                hyprctl keyword decoration:blur:size 7
                notify-send "Blur Strength" "Set to Strong (7)"
                ;;
            *Maximum*) 
                hyprctl keyword decoration:blur:size 10
                notify-send "Blur Strength" "Set to Maximum (10)"
                ;;
            *Custom*)
                custom=$(echo "" | fuzzel --dmenu --prompt="Enter blur size (1-20): ")
                if [ -n "$custom" ] && [ "$custom" -ge 1 ] && [ "$custom" -le 20 ] 2>/dev/null; then
                    hyprctl keyword decoration:blur:size "$custom"
                    notify-send "Blur Strength" "Set to $custom (custom)"
                else
                    notify-send "Invalid Input" "Please enter a number between 1 and 20"
                fi
                ;;
        esac
        ;;

    *Quality*)
        QUALITY_OPTIONS="Low (1 pass)
Medium (2 passes)
High (3 passes)
Custom (1-4 passes)"
        quality=$(echo "$QUALITY_OPTIONS" | fuzzel --dmenu --prompt="Blur Quality: " --lines=4)
        case "$quality" in
            *Low*) 
                hyprctl keyword decoration:blur:passes 1
                notify-send "Blur Quality" "Set to Low (1 pass)"
                ;;
            *Medium*) 
                hyprctl keyword decoration:blur:passes 2
                notify-send "Blur Quality" "Set to Medium (2 passes)"
                ;;
            *High*) 
                hyprctl keyword decoration:blur:passes 3
                notify-send "Blur Quality" "Set to High (3 passes - GPU intensive)"
                ;;
            *Custom*)
                custom=$(echo "" | fuzzel --dmenu --prompt="Enter passes (1-4): ")
                if [ -n "$custom" ] && [ "$custom" -ge 1 ] && [ "$custom" -le 4 ] 2>/dev/null; then
                    hyprctl keyword decoration:blur:passes "$custom"
                    notify-send "Blur Quality" "Set to $custom passes (custom)"
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
