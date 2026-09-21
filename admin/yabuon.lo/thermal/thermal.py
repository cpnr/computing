#!/usr/bin/env python
import argparse
import sys
import numpy as np

sys.path.append("/home/hep/.local/lib/python3.13/site-packages")
import board, busio
import adafruit_mlx90640

DEAD_PIXELS = [(2, 18)]
LOCATION = "hot_aisle"
CAMERA_ID = "mlx90640_1"
HOTSPOT_THRESHOLD_C = 40.0

def init_sensor():
    i2c = busio.I2C(board.SCL, board.SDA)
    mlx = adafruit_mlx90640.MLX90640(i2c)
    mlx.refresh_rate = adafruit_mlx90640.RefreshRate.REFRESH_2_HZ
    return mlx

def read_frame(mlx):
    frame = [0] * 768
    n_error = 0
    while True:
        try:
            mlx.getFrame(frame)
            break
        except ValueError:
            n_error += 1
            continue
    return np.array(frame).reshape((24, 32)), n_error


def clean_frame(arr):
    h, w = arr.shape
    for r, c in DEAD_PIXELS:
        neighbors = [arr[r + dr, c + dc] for dr, dc in [(-1, 0), (1, 0), (0, -1), (0, 1)]
                     if 0 <= r + dr < h and 0 <= c + dc < w and (r + dr, c + dc) not in DEAD_PIXELS]
        arr[r, c] = np.mean(neighbors)
    return arr


def compute_stats(arr):
    return {
        "max_temp": float(arr.max()),
        "min_temp": float(arr.min()),
        "mean_temp": float(arr.mean()),
        "p99_temp": float(np.percentile(arr, 99)),
        "hotspot_pixels": int(np.sum(arr > HOTSPOT_THRESHOLD_C)),
    }

def emit_line_protocol(stats):
    parts = []
    for k, v in stats.items():
        if isinstance(v, int):
            parts.append(f"{k}={v}i")
        else:
            parts.append(f"{k}={v:.2f}")
    print(f"thermal,location={LOCATION},camera_id={CAMERA_ID} " + ",".join(parts), flush=True)

def print_ansi(arr):
    lo, hi = arr.min(), arr.max()
    for row in arr:
        line = ""
        for t in row:
            f = (t - lo) / (hi - lo + 1e-6)
            r = int(255 * min(1, f * 2))
            b = int(255 * min(1, (1 - f) * 2))
            g = int(255 * (1 - abs(f - 0.5) * 2))
            line += f"\033[48;2;{r};{g};{b}m   \033[0m"
        print(line)

def render_matplotlib(arr, path=None, show=False):
    import matplotlib
    if not show:
        matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    from matplotlib.colors import BoundaryNorm
    from matplotlib.patches import Rectangle
    from mpl_toolkits.axes_grid1 import make_axes_locatable
    from datetime import datetime

    below = np.append(np.arange(15, 25, 1.0), 25)
    above = np.concatenate([np.arange(26, 31, 1.0), [35, 40, 70, 130, 200]])
    levels = np.concatenate([below, above])

    cmap = plt.get_cmap("seismic", len(levels) - 1)
    norm = BoundaryNorm(levels, cmap.N)

    fig, ax = plt.subplots(figsize=(5, 5))
    cs = ax.contourf(arr[::-1], levels=levels, cmap=cmap, norm=norm)
    ax.contour(arr[::-1], levels=levels, colors='black', linewidths=0.3, alpha=0.3)
    ax.axis("off")

    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    ax.set_title(timestamp, fontsize=20, loc="left")

    # min/max 위치 찾아서 표시
    max_idx = np.unravel_index(np.argmax(arr), arr.shape)
    min_idx = np.unravel_index(np.argmin(arr), arr.shape)
    h = arr.shape[0]

    for (r, c), val, color, label in [(max_idx, arr[max_idx], "black", "hot"), (min_idx, arr[min_idx], "black", "cool")]:
        y = h - 1 - r
        # 그 픽셀 칸 전체를 사각형으로 감싸기 (칸 중심이 (c, y)이므로 -0.5 오프셋)
        rect = Rectangle((c - 0.5, y - 0.5), 1, 1, fill=False, edgecolor=color, linewidth=1.5)
        ax.add_patch(rect)
        ax.annotate(f"{label} {val:.1f}°C", (c, y), textcoords="offset points",
                    xytext=(8, 8), fontsize=8, color=color,
                    bbox=dict(boxstyle="round,pad=0.2", fc="white", alpha=0.7))

    divider = make_axes_locatable(ax)
    cax = divider.append_axes("right", size="5%", pad=0.05)

    cbar = fig.colorbar(cs, cax=cax, label="°C")
    cbar.set_ticks([15, 20, 25, 30, 35, 40, 70, 130, 200])

    plt.tight_layout()

    if show:
        plt.show()
    else:
        fig.savefig(path, dpi=100, bbox_inches="tight")
    plt.close(fig)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('-m', "--mode", choices=["monitor", "render", "debug"], default="monitor")
    parser.add_argument('-d', "--display", choices=["ansi", "gui"], default="ansi",
                         help="debug 모드에서만 사용")
    parser.add_argument('-o', "--output", default="/tmp/thermal_latest.png")
    args = parser.parse_args()

    mlx = init_sensor()
    arr, n_error = read_frame(mlx)
    arr = clean_frame(arr)
    arr = np.rot90(arr, k=1)
    stats = compute_stats(arr)

    if args.mode == "monitor":
        emit_line_protocol(stats)
    elif args.mode == "render":
        render_matplotlib(arr, path=args.output, show=False)
    elif args.mode == "debug":
        print(f"min: {stats['min_temp']:.1f}  max: {stats['max_temp']:.1f}  errors: {n_error}", file=sys.stderr)
        if args.display == "gui":
            render_matplotlib(arr, show=True)
        else:
            print_ansi(arr)
