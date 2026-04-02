# dotfiles

Wayland (Hyprland) and X11 (i3) desktop configuration for Fedora Linux. Dark minimal aesthetic.

## Stack

| Tool | Purpose |
|------|---------|
| [Hyprland](https://hyprland.org/) | Wayland compositor |
| [SDDM](https://github.com/sddm/sddm) | Login manager |
| [hyprlock](https://github.com/hyprwm/hyprlock) | Screen locker |
| [Waybar](https://github.com/Alexays/Waybar) | Status bar |
| [Wofi](https://hg.sr.ht/~scoopta/wofi) | App launcher (drun) |
| [Alacritty](https://alacritty.org/) | Terminal emulator |
| [Fish](https://fishshell.com/) | Shell |
| [Mako](https://github.com/emersion/mako) | Notification daemon |
| [Hyprpaper](https://github.com/hyprwm/hyprpaper) | Wallpaper daemon |
| [grimshot](https://github.com/OctopusET/sway-contrib) | Screenshots |
| [wf-recorder](https://github.com/ammen99/wf-recorder) + ffmpeg | GIF screen recording |
| [i3](https://i3wm.org/) | X11 tiling window manager (alternative to Hyprland) |
| [pavucontrol](https://freedesktop.org/software/pulseaudio/pavucontrol/) | Volume mixer (waybar click) |
| [Blueman](https://github.com/blueman-project/blueman) | Bluetooth manager (waybar click) |
| [btop](https://github.com/aristocratsoftware/btop) | System monitor |

## Layout

```
dotfiles/
├── .config/
│   ├── hypr/
│   │   ├── hyprland.conf       # Main Hyprland config
│   │   ├── hyprlock.conf       # Lock screen layout and style
│   │   ├── monitor.conf        # Monitor layout (machine-specific)
│   │   ├── setup-wallpaper.sh  # Generates per-monitor wallpapers at login
│   │   ├── power-menu.sh       # Wofi power menu (lock/logout/suspend/reboot/shutdown)
│   │   ├── record-gif.sh       # Toggle GIF screen recording (wf-recorder → ffmpeg)
│   │   └── keybinds.conf
│   ├── i3/
│   │   └── config              # i3 config (mirrors Hyprland keybinds, dual-monitor layout)
│   ├── waybar/
│   │   ├── config.jsonc        # Bar modules and layout
│   │   ├── style.css           # Dark slate theme
│   │   └── watch-waybar.sh     # Auto-reload on config save + IPC connectivity health check
│   ├── wofi/
│   │   ├── config              # Launcher settings
│   │   └── style.css           # Matches waybar theme
│   └── alacritty/
│       └── alacritty.toml      # Terminal config (FiraMono Nerd Font, gruvbox)
├── ansible/
│   ├── site.yml                # Top-level playbook
│   ├── inventory.yml           # Localhost target
│   ├── ansible.cfg             # Roles path, output format
│   ├── requirements.yml        # community.general collection
│   └── roles/
│       ├── system/             # COPR, SDDM
│       ├── hyprland/           # Hyprland + all ecosystem packages
│       ├── fonts/              # System fonts + FiraMono Nerd Font
│       ├── shell/              # Fish, default shell, CLI utilities
│       ├── python/             # Python3, pip, numpy, matplotlib
│       └── chrome/             # Chrome X11 desktop entry
└── scripts/
    ├── install.sh              # Bootstrap: installs Ansible and runs the playbook
    ├── setup-snapshots.sh      # Configure btrfs snapshots via snapper
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

Installs Ansible, then runs the playbook which sets up: COPR, SDDM, Hyprland + ecosystem packages, system fonts, FiraMono Nerd Font, Fish shell, CLI utilities, Python packages, and the Chrome X11 desktop entry.

To re-run a single role after the initial setup:

```bash
ansible-playbook ansible/site.yml --tags <role> --ask-become-pass
# roles: system, hyprland, fonts, shell, python, chrome
```

To dry-run before applying:

```bash
ansible-playbook ansible/site.yml --check --diff --ask-become-pass
```

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

### 5. Set up btrfs snapshots (optional)

Configures snapper to snapshot `/` and `/home`, with DNF pre/post integration and scheduled timeline cleanup:

```bash
bash scripts/setup-snapshots.sh
```

### 6. Log in to Hyprland

`install.sh` enables SDDM automatically. Reboot, select **Hyprland** from the SDDM session menu, and log in.

Wallpapers are generated automatically at login via `setup-wallpaper.sh`. Portrait and landscape monitors each get a layout-appropriate render.

## Snapshots & recovery

Snapshots are taken automatically by snapper — on a timeline (hourly/daily/weekly) and before/after every `dnf` transaction.

### Browsing snapshots

```bash
snapper -c root list    # system snapshots
snapper -c home list    # home snapshots
```

### System still boots — roll back files

```bash
# roll back specific files to snapshot N
snapper -c root undochange N..0 /etc/some/file

# roll back everything to snapshot N
snapper -c root undochange N..0
```

### System won't boot — recover from GRUB

1. Reboot and select **Btrfs snapshots** in the GRUB menu
2. Boot into the snapshot you want to restore
3. Verify everything works, then make it permanent:

```bash
sudo snapper -c root rollback N
sudo reboot
```

The GRUB menu is kept up to date automatically by `grub-btrfsd` whenever a new snapshot is created.

## Keeping up to date

Pull dotfiles and update the nvim submodule together:

```bash
git pull && git submodule update --remote
```

## Waybar

The bar auto-reloads when `config.jsonc` or `style.css` is saved — no manual restart needed.

`watch-waybar.sh` keeps waybar alive and in sync. Every 10 seconds it checks `/proc/net/unix` for an ESTABLISHED connection from waybar to Hyprland's `socket2` event socket. If that connection is gone, waybar has lost its IPC subscription and will stop updating workspaces and the active window title — so it is restarted. This catches both crashes and the IPC desync bug present in Waybar ≤ 0.14.0 (fixed in 0.15.0).

To start the watcher manually (it runs automatically via `exec-once` in hyprland.conf):

```bash
~/.config/waybar/watch-waybar.sh &
```

## Power menu

`mod+shift+R` opens a wofi menu with session actions: Lock, Logout, Suspend, Reboot, Shutdown.

## Wallpaper

Procedurally generated wireframe topology surfaces (S², T², Klein bottle) rendered in matplotlib over a perspective grid. Generated fresh at login, one image per monitor resolution.

To regenerate manually:

```bash
bash ~/.config/hypr/setup-wallpaper.sh
```

## GIF recording

`Shift+Print` toggles a region GIF recording:

- **First press** — prompts to select a region with `slurp`, then starts recording via `wf-recorder`.
- **Second press** — stops recording, converts to GIF via ffmpeg (15 fps, 800px wide, palette-optimized), and saves to `~/Videos/`. A notification confirms the path.

`record-gif.sh` handles the toggle logic. `wf-recorder` and `ffmpeg` are installed by the Ansible `hyprland` role.

## Lock screen

Lock with `CTRL+ALT+L`. The lock screen shows a clock and date. `hyprlock.conf` controls layout and colors.

## Notes

- `monitor.conf` is machine-specific — edit it after running `setup-monitors.sh`
- Wallpaper JPGs and `hyprpaper.conf` are gitignored (auto-generated at login)
- Icons use Font Awesome 6 Free unicode codepoints (not nerd fonts)
- FiraMono Nerd Font is auto-installed by `install.sh` (not in Fedora repos)
- Google Chrome is not in `install.sh` — install manually from the Chrome website
- NVIDIA users: `hyprland.conf` includes the required env vars (`GBM_BACKEND`, `NVD_BACKEND`, `WLR_NO_HARDWARE_CURSORS`)
- CUDA: `config.fish` sets `LD_LIBRARY_PATH` and adds `/usr/local/cuda/bin` to `PATH` — assumes CUDA installed to `/usr/local/cuda`
