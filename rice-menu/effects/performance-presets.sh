#!/bin/bash
# Performance Presets

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

OPTIONS="Battery Saver (No effects)
Balanced (Recommended)
Performance (Full effects)
Gaming (Minimal for FPS)
Back"

selected=$(echo "$OPTIONS" | fuzzel --dmenu --prompt="Performance Presets: " --lines=5)

case "$selected" in
    *"Battery Saver"*)
        # Disable all effects for maximum battery life
        hyprctl keyword decoration:rounding 0
        hyprctl keyword decoration:blur:enabled false
        hyprctl keyword decoration:shadow:enabled false
        hyprctl keyword decoration:active_opacity 1.0
        hyprctl keyword decoration:inactive_opacity 1.0
        hyprctl keyword animations:enabled false
        notify-send "Performance Preset" "Battery Saver enabled - All effects disabled"
        ;;

    *Balanced*)
        # Moderate effects for good balance
        hyprctl keyword decoration:rounding 8
        hyprctl keyword decoration:blur:enabled true
        hyprctl keyword decoration:blur:size 3
        hyprctl keyword decoration:blur:passes 1
        hyprctl keyword decoration:shadow:enabled true
        hyprctl keyword decoration:shadow:range 4
        hyprctl keyword decoration:shadow:render_power 2
        hyprctl keyword decoration:active_opacity 1.0
        hyprctl keyword decoration:inactive_opacity 0.95
        hyprctl keyword animations:enabled true
        hyprctl keyword animations:speed 1.0
        notify-send "Performance Preset" "Balanced enabled - Moderate effects"
        ;;

    *Performance*)
        # Full visual effects
        hyprctl keyword decoration:rounding 12
        hyprctl keyword decoration:blur:enabled true
        hyprctl keyword decoration:blur:size 5
        hyprctl keyword decoration:blur:passes 2
        hyprctl keyword decoration:shadow:enabled true
        hyprctl keyword decoration:shadow:range 8
        hyprctl keyword decoration:shadow:render_power 3
        hyprctl keyword decoration:active_opacity 1.0
        hyprctl keyword decoration:inactive_opacity 0.9
        hyprctl keyword animations:enabled true
        hyprctl keyword animations:speed 1.0
        notify-send "Performance Preset" "Performance enabled - Full visual effects"
        ;;

    *Gaming*)
        # Minimal effects for maximum FPS
        hyprctl keyword decoration:rounding 4
        hyprctl keyword decoration:blur:enabled false
        hyprctl keyword decoration:shadow:enabled false
        hyprctl keyword decoration:active_opacity 1.0
        hyprctl keyword decoration:inactive_opacity 1.0
        hyprctl keyword animations:enabled true
        hyprctl keyword animations:speed 2.0
        notify-send "Performance Preset" "Gaming enabled - Minimal effects, fast animations"
        ;;

    *Back)
        exec "$SCRIPT_DIR/menu.sh"
        ;;
esac
