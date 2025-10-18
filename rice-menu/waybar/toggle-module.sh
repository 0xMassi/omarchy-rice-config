#!/bin/bash
# Toggle Waybar Module Enable/Disable

CONFIG="/home/0xMassi/.config/waybar/config.jsonc"
MODULE="$1"

if [ -z "$MODULE" ]; then
    echo "Usage: toggle-module.sh <module-name>"
    exit 1
fi

# Check if module is currently commented out
if grep -q "^[[:space:]]*//[[:space:]]*\"$MODULE\"" "$CONFIG"; then
    # Module is disabled, enable it
    sed -i "s|^[[:space:]]*//[[:space:]]*\(\"$MODULE\"\)|        \1|" "$CONFIG"
    echo "enabled"
else
    # Module is enabled, disable it
    sed -i "s|^[[:space:]]*\(\"$MODULE\"\)|        // \1|" "$CONFIG"
    echo "disabled"
fi
