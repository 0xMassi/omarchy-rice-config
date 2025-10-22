#!/bin/bash
# Themes Menu - With Auto-Conversion Support

THEME_DIR="$HOME/.config/omarchy/themes"
THEME_LIST="$HOME/.config/rice-menu/themes/theme-list.txt"
CONVERTER="$HOME/.config/rice-menu/themes/convert-theme.sh"
CURRENT_THEME=$(readlink ~/.config/omarchy/current/theme | xargs basename)

# Count installed and available themes
INSTALLED_COUNT=$(ls -1 "$THEME_DIR" 2>/dev/null | wc -l)
SCHEME_DIR="$HOME/.config/rice-menu/color-schemes/alacritty"
AVAILABLE_COUNT=$(ls -1 "$SCHEME_DIR"/*.toml 2>/dev/null | wc -l)
TOTAL_COUNT=$((INSTALLED_COUNT + AVAILABLE_COUNT))

FAVORITES_MANAGER="$HOME/.config/rice-menu/themes/favorites.sh"
FAVORITES_COUNT=$($FAVORITES_MANAGER list 2>/dev/null | wc -l)

OPTIONS="Switch Theme (Current: $CURRENT_THEME)
Recently Used
Favorites ($FAVORITES_COUNT)
Browse by Category
Browse Theme Backgrounds
Browse All Themes ($TOTAL_COUNT available!)
Create Custom Theme
Convert Dotfiles to Theme
Theme Guide
Export/Import
Back to Main Menu"

selected=$(echo "$OPTIONS" | fuzzel --dmenu --prompt=" Themes: " --lines=10)

case "$selected" in
    *"Switch Theme"*)
        ~/.config/rice-menu/themes/switch-theme.sh
        ;;
    *"Recently Used"*)
        ~/.config/rice-menu/themes/recently-used.sh
        ;;
    *"Favorites"*)
        FAV_OPTIONS="Switch to Favorite
Add to Favorites
Remove from Favorites
Back"

        SELECTED=$(echo "$FAV_OPTIONS" | fuzzel --dmenu --prompt=" Favorites: ")

        case "$SELECTED" in
            *"Switch"*)
                FAVORITES=$($FAVORITES_MANAGER list)
                if [ -z "$FAVORITES" ]; then
                    notify-send "No Favorites" "Add themes to favorites first"
                else
                    THEME=$(echo "$FAVORITES" | fuzzel --dmenu --prompt=" Switch to: ")
                    if [ -n "$THEME" ]; then
                        notify-send "Switching Theme" "Changing to $THEME..."
                        omarchy-theme-set "$THEME"
                        notify-send "Theme Changed" "Switched to $THEME"
                    fi
                fi
                ;;
            *"Add"*)
                ALL_THEMES=$(ls -1 "$THEME_DIR")
                THEME=$(echo "$ALL_THEMES" | fuzzel --dmenu --prompt=" Add to favorites: ")
                if [ -n "$THEME" ]; then
                    $FAVORITES_MANAGER add "$THEME"
                    notify-send "Favorite Added" "$THEME added to favorites"
                fi
                ;;
            *"Remove"*)
                FAVORITES=$($FAVORITES_MANAGER list)
                if [ -z "$FAVORITES" ]; then
                    notify-send "No Favorites" "No favorites to remove"
                else
                    THEME=$(echo "$FAVORITES" | fuzzel --dmenu --prompt=" Remove from favorites: ")
                    if [ -n "$THEME" ]; then
                        $FAVORITES_MANAGER remove "$THEME"
                        notify-send "Favorite Removed" "$THEME removed from favorites"
                    fi
                fi
                ;;
        esac
        ;;
    *"Browse by Category"*)
        ~/.config/rice-menu/themes/browse-by-category.sh
        ;;
    *"Browse Theme Backgrounds"*)
        omarchy-theme-bg-next
        notify-send "Background Changed" "Cycled to next background"
        ;;
    *"Browse All Themes"*)
        GENERATOR="$HOME/.config/rice-menu/themes/generate-from-scheme.sh"

        # List installed themes and color schemes
        THEME_OPTIONS=""

        # Add installed themes
        for theme in "$THEME_DIR"/*; do
            if [ -d "$theme" ]; then
                theme_name=$(basename "$theme")
                THEME_OPTIONS="$THEME_OPTIONS [✓ INSTALLED] $theme_name\n"
            fi
        done

        # Add available color schemes
        for scheme in "$SCHEME_DIR"/*.toml; do
            scheme_name=$(basename "$scheme" .toml)
            theme_slug=$(echo "$scheme_name" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')

            # Check if already installed
            if [ ! -d "$THEME_DIR/$theme_slug" ]; then
                THEME_OPTIONS="$THEME_OPTIONS [📦 AVAILABLE] $scheme_name\n"
            fi
        done

        SELECTED=$(echo -e "$THEME_OPTIONS" | fuzzel --dmenu --prompt=" Select Theme ($TOTAL_COUNT total): " --lines=15)

        if [[ "$SELECTED" == *"[✓ INSTALLED]"* ]]; then
            notify-send "Already Installed" "Use 'Switch Theme' to activate"

        elif [[ "$SELECTED" == *"[📦 AVAILABLE]"* ]]; then
            THEME_DISPLAY=$(echo "$SELECTED" | sed 's/.*] //')
            THEME_NAME=$(echo "$THEME_DISPLAY" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
            SCHEME_FILE="$SCHEME_DIR/${THEME_DISPLAY}.toml"

            if [ -f "$SCHEME_FILE" ]; then
                # Show preview first
                PREVIEW_OPTIONS="Preview Colors
Install & Activate
Install Only
Cancel"

                ACTION=$(echo "$PREVIEW_OPTIONS" | fuzzel --dmenu --prompt=" $THEME_DISPLAY: ")

                case "$ACTION" in
                    *"Preview"*)
                        alacritty -e ~/.config/rice-menu/themes/preview-theme.sh "$SCHEME_FILE"

                        # After preview, ask again
                        INSTALL=$(echo -e "Install & Activate\nInstall Only\nCancel" | fuzzel --dmenu --prompt=" After preview: ")

                        if [[ "$INSTALL" == *"Activate"* ]]; then
                            ACTION="Install & Activate"
                        elif [[ "$INSTALL" == *"Only"* ]]; then
                            ACTION="Install Only"
                        else
                            ACTION="Cancel"
                        fi
                        ;;
                esac

                if [[ "$ACTION" == *"Install"* ]]; then
                    notify-send "Generating Theme" "Creating $THEME_DISPLAY..."

                    # Generate theme
                    $GENERATOR "$SCHEME_FILE" "$THEME_NAME"

                    # Link to omarchy themes
                    ln -sf ~/.local/share/omarchy/themes/$THEME_NAME ~/.config/omarchy/themes/$THEME_NAME

                    if [[ "$ACTION" == *"Activate"* ]]; then
                        notify-send "Switching Theme" "Changing to $THEME_DISPLAY..."
                        omarchy-theme-set "$THEME_NAME"
                        notify-send "Theme Changed" "✓ Switched to $THEME_DISPLAY"
                    else
                        notify-send "Theme Ready" "✓ $THEME_DISPLAY installed"
                    fi
                fi
            fi
        fi
        ;;
    *"Create Custom Theme"*)
        THEME_NAME=$(echo "" | fuzzel --dmenu --prompt=" New theme name: ")
        
        if [ -n "$THEME_NAME" ]; then
            THEME_NAME=$(echo "$THEME_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
            CUSTOM_DIR="$HOME/.local/share/omarchy/themes/$THEME_NAME"
            
            mkdir -p "$CUSTOM_DIR/backgrounds"
            cp -r ~/.config/omarchy/current/theme/* "$CUSTOM_DIR/" 2>/dev/null
            ln -sf "$CUSTOM_DIR" "$THEME_DIR/$THEME_NAME"
            
            notify-send "✓ Theme Created" "$THEME_NAME created at: $CUSTOM_DIR"
        fi
        ;;
    *"Convert Dotfiles"*)
        notify-send "Theme Converter" "Place dotfiles in /tmp/my-dotfiles/ then run:\n$CONVERTER /tmp/my-dotfiles theme-name"
        alacritty -e nvim "$CONVERTER"
        ;;
    *"Theme Guide"*)
        GUIDE="Omarchy Theme System

11 Built-in Themes:
✓ All pre-installed & tested
✓ Switch instantly
✓ No setup needed

16 Convertible Themes:
🔄 Auto-convert from dotfiles
🔄 Smart color extraction
🔄 Compatible configs generated

How Auto-Convert Works:
1. Downloads dotfiles repo
2. Finds configs (Waybar, Hypr, etc)
3. Extracts color palette
4. Generates missing Omarchy files
5. Validates & installs

Create Custom Theme:
1. Browse All Themes
2. Create Custom Theme
3. Edit in: ~/.local/share/omarchy/themes/
4. Modify colors in configs
5. Switch Theme to test

Total: 27 themes available!"
        
        notify-send "Theme Guide" "$GUIDE"
        ;;
    *"Export/Import"*)
        EXPORT_ACTIONS="Export Current Theme
Import Theme Archive
Back"
        
        ACTION=$(echo "$EXPORT_ACTIONS" | fuzzel --dmenu --prompt=" Export/Import: ")
        
        case "$ACTION" in
            *"Export"*)
                EXPORT_NAME=$(echo "" | fuzzel --dmenu --prompt=" Export name: ")
                if [ -n "$EXPORT_NAME" ]; then
                    EXPORT_DIR="$HOME/theme-exports"
                    mkdir -p "$EXPORT_DIR"
                    tar -czf "$EXPORT_DIR/${EXPORT_NAME}-${CURRENT_THEME}.tar.gz" \
                        -C ~/.config/omarchy/current/theme .
                    notify-send "✓ Exported" "Saved to: $EXPORT_DIR/${EXPORT_NAME}-${CURRENT_THEME}.tar.gz"
                fi
                ;;
            *"Import"*)
                ARCHIVES=$(find ~/Downloads ~/theme-exports -name "*.tar.gz" 2>/dev/null | head -10 | sed 's/^/ /')
                if [ -z "$ARCHIVES" ]; then
                    notify-send "No Archives" "No .tar.gz found"
                else
                    SELECTED=$(echo "$ARCHIVES" | fuzzel --dmenu --prompt=" Select Archive: ")
                    if [ -n "$SELECTED" ]; then
                        ARCHIVE_PATH=$(echo "$SELECTED" | xargs)
                        THEME_NAME=$(basename "$ARCHIVE_PATH" .tar.gz | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
                        IMPORT_DIR="$HOME/.local/share/omarchy/themes/$THEME_NAME"
                        mkdir -p "$IMPORT_DIR"
                        tar -xzf "$ARCHIVE_PATH" -C "$IMPORT_DIR"
                        ln -sf "$IMPORT_DIR" "$THEME_DIR/$THEME_NAME"
                        notify-send "✓ Imported" "$THEME_NAME is ready"
                    fi
                fi
                ;;
        esac
        ;;
    *"Back to Main Menu"*)
        ~/.config/rice-menu/rice-control.sh
        ;;
esac
