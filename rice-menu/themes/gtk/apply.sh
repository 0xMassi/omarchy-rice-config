#!/bin/bash
# Apply GTK Theme - Set GTK theme system-wide

THEME_NAME="$1"

if [ -z "$THEME_NAME" ]; then
    echo "Error: No theme name provided"
    exit 1
fi

notify-send "Applying GTK Theme" "Setting GTK theme to $THEME_NAME..."

# Set GTK3 theme via gsettings
gsettings set org.gnome.desktop.interface gtk-theme "$THEME_NAME" 2>/dev/null || true

# Set GTK3 theme via config file (fallback)
GTK3_CONFIG="$HOME/.config/gtk-3.0/settings.ini"
mkdir -p "$(dirname "$GTK3_CONFIG")"

if [ ! -f "$GTK3_CONFIG" ]; then
    cat > "$GTK3_CONFIG" << EOF
[Settings]
gtk-theme-name=$THEME_NAME
gtk-application-prefer-dark-theme=true
gtk-icon-theme-name=Papirus-Dark
gtk-font-name=Sans 10
gtk-cursor-theme-name=Adwaita
gtk-enable-animations=true
EOF
else
    # Update existing config
    sed -i "s/^gtk-theme-name=.*/gtk-theme-name=$THEME_NAME/" "$GTK3_CONFIG"
fi

# Set GTK4 theme (GTK4 uses gtk.css directly from ~/.config/gtk-4.0/)
# No need to set theme name, it auto-loads gtk.css

# Set dark theme preference
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true

# Reload GTK applications
# Kill and restart any running GTK apps to apply theme
# (Optional - commented out to avoid interrupting user)
# killall -HUP nautilus 2>/dev/null || true

notify-send "✓ GTK Theme Applied" "Theme: $THEME_NAME\nRestart GTK apps to see changes"
