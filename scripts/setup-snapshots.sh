#!/bin/bash
# Configure btrfs snapshots via snapper for / and /home (Fedora)
set -e

BOLD="\e[1m"
DIM="\e[2m"
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
RESET="\e[0m"

task()    { echo -e "\n${BOLD}${CYAN}  ▶ $*${RESET}"; }
ok()      { echo -e "  ${GREEN}✔ $*${RESET}"; }
skipped() { echo -e "  ${YELLOW}– $* (skipped)${RESET}"; }
info()    { echo -e "  ${DIM}  $*${RESET}"; }

echo -e "\n${BOLD}PLAY [btrfs snapshots — snapper]${RESET}"
echo -e "${DIM}$(date)${RESET}"

# --- Install ---
task "Install snapper + DNF plugin"
sudo dnf install -y snapper python3-dnf-plugin-snapper > /dev/null 2>&1
ok "Install snapper + DNF plugin"

# --- Root config ---
task "Create snapper config for /"
if sudo snapper list-configs | grep -q "^root "; then
    skipped "Create snapper config for / (already exists)"
else
    sudo snapper -c root create-config /
    ok "Create snapper config for /"
fi

# --- Home config ---
task "Create snapper config for /home"
if sudo snapper list-configs | grep -q "^home "; then
    skipped "Create snapper config for /home (already exists)"
else
    sudo snapper -c home create-config /home
    ok "Create snapper config for /home"
fi

# --- Timeline settings for root ---
task "Configure root snapshot retention"
info "timeline: hourly=5  daily=7  weekly=4  monthly=6  yearly=1"
sudo snapper -c root set-config \
    TIMELINE_CREATE=yes \
    TIMELINE_CLEANUP=yes \
    NUMBER_CLEANUP=yes \
    TIMELINE_LIMIT_HOURLY=5 \
    TIMELINE_LIMIT_DAILY=7 \
    TIMELINE_LIMIT_WEEKLY=4 \
    TIMELINE_LIMIT_MONTHLY=6 \
    TIMELINE_LIMIT_YEARLY=1
ok "Configure root snapshot retention"

# --- Timeline settings for home ---
task "Configure home snapshot retention"
info "timeline: hourly=5  daily=7  weekly=4  monthly=3  yearly=0"
sudo snapper -c home set-config \
    TIMELINE_CREATE=yes \
    TIMELINE_CLEANUP=yes \
    NUMBER_CLEANUP=yes \
    TIMELINE_LIMIT_HOURLY=5 \
    TIMELINE_LIMIT_DAILY=7 \
    TIMELINE_LIMIT_WEEKLY=4 \
    TIMELINE_LIMIT_MONTHLY=3 \
    TIMELINE_LIMIT_YEARLY=0
ok "Configure home snapshot retention"

# --- Enable systemd timers ---
task "Enable snapper systemd timers"
sudo systemctl enable --now snapper-timeline.timer > /dev/null 2>&1
sudo systemctl enable --now snapper-cleanup.timer > /dev/null 2>&1
ok "Enable snapper systemd timers"

# --- grub-btrfs ---
task "Enable kylegospo/grub-btrfs COPR"
if ls /etc/yum.repos.d/ | grep -q "kylegospo-grub-btrfs"; then
    skipped "Enable kylegospo/grub-btrfs COPR (already enabled)"
else
    sudo dnf copr enable -y kylegospo/grub-btrfs > /dev/null 2>&1
    ok "Enable kylegospo/grub-btrfs COPR"
fi

task "Install grub-btrfs + inotify-tools"
sudo dnf install -y grub-btrfs inotify-tools > /dev/null 2>&1
ok "Install grub-btrfs + inotify-tools"

# Fedora uses grub2 paths — patch the config if not already done
GRUB_BTRFS_CONF="/etc/default/grub-btrfs/config"
task "Configure grub-btrfs for Fedora grub2 paths"
if grep -q "grub2-mkconfig" "$GRUB_BTRFS_CONF" 2>/dev/null; then
    skipped "Configure grub-btrfs for Fedora grub2 paths (already set)"
else
    sudo sed -i \
        -e 's|#GRUB_BTRFS_MKCONFIG=.*|GRUB_BTRFS_MKCONFIG=/usr/sbin/grub2-mkconfig|' \
        -e 's|#GRUB_BTRFS_GRUB_DIRNAME=.*|GRUB_BTRFS_GRUB_DIRNAME="/boot/grub2"|' \
        -e 's|#GRUB_BTRFS_SCRIPT_CHECK=.*|GRUB_BTRFS_SCRIPT_CHECK=grub2-script-check|' \
        "$GRUB_BTRFS_CONF"
    ok "Configure grub-btrfs for Fedora grub2 paths"
fi

task "Enable grub-btrfsd daemon"
sudo systemctl enable --now grub-btrfsd > /dev/null 2>&1
ok "Enable grub-btrfsd daemon"

task "Regenerate GRUB config"
sudo grub2-mkconfig -o /boot/grub2/grub.cfg > /dev/null 2>&1
ok "Regenerate GRUB config"

# --- Summary ---
echo -e "\n${BOLD}${GREEN}  ✔ Snapshots configured.${RESET}"
echo -e "  ${DIM}Useful commands:"
echo -e "    snapper -c root list               — list root snapshots"
echo -e "    snapper -c home list               — list home snapshots"
echo -e "    snapper -c root diff N..M          — diff between snapshots"
echo -e "    snapper -c root undochange N..0    — roll back files to snapshot N"
echo -e "    snapper -c root rollback N         — roll back entire root to snapshot N"
echo -e "    (snapshots also appear in GRUB menu for bootable recovery)${RESET}"
echo ""
