"""Sanity check for the Reachy Mini kit. Run: run.cmd tools\\check_env.py"""

import importlib
import json
import platform
import sys
import urllib.request
from importlib.metadata import PackageNotFoundError, version

ok = True


def report(name: str, good: bool, detail: str = "") -> None:
    global ok
    ok &= good
    print(f"  [{'OK' if good else '!!'}] {name:22s} {detail}")


print(f"Python {platform.python_version()} ({platform.machine()}) at {sys.executable}")
report("python >= 3.11", sys.version_info >= (3, 11))

for dist, module in [
    ("reachy-mini", "reachy_mini"),
    ("mujoco", "mujoco"),
    ("opencv-python", "cv2"),
    ("ipykernel", "ipykernel"),
]:
    try:
        importlib.import_module(module)
        report(dist, True, version(dist))
    except (ImportError, PackageNotFoundError) as e:
        report(dist, False, str(e))

# GStreamer ships as wheels on Windows (gstreamer-bundle) and is needed for media
try:
    import gi

    gi.require_version("Gst", "1.0")
    from gi.repository import Gst

    Gst.init(None)
    report("gstreamer", True, Gst.version_string())
except Exception as e:  # noqa: BLE001
    report("gstreamer", False, f"{e} (only needed for camera/audio)")

# Is a daemon (sim or real robot) running?
try:
    with urllib.request.urlopen("http://localhost:8000/api/daemon/status", timeout=2) as r:
        s = json.load(r)
    mode = "simulation" if s.get("simulation_enabled") else "real robot"
    print(f"\nDaemon running: v{s.get('version')}, {mode}, state={s.get('state')}")
except Exception:
    print("\nDaemon not running (start it with 2-START-SIMULATOR.cmd to run examples).")

print("\nAll good." if ok else "\nSome checks failed, see above.")
sys.exit(0 if ok else 1)
