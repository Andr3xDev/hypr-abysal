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

# Update system
update_system() {
    print_message "Updating system..."
    sudo pacman -Syu --noconfirm
}

# Install paru
install_paru() {
    bash "$SCRIPT_DIR/install-paru.sh"
}

# Essential installation - All base packages
install_essential() {
    print_message "Installing essential packages..."
    sudo pacman -S --needed --noconfirm base linux linux-headers sudo git wget tree iwd smartmontools libreoffice-fresh dosfstools networkmanager network-manager-applet bluez bluez-utils bluetui pipewire pipewire-alsa pipewire-jack pipewire-pulse wireplumber qt5-wayland qt6-wayland python-gobject noto-fonts-emoji noto-fonts-cjk ttf-jetbrains-mono-nerd ttf-nerd-fonts-symbols hyprland hypridle hyprlock hyprpicker hyprshot swww uwsm quickshell xdg-desktop-portal-hyprland xdg-desktop-portal-gnome polkit-gnome dunst brightnessctl grim slurp kitty ghostty zsh starship fzf lsd tmux btop fastfetch yazi nano vim neovim gtk3 gtk4 nwg-look ly firefox pavucontrol power-profiles-daemon zram-generator mpv obs-studio htop npm xorg-server xorg-xinit satty unzip wlr-randr woff2-font-awesome cliphist zip xdg-utils gst-plugin-pipewire rsync
    paru -S --needed --noconfirm gearlever kotofetch phinger-cursors
    print_success "Essential packages installed"
}

# Custom GTK themes
install_gtk_themes() {
    if ask "Install custom GTK themes?"; then
        print_message "Installing GTK themes..."
        bash "$SCRIPT_DIR/install-gtk.sh"
    fi
}

# Custom Firefox theme
install_firefox_theme() {
    if ask "Install custom Firefox theme (userChrome.css)?"; then
        bash "$SCRIPT_DIR/install-firefox-theme.sh"
    fi
}

# Copy dotfiles
copy_dotfiles() {
    if ask "Copy configuration files (dotfiles)?"; then
        print_message "Copying dotfiles..."
        bash "$SCRIPT_DIR/install-os-config.sh"
    fi
}

# Enable system services
enable_services() {
    if ask "Enable system services (NetworkManager, Bluetooth, ly, etc.)?"; then
        bash "$SCRIPT_DIR/enable-services.sh"
    fi
}

# Configure Zsh
configure_zsh() {
    if ask "Configure Zsh with Oh My Zsh and plugins?"; then
        bash "$SCRIPT_DIR/configure-zsh.sh"
    fi
}

# Main installation
main_installation() {
    print_banner "HyprPharch Minimal Install"
    echo "Essential packages will be installed automatically."
    echo "Optional components will prompt for confirmation."
    echo

    update_system
    install_paru
    install_essential

    print_message "════════════════════════════════════════"
    print_message "       OPTIONAL COMPONENTS              "
    print_message "════════════════════════════════════════"

    install_gtk_themes
    install_firefox_theme

    print_message "════════════════════════════════════════"
    print_message "       FINAL CONFIGURATION              "
    print_message "════════════════════════════════════════"
    copy_dotfiles
    enable_services
    configure_zsh

    echo
    print_success "╔════════════════════════════════════════╗"
    print_success "║  Minimal installation completed!       ║"
    print_success "╚════════════════════════════════════════╝"
}

main_installation
