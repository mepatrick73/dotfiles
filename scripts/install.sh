sudo dnf install mako
sudo dnf install waybar
sudo dnf install btop
sudo dnf install wdisplays
sudo dnf install tmux
sudo dnf install alacritty
sudo dnf install fzf
sudo dnf install stow
sudo dnf install socat

# Hyprland ecosystem packages (requires solopasha/hyprland COPR)
dnf copr list --enabled | grep -q "solopasha/hyprland" || sudo dnf copr enable -y solopasha/hyprland
sudo dnf install hyprpaper
