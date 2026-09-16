#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh" || { echo "Error: common.sh not found"; exit 1; }

CONFIG_SRC="$SCRIPT_DIR/../config"

print_banner "Installing Dotfiles"

# Copy all config files
print_message "Copying configuration files..."

# Create backup if config exists
if [ -d "$HOME/.config" ]; then
    BACKUP_DIR="$HOME/.config.backup-$(date +%Y%m%d-%H%M%S)"
    print_warning "Backing up existing config to $BACKUP_DIR"
    cp -r "$HOME/.config" "$BACKUP_DIR"
fi

# Create .config directory
mkdir -p "$HOME/.config"

# Copy each config directory
for config in btop dunst fastfetch ghostty gtk-3.0 gtk-4.0 hypr kitty kotofetch lazygit nvim nwg-look quickshell rofi satty scripts starship startpage swww systemd tmux xsettingsd yazi; do
    if [ -d "$CONFIG_SRC/$config" ]; then
        print_message "Installing $config config..."
        cp -r "$CONFIG_SRC/$config" "$HOME/.config/"
    fi
done

# Copy starship.toml to home
if [ -f "$CONFIG_SRC/starship.toml" ] && [ "$(readlink -f "$CONFIG_SRC/starship.toml")" != "$(readlink -f "$HOME/.config/starship.toml" 2>/dev/null)" ]; then
    cp "$CONFIG_SRC/starship.toml" "$HOME/.config/starship.toml"
fi

# Copy wallpapers to .config
if [ -d "$CONFIG_SRC/wallpapers" ]; then
    print_message "Installing wallpapers..."
    cp -r "$CONFIG_SRC/wallpapers" "$HOME/.config/"
fi

# Copy fonts to ~/.local/share/fonts
if [ -d "$CONFIG_SRC/fonts" ]; then
    print_message "Installing fonts..."
    mkdir -p "$HOME/.local/share/fonts"
    cp -r "$CONFIG_SRC/fonts/." "$HOME/.local/share/fonts/"
    fc-cache -f "$HOME/.local/share/fonts" >/dev/null
    print_success "Fonts installed successfully"
fi

print_success "Dotfiles installed successfully"
