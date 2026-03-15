#!/bin/bash
# Install all dependencies for the Hyprland dotfiles setup (Fedora)
set -e

# ── Helpers ────────────────────────────────────────────────────────────────────

BOLD="\e[1m"
DIM="\e[2m"
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
CYAN="\e[36m"
RESET="\e[0m"

task()    { echo -e "\n${BOLD}${CYAN}  ▶ $*${RESET}"; }
ok()      { echo -e "  ${GREEN}✔ $*${RESET}"; }
skipped() { echo -e "  ${YELLOW}– $* (skipped)${RESET}"; }
info()    { echo -e "  ${DIM}  $*${RESET}"; }

dnf_install() {
    local desc="$1"; shift
    task "$desc"
    info "packages: $*"
    sudo dnf install -y "$@" > /dev/null 2>&1
    ok "$desc"
}

# ── Play: Hyprland setup ───────────────────────────────────────────────────────
echo -e "\n${BOLD}PLAY [Hyprland dotfiles — Fedora]${RESET}"
echo -e "${DIM}$(date)${RESET}"

# --- COPR ---
task "Enable solopasha/hyprland COPR"
if ls /etc/yum.repos.d/ | grep -q "solopasha-hyprland"; then
    skipped "Enable solopasha/hyprland COPR"
else
    sudo dnf copr enable -y solopasha/hyprland > /dev/null 2>&1
    ok "Enable solopasha/hyprland COPR"
fi

# --- Packages ---
dnf_install "Hyprland + ecosystem" hyprland hyprpaper xdg-desktop-portal-hyprland hyprlock

task "Install SDDM login manager"
sudo dnf install -y sddm > /dev/null 2>&1
sudo systemctl disable gdm lightdm 2>/dev/null || true
sudo systemctl enable sddm 2>/dev/null
ok "Install SDDM login manager"

dnf_install "Polkit agent"                  hyprpolkitagent
dnf_install "Keyring"                       gnome-keyring libsecret
dnf_install "Bar, launcher, notifications"  waybar wofi alacritty mako network-manager-applet
dnf_install "Volume mixer"                  pavucontrol
dnf_install "Bluetooth manager"             blueman
dnf_install "Screenshots"                   grim slurp grimshot
dnf_install "Hardware controls"             brightnessctl playerctl
dnf_install "Fonts"                         google-noto-sans-mono-fonts fontawesome-6-free-fonts

task "FiraMono Nerd Font"
if fc-list | grep -q "FiraMono Nerd Font"; then
    skipped "FiraMono Nerd Font"
else
    FIRA_VERSION="3.3.0"
    info "downloading v${FIRA_VERSION}..."
    mkdir -p ~/.local/share/fonts/FiraMono
    curl -sL "https://github.com/ryanoasis/nerd-fonts/releases/download/v${FIRA_VERSION}/FiraMono.zip" -o /tmp/FiraMono.zip
    unzip -o /tmp/FiraMono.zip -d ~/.local/share/fonts/FiraMono > /dev/null
    rm /tmp/FiraMono.zip
    fc-cache -f
    ok "FiraMono Nerd Font"
fi

dnf_install "Utilities" btop tmux fzf stow socat wdisplays

task "Fish shell"
sudo dnf install -y fish > /dev/null 2>&1
if [ "$SHELL" != "$(which fish)" ]; then
    chsh -s "$(which fish)"
    ok "Fish shell (set as default)"
else
    ok "Fish shell (already default)"
fi

dnf_install "Python + pip" python3 python3-pip

task "Python packages (numpy, matplotlib)"
pip3 install --user numpy matplotlib -q
ok "Python packages (numpy, matplotlib)"

# ── Summary ───────────────────────────────────────────────────────────────────
echo -e "\n${BOLD}${GREEN}  ✔ Setup complete.${RESET} Stow dotfiles and reboot into SDDM.\n"
