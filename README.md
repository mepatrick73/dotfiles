# dotfiles

Hyprland-based Wayland desktop configuration for Fedora Linux. Dark minimal aesthetic.

## Stack

| Tool | Purpose |
|------|---------|
| [Hyprland](https://hyprland.org/) | Wayland compositor |
| [SDDM](https://github.com/sddm/sddm) | Login manager |
| [Waybar](https://github.com/Alexays/Waybar) | Status bar |
| [Wofi](https://hg.sr.ht/~scoopta/wofi) | App launcher (drun) |
| [Alacritty](https://alacritty.org/) | Terminal emulator |
| [Mako](https://github.com/emersion/mako) | Notification daemon |
| [Hyprpaper](https://github.com/hyprwm/hyprpaper) | Wallpaper daemon (bundled with Hyprland) |
| [grimshot](https://github.com/OctopusET/sway-contrib) | Screenshots |
| [btop](https://github.com/aristocratsoftware/btop) | System monitor |

## Layout

```
dotfiles/
├── .config/
│   ├── hypr/
│   │   ├── hyprland.conf       # Main Hyprland config
│   │   ├── monitor.conf        # Monitor layout (machine-specific)
│   │   ├── setup-wallpaper.sh  # Generates per-monitor wallpapers at login
│   │   └── keybinds.conf
│   ├── waybar/
│   │   ├── config.jsonc        # Bar modules and layout
│   │   ├── style.css           # Dark slate theme
│   │   └── watch-waybar.sh     # Auto-reload on config save + crash watchdog
│   ├── wofi/
│   │   ├── config              # Launcher settings
│   │   └── style.css           # Matches waybar theme
│   └── alacritty/
│       └── alacritty.toml      # Terminal config (FiraMono Nerd Font, gruvbox)
└── scripts/
    ├── install.sh              # Install all dependencies (Fedora/DNF)
    ├── gen-wallpaper.py        # Generate wireframe topology wallpaper
    └── setup-monitors.sh       # Bootstrap monitor.conf on a new machine
```

## Fresh Install

### 0. Upgrade Fedora to latest stable

Check the current latest stable release at [fedoraproject.org](https://fedoraproject.org/) and replace `XX` below:

```bash
sudo dnf upgrade --refresh
sudo dnf install dnf-plugin-system-upgrade
sudo dnf system-upgrade download --releasever=XX
sudo dnf system-upgrade reboot
```

If coming from KDE Plasma, you can remove it after confirming Hyprland works:

```bash
sudo dnf group remove "KDE Plasma Workspaces"
```

### 1. Clone with submodules

```bash
git clone --recurse-submodules https://github.com/mepatrick73/dotfiles.git ~/dotfiles
```

If you already cloned without `--recurse-submodules`:

```bash
git submodule update --init
```

### 2. Install dependencies

```bash
bash scripts/install.sh
```

This installs: hyprland (hyprpaper bundled), xdg-desktop-portal-hyprland, sddm, hyprpolkitagent, waybar, wofi, alacritty, mako, grim, slurp, grimshot, brightnessctl, playerctl, Noto Sans Mono, Font Awesome 6, FiraMono Nerd Font, btop, tmux, fzf, stow, socat, wdisplays, python3, numpy, matplotlib.

### 3. Stow dotfiles

```bash
cd ~/dotfiles
stow --target=$HOME .
```

### 4. Set up monitors

Launch `wdisplays` to visually arrange monitors, set resolutions, refresh rates, and rotations:

```bash
wdisplays
```

Apply the layout in the GUI, then run `setup-monitors.sh` to make it permanent:

```bash
bash scripts/setup-monitors.sh
hyprctl reload
```

This reads the live monitor state from Hyprland and writes `~/.config/hypr/monitor.conf`, including workspace pinning rules for any rotated (vertical) monitor.

### 5. Log in to Hyprland

`install.sh` enables SDDM automatically. Reboot, select **Hyprland** from the SDDM session menu, and log in.

Wallpapers are generated automatically at login via `setup-wallpaper.sh`. Portrait and landscape monitors each get a layout-appropriate render.

## Keeping up to date

Pull dotfiles and update the nvim submodule together:

```bash
git pull && git submodule update --remote
```

## Waybar

The bar auto-reloads when `config.jsonc` or `style.css` is saved — no manual restart needed. A watchdog also restarts waybar if it hangs or crashes.

To start the watcher manually (it runs automatically via `exec-once` in hyprland.conf):

```bash
~/.config/waybar/watch-waybar.sh &
```

## Wallpaper

Procedurally generated wireframe topology surfaces (S², T², Klein bottle) rendered in matplotlib over a perspective grid. Generated fresh at login, one image per monitor resolution.

To regenerate manually:

```bash
bash ~/.config/hypr/setup-wallpaper.sh
```

## Notes

- `monitor.conf` is machine-specific — edit it after running `setup-monitors.sh`
- Wallpaper JPGs and `hyprpaper.conf` are gitignored (auto-generated at login)
- Icons use Font Awesome 6 Free unicode codepoints (not nerd fonts)
