#!/bin/bash
# Metadata Editor - Edit theme name, author, description, tags

THEME_DIR="$1"

if [ -z "$THEME_DIR" ]; then
    echo "Error: No theme directory provided"
    exit 1
fi

METADATA_FILE="$THEME_DIR/theme.json"

# Create default metadata if doesn't exist
if [ ! -f "$METADATA_FILE" ]; then
    THEME_NAME=$(basename "$THEME_DIR")
    cat > "$METADATA_FILE" << EOF
{
  "name": "$THEME_NAME",
  "slug": "$THEME_NAME",
  "author": "$USER",
  "description": "A custom Omarchy theme",
  "version": "1.0.0",
  "created": "$(date +%Y-%m-%d)",
  "tags": ["custom"]
}
EOF
fi

# Parse current metadata
NAME=$(jq -r '.name // "Untitled"' "$METADATA_FILE" 2>/dev/null || echo "Untitled")
AUTHOR=$(jq -r '.author // "Anonymous"' "$METADATA_FILE" 2>/dev/null || echo "Anonymous")
DESCRIPTION=$(jq -r '.description // ""' "$METADATA_FILE" 2>/dev/null || echo "")
TAGS=$(jq -r '.tags // [] | join(", ")' "$METADATA_FILE" 2>/dev/null || echo "")
VERSION=$(jq -r '.version // "1.0.0"' "$METADATA_FILE" 2>/dev/null || echo "1.0.0")

while true; do
    OPTIONS="Theme Name: $NAME
Author: $AUTHOR
Description: $DESCRIPTION
Tags: $TAGS
Version: $VERSION
Save & Exit
Cancel"

    selected=$(echo "$OPTIONS" | fuzzel --dmenu --prompt="Edit Theme Metadata: " --lines=7)

    case "$selected" in
        *"Theme Name"*)
            NEW_NAME=$(echo "$NAME" | fuzzel --dmenu --prompt="Enter theme name: ")
            if [ -n "$NEW_NAME" ]; then
                NAME="$NEW_NAME"
                notify-send "Updated" "Theme name set to: $NAME"
            fi
            ;;

        *"Author"*)
            NEW_AUTHOR=$(echo "$AUTHOR" | fuzzel --dmenu --prompt="Enter author name: ")
            if [ -n "$NEW_AUTHOR" ]; then
                AUTHOR="$NEW_AUTHOR"
                notify-send "Updated" "Author set to: $AUTHOR"
            fi
            ;;

        *"Description"*)
            NEW_DESC=$(echo "$DESCRIPTION" | fuzzel --dmenu --prompt="Enter description: ")
            if [ -n "$NEW_DESC" ]; then
                DESCRIPTION="$NEW_DESC"
                notify-send "Updated" "Description updated"
            fi
            ;;

        *"Tags"*)
            TAG_OPTIONS="Dark
Light
Blue
Green
Red
Purple
Pastel
Neon
Monochrome
Retro
Minimal
Vibrant
Custom (enter manually)"

            TAG=$(echo "$TAG_OPTIONS" | fuzzel --dmenu --prompt="Select tag to add: " --lines=13)

            if [[ "$TAG" == *"Custom"* ]]; then
                CUSTOM_TAG=$(echo "" | fuzzel --dmenu --prompt="Enter custom tag: ")
                if [ -n "$CUSTOM_TAG" ]; then
                    if [ -z "$TAGS" ]; then
                        TAGS="$CUSTOM_TAG"
                    else
                        TAGS="$TAGS, $CUSTOM_TAG"
                    fi
                    notify-send "Tag Added" "$CUSTOM_TAG"
                fi
            elif [ -n "$TAG" ]; then
                if [ -z "$TAGS" ]; then
                    TAGS="$TAG"
                else
                    TAGS="$TAGS, $TAG"
                fi
                notify-send "Tag Added" "$TAG"
            fi
            ;;

        *"Version"*)
            NEW_VERSION=$(echo "$VERSION" | fuzzel --dmenu --prompt="Enter version (e.g., 1.0.0): ")
            if [ -n "$NEW_VERSION" ]; then
                VERSION="$NEW_VERSION"
                notify-send "Updated" "Version set to: $VERSION"
            fi
            ;;

        *"Save"*)
            # Save metadata to JSON file
            SLUG=$(echo "$NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')

            # Convert tags to JSON array
            TAGS_ARRAY=$(echo "$TAGS" | sed 's/, \?/","/g' | sed 's/^/"/' | sed 's/$/"/')

            cat > "$METADATA_FILE" << EOF
{
  "name": "$NAME",
  "slug": "$SLUG",
  "author": "$AUTHOR",
  "description": "$DESCRIPTION",
  "version": "$VERSION",
  "created": "$(date +%Y-%m-%d)",
  "tags": [$TAGS_ARRAY]
}
EOF
            notify-send "Saved" "Theme metadata saved successfully"
            exit 0
            ;;

        *"Cancel"|"")
            exit 1
            ;;
    esac
done
