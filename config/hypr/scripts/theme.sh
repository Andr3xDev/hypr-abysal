#!/bin/bash

# ---------------------------------------------------------------------------
# Hyprland Theme Switcher
# Applies the themed Hyprlock and Hyprland color configs via symlinks
# ---------------------------------------------------------------------------

HYPR_DIR="$HOME/.config/hypr/theme/"
THEME="$1"

source "${HOME}/.config/scripts/logger.sh"
log INFO "-------------------------------"
log INFO "Applying theme: ${THEME}"

case "${THEME}" in
    abysal-obsidian)
        # Hyprlock (conf)
        ln -sf themes/abysal-obsidian/abysal-obsidian.conf "$HYPR_DIR/colors.conf"
        # Hyprland (lua)
        echo 'return "abysal-obsidian"' > "$HYPR_DIR/state.lua"
        ;;
    abysal-marble)
        # Hyprlock (conf)
        ln -sf themes/abysal-marble/abysal-marble.conf "$HYPR_DIR/colors.conf"
        # Hyprland (lua)
        echo 'return "abysal-marble"' > "$HYPR_DIR/state.lua"
        ;;
    abysal-nerita)
        ln -sf themes/abysal-nerita/abysal-nerita.conf "$HYPR_DIR/colors.conf"
        echo 'return "abysal-nerita"' > "$HYPR_DIR/state.lua"
        ;;
    *)
        log ERROR "Invalid theme: ${THEME}"
        exit 1
        ;;
esac

hyprctl reload

log SUCCESS "Theme applied successfully: ${THEME}"
