#!/bin/bash
# Workspace Profile Manager

PROFILES_DIR="$HOME/.config/rice-menu/profiles/saved"
mkdir -p "$PROFILES_DIR"

# Save current workspace as profile
save_profile() {
    local profile_name="$1"
    local profile_dir="$PROFILES_DIR/$profile_name"

    mkdir -p "$profile_dir"

    # Get current theme
    local current_theme=$(readlink ~/.config/omarchy/current/theme | xargs basename)

    # Get current wallpaper
    local current_wallpaper=$(readlink ~/.config/omarchy/current/background 2>/dev/null)

    # Get Hyprland workspace layout (active workspaces and windows)
    local workspace_layout=$(hyprctl clients -j)

    # Save profile info
    cat > "$profile_dir/profile.conf" << EOF
# Workspace Profile: $profile_name
# Created: $(date)

THEME="$current_theme"
WALLPAPER="$current_wallpaper"
EOF

    # Save workspace layout
    echo "$workspace_layout" > "$profile_dir/layout.json"

    # Copy wallpaper if it exists
    if [ -f "$current_wallpaper" ]; then
        cp "$current_wallpaper" "$profile_dir/wallpaper.$(basename "$current_wallpaper" | grep -oE '\.[^.]+$')"
    fi

    echo "Profile '$profile_name' saved successfully"
    echo "  Theme: $current_theme"
    echo "  Wallpaper: $(basename "$current_wallpaper" 2>/dev/null || echo "none")"
}

# Load workspace profile
load_profile() {
    local profile_name="$1"
    local profile_dir="$PROFILES_DIR/$profile_name"

    if [ ! -f "$profile_dir/profile.conf" ]; then
        echo "Profile '$profile_name' not found"
        return 1
    fi

    # Source profile config
    source "$profile_dir/profile.conf"

    echo "Loading profile: $profile_name"

    # Apply theme
    if [ -n "$THEME" ] && [ -d "$HOME/.config/omarchy/themes/$THEME" ]; then
        echo "  Applying theme: $THEME"
        omarchy-theme-set "$THEME"
    fi

    # Apply wallpaper
    if [ -n "$WALLPAPER" ] && [ -f "$WALLPAPER" ]; then
        echo "  Setting wallpaper"
        pkill swaybg
        swaybg -i "$WALLPAPER" -m fill &
    elif [ -f "$profile_dir/wallpaper."* ]; then
        local saved_wallpaper=$(ls "$profile_dir/wallpaper."* 2>/dev/null | head -1)
        if [ -f "$saved_wallpaper" ]; then
            echo "  Setting saved wallpaper"
            pkill swaybg
            swaybg -i "$saved_wallpaper" -m fill &
        fi
    fi

    echo "Profile '$profile_name' loaded successfully"
}

# List all profiles
list_profiles() {
    if [ -d "$PROFILES_DIR" ]; then
        for profile in "$PROFILES_DIR"/*; do
            if [ -d "$profile" ] && [ -f "$profile/profile.conf" ]; then
                basename "$profile"
            fi
        done
    fi
}

# Delete profile
delete_profile() {
    local profile_name="$1"
    local profile_dir="$PROFILES_DIR/$profile_name"

    if [ -d "$profile_dir" ]; then
        rm -rf "$profile_dir"
        echo "Profile '$profile_name' deleted"
    else
        echo "Profile '$profile_name' not found"
    fi
}

# Get profile info
get_profile_info() {
    local profile_name="$1"
    local profile_dir="$PROFILES_DIR/$profile_name"

    if [ -f "$profile_dir/profile.conf" ]; then
        source "$profile_dir/profile.conf"
        echo "Profile: $profile_name"
        echo "Theme: $THEME"
        echo "Wallpaper: $(basename "$WALLPAPER" 2>/dev/null || echo "none")"
    fi
}

# Main command dispatcher
case "$1" in
    save)
        save_profile "$2"
        ;;
    load)
        load_profile "$2"
        ;;
    list)
        list_profiles
        ;;
    delete)
        delete_profile "$2"
        ;;
    info)
        get_profile_info "$2"
        ;;
    *)
        echo "Usage: profile-manager.sh {save|load|list|delete|info} <profile-name>"
        exit 1
        ;;
esac
