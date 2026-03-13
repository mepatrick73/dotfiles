#!/usr/bin/env python3
"""Generate a dark wireframe topology wallpaper — Gestalt-informed layout."""

import argparse
import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D  # noqa: F401

parser = argparse.ArgumentParser()
parser.add_argument("--width",  type=int, default=2560)
parser.add_argument("--height", type=int, default=1440)
parser.add_argument("--output", type=str, default="/home/patrick/dotfiles/.config/hypr/wallpaper.jpg")
args = parser.parse_args()

W, H, DPI = args.width, args.height, 100
OUTPUT = args.output
BG = "#08080a"

fig = plt.figure(figsize=(W / DPI, H / DPI), dpi=DPI, facecolor=BG)

# ── Perspective grid floor ────────────────────────────────────────────────────
grid_ax = fig.add_axes([0, 0, 1, 1], zorder=0)
grid_ax.set_xlim(0, 1)
grid_ax.set_ylim(0, 1)
grid_ax.set_axis_off()
grid_ax.patch.set_alpha(0)

vp = (0.5, 0.28)
horizon_y = vp[1]
grid_color = "#161a1e"
grid_alpha = 0.9
lw = 0.5

n_radial = 32
x_spread = np.linspace(-0.2, 1.2, n_radial)
for x in x_spread:
    grid_ax.plot([vp[0], x], [vp[1], 0.0],
                 color=grid_color, alpha=grid_alpha, linewidth=lw,
                 transform=fig.transFigure, zorder=0)

n_horiz = 14
for i in range(1, n_horiz + 1):
    t = (i / n_horiz) ** 1.6
    y = horizon_y * (1 - t)
    x_left  = vp[0] + (x_spread[0]  - vp[0]) * (vp[1] - y) / vp[1]
    x_right = vp[0] + (x_spread[-1] - vp[0]) * (vp[1] - y) / vp[1]
    grid_ax.plot([x_left, x_right], [y, y],
                 color=grid_color, alpha=grid_alpha, linewidth=lw,
                 transform=fig.transFigure, zorder=0)

grid_ax.plot([0, 1], [horizon_y, horizon_y], color=grid_color,
             alpha=min(grid_alpha * 1.5, 1.0), linewidth=0.7,
             transform=fig.transFigure, zorder=0)


# ── 3D axes helper ────────────────────────────────────────────────────────────
def make_ax(rect, elev=20, azim=30):
    ax = fig.add_axes(rect, projection="3d")
    ax.set_facecolor(BG)
    ax.patch.set_alpha(0)
    ax.set_axis_off()
    for pane in (ax.xaxis.pane, ax.yaxis.pane, ax.zaxis.pane):
        pane.fill = False
        pane.set_edgecolor("none")
    ax.view_init(elev=elev, azim=azim)
    return ax


def add_label(ax, label, euler):
    ax.text2D(0.5, -0.05, label, transform=ax.transAxes,
              ha="center", color="#484e56", fontsize=15,
              fontfamily="monospace", fontweight="bold")
    ax.text2D(0.5, -0.11, euler, transform=ax.transAxes,
              ha="center", color="#2c3036", fontsize=11,
              fontfamily="monospace")


# ── Layout: diagonal stagger, size/brightness progression ────────────────────
# Rects are [left, bottom, width, height] in figure fraction
# Aspect ratio aware: keep shapes visually similar across different resolutions
ar = W / H  # aspect ratio

def scale_rect(left, bottom, w, h):
    """Adjust rect so shapes stay proportional regardless of resolution."""
    return [left, bottom, w * (1440 / H), h * (1440 / H) * ar / (2560 / W)]

# ── S² ────────────────────────────────────────────────────────────────────────
ax1 = make_ax(scale_rect(0.04, 0.18, 0.26, 0.54), elev=28, azim=35)
u = np.linspace(0, 2 * np.pi, 42)
v = np.linspace(0, np.pi, 21)
U, V = np.meshgrid(u, v)
ax1.plot_wireframe(
    np.cos(U) * np.sin(V), np.sin(U) * np.sin(V), np.cos(V),
    color="#9aa4ae", alpha=0.26, linewidth=0.35, rstride=1, cstride=1,
)
ax1.set_box_aspect([1, 1, 1])
add_label(ax1, "S²", "χ = 2")

# ── T² ────────────────────────────────────────────────────────────────────────
ax2 = make_ax(scale_rect(0.355, 0.21, 0.29, 0.58), elev=30, azim=50)
u = np.linspace(0, 2 * np.pi, 60)
v = np.linspace(0, 2 * np.pi, 30)
U, V = np.meshgrid(u, v)
R, r = 1.0, 0.42
ax2.plot_wireframe(
    (R + r * np.cos(V)) * np.cos(U),
    (R + r * np.cos(V)) * np.sin(U),
    r * np.sin(V),
    color="#b8c2cc", alpha=0.30, linewidth=0.38, rstride=1, cstride=1,
)
ax2.set_box_aspect([1, 1, 0.45])
lim = R + r + 0.1
ax2.set_xlim(-lim, lim)
ax2.set_ylim(-lim, lim)
ax2.set_zlim(-r - 0.1, r + 0.1)
add_label(ax2, "T²", "χ = 0")

# ── Klein ─────────────────────────────────────────────────────────────────────
ax3 = make_ax(scale_rect(0.675, 0.24, 0.30, 0.58), elev=20, azim=60)
u = np.linspace(0, 2 * np.pi, 64)
v = np.linspace(0, 2 * np.pi, 64)
U, V = np.meshgrid(u, v)
r = 1 - np.cos(U) / 2
X = np.where(
    U < np.pi,
    6 * np.cos(U) * (1 + np.sin(U)) + 4 * r * np.cos(U) * np.cos(V),
    6 * np.cos(U) * (1 + np.sin(U)) + 4 * r * np.cos(V + np.pi),
)
Y = np.where(U < np.pi, 16 * np.sin(U) + 4 * r * np.sin(U) * np.cos(V), 16 * np.sin(U))
Z = 4 * r * np.sin(V)
ax3.plot_wireframe(X / 22, Y / 22, Z / 22,
                   color="#c8d0d8", alpha=0.34, linewidth=0.42, rstride=1, cstride=1)
ax3.set_box_aspect([1, 1, 1])
add_label(ax3, "Klein", "χ = 0")

fig.savefig(OUTPUT, dpi=DPI, facecolor=BG, pil_kwargs={"quality": 95})
print(f"Saved {W}x{H} → {OUTPUT}")
