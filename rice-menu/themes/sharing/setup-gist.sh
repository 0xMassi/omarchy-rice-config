#!/bin/bash
# Setup GitHub Gist - Guide user through gh CLI setup

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    INSTALL_OPTIONS="Install GitHub CLI
Skip (use transfer.sh instead)
Cancel"

    selected=$(echo "$INSTALL_OPTIONS" | fuzzel --dmenu --prompt="GitHub CLI not found: " --lines=3)

    case "$selected" in
        *"Install"*)
            notify-send "Installing GitHub CLI" "Installing via pacman..."

            # Open terminal to run install command
            alacritty -e bash -c "
                echo '════════════════════════════════════════════════════════════'
                echo ' Installing GitHub CLI'
                echo '════════════════════════════════════════════════════════════'
                echo ''
                sudo pacman -S github-cli
                echo ''
                echo 'Press Enter to continue...'
                read
            "

            # Check again
            if ! command -v gh &> /dev/null; then
                notify-send "Installation Failed" "GitHub CLI not installed"
                exit 1
            fi

            notify-send "✓ Installed" "GitHub CLI installed successfully"
            ;;
        *)
            exit 1
            ;;
    esac
fi

# Check authentication status
if gh auth status &> /dev/null; then
    # Already authenticated
    USERNAME=$(gh auth status 2>&1 | grep "Logged in" | awk '{print $7}')

    STATUS_INFO="✓ GitHub Authentication Active

Logged in as: $USERNAME
Account type: $(gh auth status 2>&1 | grep "account" | awk '{print $4}')

You can now upload themes to GitHub Gist.

Options:"

    OPTIONS="Test Gist Upload
Re-authenticate
Logout
Done"

    selected=$(echo "$OPTIONS" | fuzzel --dmenu --prompt="GitHub Auth Status: " --lines=4)

    case "$selected" in
        *"Test"*)
            notify-send "Testing Gist" "Creating test gist..."

            TEST_FILE="/tmp/test-gist-$$.txt"
            echo "Test gist from Omarchy Theme System - $(date)" > "$TEST_FILE"

            GIST_URL=$(gh gist create "$TEST_FILE" --public --desc "Omarchy test gist" 2>&1 | grep -o 'https://gist.github.com/[^[:space:]]*')
            rm -f "$TEST_FILE"

            if [ -n "$GIST_URL" ]; then
                echo -n "$GIST_URL" | wl-copy
                notify-send "✓ Test Successful" "Gist created: $GIST_URL\nURL copied to clipboard"
            else
                notify-send "Test Failed" "Could not create gist"
            fi
            ;;
        *"Re-authenticate"*)
            gh auth logout
            # Continue to authentication flow below
            ;;
        *"Logout"*)
            gh auth logout
            notify-send "Logged Out" "GitHub authentication removed"
            exit 0
            ;;
        *)
            exit 0
            ;;
    esac
fi

# Authentication flow
if ! gh auth status &> /dev/null; then
    WELCOME="Welcome to GitHub Gist Setup!

GitHub Gist allows you to:
• Upload themes permanently (until you delete them)
• Share themes with permanent URLs
• Manage your uploaded themes
• Track downloads and views

To use GitHub Gist, you need to authenticate with GitHub.

Authentication methods:"

    AUTH_OPTIONS="Browser Login (Recommended)
Token Login (Advanced)
Help & Info
Skip Setup
Cancel"

    selected=$(echo "$AUTH_OPTIONS" | fuzzel --dmenu --prompt="GitHub Gist Setup: " --lines=5)

    case "$selected" in
        *"Help"*)
            HELP_INFO="GitHub Gist Help

What is GitHub Gist?
• A simple way to share code and files
• Permanent hosting (until you delete)
• Free for public gists
• Track views and downloads
• Manage all your uploads at gist.github.com

Why use Gist for themes?
• Permanent URLs that don't expire
• Professional sharing
• Easy to manage and delete
• Can update themes after upload
• Others can fork/modify your themes

Do I need a GitHub account?
• Yes, you need a free GitHub account
• Sign up at: github.com/signup
• It's free and takes 2 minutes

Is it safe?
• Yes, GitHub CLI is official and secure
• We only request 'gist' permission
• No access to your code repositories
• You can revoke access anytime

Alternatives:
• transfer.sh - 7 days, no account
• 0x0.st - 365 days, no account
• Local file sharing

Press Enter to go back..."

            echo "$HELP_INFO" | fuzzel --dmenu --prompt="GitHub Gist Help" --lines=20 || true
            # Return to auth options
            exec "$0"
            ;;
        *"Browser"*)
            notify-send "GitHub Authentication" "Opening browser for authentication..."

            # Run gh auth login in terminal so user can see the process
            alacritty -e bash -c "
                clear
                echo '════════════════════════════════════════════════════════════'
                echo ' GitHub Authentication - Browser Login'
                echo '════════════════════════════════════════════════════════════'
                echo ''
                echo 'Follow these steps:'
                echo '1. A browser window will open'
                echo '2. Log in to your GitHub account'
                echo '3. Authorize GitHub CLI'
                echo '4. Return to this terminal'
                echo ''
                echo 'Press Enter to continue...'
                read
                echo ''
                gh auth login --web --scopes 'gist'
                echo ''
                echo '════════════════════════════════════════════════════════════'
                if gh auth status &> /dev/null; then
                    echo '✓ Authentication successful!'
                else
                    echo '✗ Authentication failed'
                fi
                echo ''
                echo 'Press Enter to close...'
                read
            "

            # Verify authentication
            if gh auth status &> /dev/null; then
                USERNAME=$(gh auth status 2>&1 | grep "Logged in" | awk '{print $7}')
                notify-send "✓ Authenticated" "Logged in as $USERNAME\nYou can now upload themes to GitHub Gist"
            else
                notify-send "Authentication Failed" "Could not authenticate with GitHub"
                exit 1
            fi
            ;;

        *"Token"*)
            TOKEN_INFO="Token Login (Advanced)

This method requires a Personal Access Token from GitHub.

Steps to get a token:
1. Go to: github.com/settings/tokens
2. Click 'Generate new token (classic)'
3. Give it a name: 'Omarchy Theme System'
4. Select scope: 'gist'
5. Click 'Generate token'
6. Copy the token (you won't see it again!)

Ready to enter token?"

            CONTINUE=$(echo -e "Yes, I have a token\nNo, go back\nCancel" | fuzzel --dmenu --prompt="Token Login: ")

            if [[ "$CONTINUE" =~ "Yes" ]]; then
                TOKEN=$(echo "" | fuzzel --dmenu --prompt="Paste GitHub token: ")

                if [ -z "$TOKEN" ]; then
                    notify-send "Cancelled" "No token provided"
                    exit 1
                fi

                # Authenticate with token
                echo "$TOKEN" | gh auth login --with-token

                if gh auth status &> /dev/null; then
                    USERNAME=$(gh auth status 2>&1 | grep "Logged in" | awk '{print $7}')
                    notify-send "✓ Authenticated" "Logged in as $USERNAME"
                else
                    notify-send "Authentication Failed" "Invalid token or authentication error"
                    exit 1
                fi
            fi
            ;;

        *)
            exit 0
            ;;
    esac
fi

# Show success and next steps
if gh auth status &> /dev/null; then
    USERNAME=$(gh auth status 2>&1 | grep "Logged in" | awk '{print $7}')

    SUCCESS="✓ GitHub Gist Setup Complete!

Logged in as: $USERNAME

You can now:
• Upload themes to GitHub Gist
• Share permanent URLs
• Manage your gists at: gist.github.com

To upload a theme:
1. Go to Theme Editor
2. Edit or create a theme
3. Click 'Export Theme'
4. Select 'Upload to GitHub Gist'"

    echo "$SUCCESS" | fuzzel --dmenu --prompt="✓ Setup Complete" --lines=15 || true
    notify-send "✓ GitHub Gist Ready" "Logged in as $USERNAME"
fi
