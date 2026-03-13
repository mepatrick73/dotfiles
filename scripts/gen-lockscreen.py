#!/usr/bin/env python3
"""
Animated torus with two simultaneous rotations:
  - Local:  torus spins around its own symmetry axis  (k revolutions)
  - World:  the tilted torus precesses around world Z  (1 revolution)

Period ratio: T_world = k × T_local  (default k=3)
The camera is fixed so the interplay of the two rotations is clearly visible.
"""

import argparse
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation, PillowWriter
from mpl_toolkits.mplot3d import Axes3D  # noqa: F401

parser = argparse.ArgumentParser()
parser.add_argument("--width",  type=int,   default=960)
parser.add_argument("--height", type=int,   default=540)
parser.add_argument("--frames", type=int,   default=120)
parser.add_argument("--fps",    type=int,   default=30)
parser.add_argument("--ratio",  type=int,   default=3,
                    help="local spins per world revolution")
parser.add_argument("--tilt",   type=float, default=55.0,
                    help="torus axis tilt in degrees")
parser.add_argument("--output", type=str,   default="lockscreen.gif")
args = parser.parse_args()

BG  = "#08080a"
DPI = 100
N   = 60   # mesh resolution

# ── Torus mesh (symmetry axis = Z) ────────────────────────────────────────────
u = np.linspace(0, 2 * np.pi, N)
v = np.linspace(0, 2 * np.pi, N)
U, V = np.meshgrid(u, v)

R, r = 1.0, 0.36
X0 = (R + r * np.cos(V)) * np.cos(U)
Y0 = (R + r * np.cos(V)) * np.sin(U)
Z0 = r * np.sin(V)
pts = np.stack([X0.ravel(), Y0.ravel(), Z0.ravel()], axis=1)


def rot_z(pts, θ):
    c, s = np.cos(θ), np.sin(θ)
    x =  pts[:, 0] * c - pts[:, 1] * s
    y =  pts[:, 0] * s + pts[:, 1] * c
    return np.stack([x, y, pts[:, 2]], axis=1)


def rot_x(pts, θ):
    c, s = np.cos(θ), np.sin(θ)
    y =  pts[:, 1] * c - pts[:, 2] * s
    z =  pts[:, 1] * s + pts[:, 2] * c
    return np.stack([pts[:, 0], y, z], axis=1)


tilt_rad = np.radians(args.tilt)

# ── Figure ─────────────────────────────────────────────────────────────────────
fig = plt.figure(figsize=(args.width / DPI, args.height / DPI), dpi=DPI, facecolor=BG)
ax  = fig.add_axes([0.0, 0.0, 1.0, 1.0], projection='3d')
ax.set_facecolor(BG)
ax.patch.set_alpha(0)
ax.set_axis_off()
for pane in (ax.xaxis.pane, ax.yaxis.pane, ax.zaxis.pane):
    pane.fill = False
    pane.set_edgecolor("none")

lim = R + r + 0.15
ax.set_xlim(-lim, lim)
ax.set_ylim(-lim, lim)
ax.set_zlim(-lim, lim)
ax.set_box_aspect([1, 1, 1])
ax.view_init(elev=28, azim=40)


def draw(frame):
    while ax.collections:
        ax.collections[0].remove()

    t = 2 * np.pi * frame / args.frames

    # 1. Local spin: rotate around torus symmetry axis (Z)
    p = rot_z(pts, args.ratio * t)
    # 2. Tilt the symmetry axis
    p = rot_x(p, tilt_rad)
    # 3. World precession: rotate around world Z
    p = rot_z(p, t)

    X, Y, Z = p[:, 0].reshape(N, N), p[:, 1].reshape(N, N), p[:, 2].reshape(N, N)
    ax.plot_wireframe(X, Y, Z,
                      color="#b8c2cc", alpha=0.38, linewidth=0.55,
                      rstride=2, cstride=2)

    if frame % 20 == 0:
        print(f"  frame {frame}/{args.frames}")


print(f"Rendering {args.frames} frames at {args.width}x{args.height} "
      f"(ratio {args.ratio}:1, tilt {args.tilt}°)...")
ani = FuncAnimation(fig, draw, frames=args.frames, interval=1000 // args.fps)
ani.save(args.output, writer=PillowWriter(fps=args.fps))
print(f"Saved → {args.output}")
