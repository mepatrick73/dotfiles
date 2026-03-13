# dotfiles

Hyprland-based Wayland desktop configuration for Fedora Linux. Dark minimal aesthetic.

## Stack

| Tool | Purpose |
|------|---------|
| [Hyprland](https://hyprland.org/) | Wayland compositor |
| [Waybar](https://github.com/Alexays/Waybar) | Status bar |
| [Wofi](https://hg.sr.ht/~scoopta/wofi) | App launcher (drun) |
| [Alacritty](https://alacritty.org/) | Terminal emulator |
| [Mako](https://github.com/emersion/mako) | Notification daemon |
| [Hyprpaper](https://github.com/hyprwm/hyprpaper) | Wallpaper daemon |
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

### 1. Install dependencies

```bash
bash scripts/install.sh
```

This installs: waybar, wofi, alacritty, mako, btop, tmux, fzf, socat, stow, hyprpaper, python3, numpy, matplotlib.

### 2. Stow dotfiles

```bash
cd ~/dotfiles
stow --target=$HOME .
```

### 3. Set up monitors

Run this once on a new machine to generate an initial `monitor.conf`:

```bash
bash scripts/setup-monitors.sh
```

Then edit `.config/hypr/monitor.conf` to fine-tune offsets, refresh rates, and transforms. Reload with `hyprctl reload`.

### 4. Log in to Hyprland

Wallpapers are generated automatically at login via `setup-wallpaper.sh`. Portrait and landscape monitors each get a layout-appropriate render.

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
