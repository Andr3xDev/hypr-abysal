#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh" || { echo "Error: common.sh not found"; exit 1; }

print_banner "Installing Spotify & Spicetify"

sudo pacman -S --needed --noconfirm spotify-launcher
paru -S --needed --noconfirm spicetify-cli

# Launch Spotify to initialize installation
print_message "Launching Spotify to initialize installation..."
spotify-launcher &
SPOTIFY_PID=$!

SPOTIFY_INSTALL_PATH="$HOME/.local/share/spotify-launcher/install/usr/share/spotify"
SPOTIFY_PREFS_PATH="$HOME/.config/spotify/prefs"

# Wait for Spotify to finish extracting (up to 60 seconds)
print_message "Waiting for Spotify to initialize..."
SPOTIFY_WAIT_TIMEOUT=60
SPOTIFY_WAIT_ELAPSED=0
while [ ! -d "$SPOTIFY_INSTALL_PATH" ] || [ ! -f "$SPOTIFY_PREFS_PATH" ]; do
    if [ "$SPOTIFY_WAIT_ELAPSED" -ge "$SPOTIFY_WAIT_TIMEOUT" ]; then
        print_error "Timed out waiting for Spotify to initialize"
        kill $SPOTIFY_PID 2>/dev/null || killall spotify 2>/dev/null || true
        exit 1
    fi
    sleep 1
    SPOTIFY_WAIT_ELAPSED=$((SPOTIFY_WAIT_ELAPSED + 1))
done

# Close Spotify
print_message "Closing Spotify..."
kill $SPOTIFY_PID 2>/dev/null || killall spotify 2>/dev/null || true
sleep 2

# Configure Spicetify permissions
print_message "Setting up Spicetify permissions..."
spicetify config spotify_path "$SPOTIFY_INSTALL_PATH"
spicetify config prefs_path "$SPOTIFY_PREFS_PATH"

# Run Spicetify for the first time
print_message "Running Spicetify initial setup..."
spicetify backup apply

# Clone spicetify-themes and install Dribbblish and Onepunch themes
print_message "Installing Spicetify themes (Dribbblish and Onepunch)..."

# Get spicetify themes directory
THEMES_DIR="$HOME/.config/spicetify/Themes"
mkdir -p "$THEMES_DIR"

# Clone repo directly in themes directory
cd "$THEMES_DIR"
git clone --depth 1 https://github.com/spicetify/spicetify-themes.git

# Copy Dribbblish and Onepunch themes to parent directory
cp -r spicetify-themes/Dribbblish ./
cp -r spicetify-themes/Onepunch ./

# Remove cloned repository
rm -rf spicetify-themes

spicetify config inject_css 1 replace_colors 1 overwrite_assets 1 inject_theme_js 1

print_success "╔════════════════════════════════════════╗"
print_success "║  Spotify & Spicetify installed!        ║"
print_success "║  Themes: Dribbblish, Onepunch          ║"
print_success "╚════════════════════════════════════════╝"
