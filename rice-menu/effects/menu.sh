#!/bin/bash
# Effects Menu

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

OPTIONS="Window Rounding
Blur Settings
Shadows
Opacity
Animations
Performance Presets
Reload Hyprland
Back"

selected=$(echo "$OPTIONS" | fuzzel --dmenu --prompt="Effects: " --lines=8)

case "$selected" in
    *Rounding*)
        "$SCRIPT_DIR/rounding.sh"
        ;;
    *Blur*)
        "$SCRIPT_DIR/blur.sh"
        ;;
    *Shadows*)
        "$SCRIPT_DIR/shadows.sh"
        ;;
    *Opacity*)
        "$SCRIPT_DIR/opacity.sh"
        ;;
    *Animations*)
        "$SCRIPT_DIR/animations.sh"
        ;;
    *Performance*)
        "$SCRIPT_DIR/performance-presets.sh"
        ;;
    *Reload*)
        hyprctl reload
        notify-send "Hyprland Reloaded" "Configuration has been reloaded"
        ;;
    *Back)
        exec ~/.config/rice-menu/rice-control.sh
        ;;
esac
