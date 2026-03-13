#!/bin/bash
# Generate per-monitor wallpapers from current monitor config and start hyprpaper.
# Reads live monitor info via hyprctl so it works on any machine without editing.

HYPR_DIR="$HOME/.config/hypr"
GEN_SCRIPT="$HOME/dotfiles/scripts/gen-wallpaper.py"
CONF="$HYPR_DIR/hyprpaper.conf"

# Generate wallpapers and hyprpaper.conf via Python (handles JSON + rendering)
python3 - <<EOF
import json, subprocess, os, sys

hypr_dir  = os.path.expanduser("~/.config/hypr")
gen_script = os.path.expanduser("~/dotfiles/scripts/gen-wallpaper.py")

result = subprocess.run(["hyprctl", "monitors", "-j"], capture_output=True, text=True)
monitors = json.loads(result.stdout)

preloads   = []
wallpapers = []
generated  = set()  # (width, height) pairs already rendered

for m in monitors:
    name = m["name"]
    # hyprctl reports dimensions already accounting for rotation/transform
    w = m["width"]
    h = m["height"]

    wp_file = os.path.join(hypr_dir, f"wallpaper-{w}x{h}.jpg")

    transform = m.get("transform", 0)
    key = (w, h, transform)

    if key not in generated:
        print(f"Generating {w}x{h} transform={transform} wallpaper for {name}...", flush=True)
        subprocess.run([sys.executable, gen_script,
                        "--width", str(w), "--height", str(h),
                        "--transform", str(transform),
                        "--output", wp_file], check=True)
        generated.add(key)

    preloads.append(f"preload = {wp_file}")
    wallpapers.append(f"wallpaper = {name},{wp_file}")

conf = "\n".join(preloads) + "\n" + "\n".join(wallpapers) + "\nsplash = false\n"
with open(os.path.join(hypr_dir, "hyprpaper.conf"), "w") as f:
    f.write(conf)
print("hyprpaper.conf written.")
EOF

# Start hyprpaper
pkill -x hyprpaper 2>/dev/null
sleep 0.3
hyprpaper &
