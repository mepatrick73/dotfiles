#!/bin/bash
# Install all dependencies for the Hyprland dotfiles setup (Fedora)
set -e

# --- Hyprland COPR ---
# Provides: hyprland, hyprpaper, xdg-desktop-portal-hyprland, and ecosystem packages
dnf copr list --enabled | grep -q "solopasha/hyprland" || sudo dnf copr enable -y solopasha/hyprland

# --- Hyprland + ecosystem ---
sudo dnf install -y hyprland hyprpaper xdg-desktop-portal-hyprland

# --- Login manager ---
sudo dnf install -y sddm
sudo systemctl enable sddm

# --- Polkit agent (privilege prompts: mounting, sudo GUIs, etc.) ---
sudo dnf install -y hyprpolkitagent

# --- Bar, launcher, terminal, notifications ---
sudo dnf install -y waybar wofi alacritty mako network-manager-applet

# --- Screenshots ---
# grimshot wraps grim + slurp and is bound to Print in hyprland.conf
sudo dnf install -y grim slurp grimshot

# --- Hardware controls ---
sudo dnf install -y brightnessctl playerctl

# --- Fonts ---
sudo dnf install -y google-noto-sans-mono-fonts fontawesome-6-free-fonts

# FiraMono Nerd Font (used in alacritty) — not in Fedora repos, install manually
if ! fc-list | grep -q "FiraMono Nerd Font"; then
    FIRA_VERSION="3.3.0"
    mkdir -p ~/.local/share/fonts/FiraMono
    curl -L "https://github.com/ryanoasis/nerd-fonts/releases/download/v${FIRA_VERSION}/FiraMono.zip" -o /tmp/FiraMono.zip
    unzip -o /tmp/FiraMono.zip -d ~/.local/share/fonts/FiraMono
    rm /tmp/FiraMono.zip
    fc-cache -f
fi

# --- Utilities ---
sudo dnf install -y btop tmux fzf stow socat wdisplays

# --- Shell ---
sudo dnf install -y fish
if [ "$SHELL" != "$(which fish)" ]; then
    chsh -s "$(which fish)"
fi


# --- Python + wallpaper generation ---
sudo dnf install -y python3 python3-pip
pip3 install --user numpy matplotlib
