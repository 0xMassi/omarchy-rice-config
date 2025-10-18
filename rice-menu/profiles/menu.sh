#!/bin/bash
# Workspace Profiles Menu

PROFILE_MANAGER="$HOME/.config/rice-menu/profiles/profile-manager.sh"

OPTIONS="Load Profile
Save Current Setup
Quick Profiles
Manage Profiles
Back to Main Menu"

selected=$(echo "$OPTIONS" | fuzzel --dmenu --prompt=" Profiles: " --lines=5)

case "$selected" in
    *"Load Profile"*)
        PROFILES=$($PROFILE_MANAGER list | sed 's/^/ /')

        if [ -z "$PROFILES" ]; then
            notify-send "No Profiles" "No saved profiles found. Create one first!"
        else
            SELECTED=$(echo "$PROFILES" | fuzzel --dmenu --prompt=" Load Profile: ")

            if [ -n "$SELECTED" ]; then
                PROFILE_NAME=$(echo "$SELECTED" | xargs)
                notify-send "Loading Profile" "Switching to $PROFILE_NAME..."
                $PROFILE_MANAGER load "$PROFILE_NAME"
                notify-send "Profile Loaded" "✓ Switched to $PROFILE_NAME"
            fi
        fi
        ;;
    *"Save Current Setup"*)
        PROFILE_NAME=$(echo "" | fuzzel --dmenu --prompt=" Profile name: ")

        if [ -n "$PROFILE_NAME" ]; then
            PROFILE_NAME=$(echo "$PROFILE_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
            notify-send "Saving Profile" "Creating $PROFILE_NAME..."
            $PROFILE_MANAGER save "$PROFILE_NAME"
            notify-send "Profile Saved" "✓ Created $PROFILE_NAME"
        fi
        ;;
    *"Quick Profiles"*)
        QUICK_OPTIONS="Work (Nord + Minimal)
Gaming (Dark + Performance)
Creative (Colorful + Inspiring)
Evening (Warm + Cozy)
Create Custom"

        QUICK_SELECTED=$(echo "$QUICK_OPTIONS" | fuzzel --dmenu --prompt=" Quick Profile: ")

        case "$QUICK_SELECTED" in
            *"Work"*)
                omarchy-theme-set nord
                notify-send "Work Profile" "✓ Switched to Nord theme"
                ;;
            *"Gaming"*)
                omarchy-theme-set tokyo-night
                notify-send "Gaming Profile" "✓ Switched to Tokyo Night"
                ;;
            *"Creative"*)
                omarchy-theme-set dracula
                notify-send "Creative Profile" "✓ Switched to Dracula"
                ;;
            *"Evening"*)
                omarchy-theme-set catppuccin
                notify-send "Evening Profile" "✓ Switched to Catppuccin"
                ;;
        esac
        ;;
    *"Manage Profiles"*)
        MANAGE_OPTIONS="View All Profiles
Delete Profile
Export Profile
Import Profile
Back"

        MANAGE_SELECTED=$(echo "$MANAGE_OPTIONS" | fuzzel --dmenu --prompt=" Manage: ")

        case "$MANAGE_SELECTED" in
            *"View All Profiles"*)
                PROFILES=$($PROFILE_MANAGER list | sed 's/^/ /')

                if [ -z "$PROFILES" ]; then
                    notify-send "No Profiles" "No saved profiles found"
                else
                    SELECTED=$(echo "$PROFILES" | fuzzel --dmenu --prompt=" Select to view: ")

                    if [ -n "$SELECTED" ]; then
                        PROFILE_NAME=$(echo "$SELECTED" | xargs)
                        INFO=$($PROFILE_MANAGER info "$PROFILE_NAME")
                        notify-send "Profile Info" "$INFO"
                    fi
                fi
                ;;
            *"Delete Profile"*)
                PROFILES=$($PROFILE_MANAGER list | sed 's/^/ /')

                if [ -n "$PROFILES" ]; then
                    SELECTED=$(echo "$PROFILES" | fuzzel --dmenu --prompt=" Delete: ")

                    if [ -n "$SELECTED" ]; then
                        PROFILE_NAME=$(echo "$SELECTED" | xargs)
                        CONFIRM=$(echo -e "Delete $PROFILE_NAME\nCancel" | fuzzel --dmenu --prompt=" Confirm: ")

                        if [[ "$CONFIRM" == "Delete"* ]]; then
                            $PROFILE_MANAGER delete "$PROFILE_NAME"
                            notify-send "Profile Deleted" "✓ Removed $PROFILE_NAME"
                        fi
                    fi
                fi
                ;;
        esac
        ;;
    *"Back to Main Menu"*)
        ~/.config/rice-menu/rice-control.sh
        ;;
esac
