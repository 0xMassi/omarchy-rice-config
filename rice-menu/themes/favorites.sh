#!/bin/bash
# Theme Favorites Manager

FAVORITES_FILE="$HOME/.config/rice-menu/themes/favorites.txt"
mkdir -p "$(dirname "$FAVORITES_FILE")"
touch "$FAVORITES_FILE"

# Add theme to favorites
add_favorite() {
    local theme="$1"
    if ! grep -q "^$theme$" "$FAVORITES_FILE"; then
        echo "$theme" >> "$FAVORITES_FILE"
        echo "Added $theme to favorites"
    else
        echo "$theme is already in favorites"
    fi
}

# Remove theme from favorites
remove_favorite() {
    local theme="$1"
    sed -i "/^${theme}$/d" "$FAVORITES_FILE"
    echo "Removed $theme from favorites"
}

# Check if theme is favorite
is_favorite() {
    local theme="$1"
    grep -q "^$theme$" "$FAVORITES_FILE"
}

# List all favorites
list_favorites() {
    if [ -s "$FAVORITES_FILE" ]; then
        cat "$FAVORITES_FILE"
    fi
}

# Toggle favorite status
toggle_favorite() {
    local theme="$1"
    if is_favorite "$theme"; then
        remove_favorite "$theme"
        echo "removed"
    else
        add_favorite "$theme"
        echo "added"
    fi
}

# Main command dispatcher
case "$1" in
    add)
        add_favorite "$2"
        ;;
    remove)
        remove_favorite "$2"
        ;;
    toggle)
        toggle_favorite "$2"
        ;;
    is_favorite)
        is_favorite "$2"
        ;;
    list)
        list_favorites
        ;;
    *)
        echo "Usage: favorites.sh {add|remove|toggle|is_favorite|list} <theme-name>"
        exit 1
        ;;
esac
