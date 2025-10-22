#!/bin/bash
# Window Rounding Controller

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

OPTIONS="No Rounding (0)
Subtle (4)
Light (8)
Medium (12)
Round (16)
Very Round (20)
Custom (0-30)
Back"

selected=$(echo "$OPTIONS" | fuzzel --dmenu --prompt="Window Rounding: " --lines=8)

case "$selected" in
    *"No Rounding"*)
        hyprctl keyword decoration:rounding 0
        notify-send "Window Rounding" "Set to 0 (no rounding)"
        ;;
    *Subtle*)
        hyprctl keyword decoration:rounding 4
        notify-send "Window Rounding" "Set to 4 (subtle)"
        ;;
    *Light*)
        hyprctl keyword decoration:rounding 8
        notify-send "Window Rounding" "Set to 8 (light)"
        ;;
    *Medium*)
        hyprctl keyword decoration:rounding 12
        notify-send "Window Rounding" "Set to 12 (medium)"
        ;;
    *"Round"*)
        hyprctl keyword decoration:rounding 16
        notify-send "Window Rounding" "Set to 16 (round)"
        ;;
    *"Very Round"*)
        hyprctl keyword decoration:rounding 20
        notify-send "Window Rounding" "Set to 20 (very round)"
        ;;
    *Custom*)
        custom=$(echo "" | fuzzel --dmenu --prompt="Enter value (0-30): ")
        if [ -n "$custom" ] && [ "$custom" -ge 0 ] && [ "$custom" -le 30 ] 2>/dev/null; then
            hyprctl keyword decoration:rounding "$custom"
            notify-send "Window Rounding" "Set to $custom (custom)"
        else
            notify-send "Invalid Input" "Please enter a number between 0 and 30"
        fi
        ;;
    *Back)
        exec "$SCRIPT_DIR/menu.sh"
        ;;
esac
