#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh" || { echo "Error: common.sh not found"; exit 1; }

# Reuse temp directory from parent script or create one
if [ -z "$HYPRPHARCH_TEMP" ]; then
    export HYPRPHARCH_TEMP="$HOME/.cache/hyprpharch-install-$$"
    mkdir -p "$HYPRPHARCH_TEMP"
    trap "rm -rf '$HYPRPHARCH_TEMP'" EXIT INT TERM
fi

# Multilib repo (required for any lib32-* package)
enable_multilib() {
    if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
        sudo sed -i '/^#\[multilib\]$/{N;s/^#\[multilib\]\n#Include/[multilib]\nInclude/}' /etc/pacman.conf
        sudo pacman -Sy --noconfirm
    fi
}

# Intel drivers
install_intel() {
    print_message "Installing Intel drivers..."
    sudo pacman -S --needed --noconfirm intel-media-driver intel-ucode vulkan-intel lib32-vulkan-intel libva-intel-driver vulkan-tools
}

# NVIDIA drivers
install_nvidia() {
    print_warning "Make sure you have an NVIDIA GPU!"
    print_message "Installing NVIDIA drivers (open kernel modules)..."
    sudo pacman -S --needed --noconfirm nvidia-open-dkms nvidia-utils lib32-nvidia-utils libva-nvidia-driver lib32-mesa
}

# Linux Zen kernel
install_linux_zen() {
    sudo pacman -S --needed --noconfirm linux-zen linux-zen-headers
}

# Development tools
install_dev_tools() {
    sudo pacman -S --needed --noconfirm docker docker-buildx docker-compose
    sudo usermod -aG docker "$USER"
    paru -S --needed --noconfirm visual-studio-code-bin
}

# Spotify with Spicetify
install_spotify() {
    bash "$SCRIPT_DIR/install-spotify.sh"
}

# Steam
install_steam() {
    sudo pacman -S --needed --noconfirm steam discord
}

# Lazygit
install_lazygit() {
    sudo pacman -S --needed --noconfirm lazygit
}

# Virtualization tools
install_virt() {
    sudo pacman -S --needed --noconfirm qemu-full virt-manager virt-viewer swtpm dnsmasq iptables
    print_warning "Remember to add your user to the libvirt group and enable libvirtd if needed"
}

# Dev toolchain
install_dev_toolchain() {
    sudo pacman -S --needed --noconfirm rust cmake maven jdk-openjdk terraform tree-sitter-cli luarocks uv sassc pacman-contrib git-delta
}

# AI CLI tools
install_ai_cli() {
    paru -S --needed --noconfirm claude-code opencode openspec engram-bin
}

# Personal desktop apps
install_personal_apps() {
    sudo pacman -S --needed --noconfirm obsidian
    paru -S --needed --noconfirm teams-for-linux proton-vpn-gtk-app vial-appimage
}

# Personal fonts
install_personal_fonts() {
    print_message "Installing Times New Roman..."
    sudo pacman -S --needed --noconfirm cabextract

    FONT_TMP="${HYPRPHARCH_TEMP:-$(mktemp -d)}/times-new-roman"
    mkdir -p "$FONT_TMP"
    wget -q -O "$FONT_TMP/times32.exe" https://downloads.sourceforge.net/project/corefonts/the%20fonts/final/times32.exe
    cabextract -q -d "$FONT_TMP" "$FONT_TMP/times32.exe"

    if ! ls "$FONT_TMP"/*.ttf >/dev/null 2>&1; then
        print_error "Font extraction failed - no .ttf files found, check download URL"
        exit 1
    fi

    mkdir -p "$HOME/.local/share/fonts"
    cp "$FONT_TMP"/*.ttf "$HOME/.local/share/fonts/"
    fc-cache -f "$HOME/.local/share/fonts" >/dev/null

    rm -rf "$FONT_TMP"
    print_success "Times New Roman installed"
}

# Main installation
main_installation() {
    print_banner "HyprPharch Personal Setup"
    echo "Installing full personal setup: GPU drivers, dev tools, personal apps."
    echo

    print_message "════════════════════════════════════════"
    print_message "       GPU DRIVERS                      "
    print_message "════════════════════════════════════════"
    enable_multilib
    install_intel
    install_nvidia
    install_linux_zen

    print_message "════════════════════════════════════════"
    print_message "       DEVELOPMENT                      "
    print_message "════════════════════════════════════════"
    install_dev_tools
    install_lazygit
    install_virt
    install_dev_toolchain
    install_ai_cli

    print_message "════════════════════════════════════════"
    print_message "       PERSONAL APPS                    "
    print_message "════════════════════════════════════════"
    install_spotify
    install_steam
    install_personal_apps
    install_personal_fonts

    echo
    print_success "╔════════════════════════════════════════╗"
    print_success "║  Personal setup completed!             ║"
    print_success "╚════════════════════════════════════════╝"
}

main_installation
