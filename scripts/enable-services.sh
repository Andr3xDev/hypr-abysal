#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh" || { echo "Error: common.sh not found"; exit 1; }

print_banner "Enabling System Services"

# NetworkManager
if pacman -Q networkmanager &>/dev/null; then
    sudo systemctl enable NetworkManager
fi

# Bluetooth
if pacman -Q bluez &>/dev/null; then
    sudo systemctl enable bluetooth
fi

# Ly display manager
if pacman -Q ly &>/dev/null; then
    sudo systemctl enable ly.service
fi

# Docker
if pacman -Q docker &>/dev/null; then
    sudo systemctl enable docker
fi

# NVIDIA suspend/resume (laptop power management)
if pacman -Q nvidia-open-dkms &>/dev/null; then
    sudo systemctl enable nvidia-suspend.service nvidia-hibernate.service nvidia-resume.service
fi

# Wallserver (user-level)
if [ -f "$HOME/.config/systemd/user/wallserver.service" ]; then
    systemctl --user enable wallserver.service
fi

print_success "Services enabled"
