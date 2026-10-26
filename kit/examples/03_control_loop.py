"""03 - Real-time control loop with set_target().

goto_target() interpolates for you. set_target() sends a target immediately,
which is what you want for generated motion, trackers or joysticks.
Here: a "breathing + figure-eight" idle animation at 50 Hz. Ctrl+C to stop.
"""

import time

import numpy as np

from reachy_mini import ReachyMini
from reachy_mini.utils import create_head_pose

RATE_HZ = 50.0
RUN_SECONDS = 20.0  # set to None to run until Ctrl+C

with ReachyMini(media_backend="no_media") as mini:
    mini.goto_target(head=create_head_pose(), antennas=[0.0, 0.0], duration=1.0)

    t0 = time.perf_counter()
    n = 0
    try:
        while RUN_SECONDS is None or time.perf_counter() - t0 < RUN_SECONDS:
            t = time.perf_counter() - t0
            # Figure-eight with the head (yaw at f, pitch at 2f), slow breathing in z
            yaw = 20 * np.sin(2 * np.pi * 0.25 * t)
            pitch = 8 * np.sin(2 * np.pi * 0.5 * t)
            z = 6 * np.sin(2 * np.pi * 0.2 * t)
            antenna = np.deg2rad(25 * np.sin(2 * np.pi * 0.5 * t))

            mini.set_target(
                head=create_head_pose(z=z, pitch=pitch, yaw=yaw, mm=True, degrees=True),
                antennas=[antenna, -antenna],
            )
            n += 1
            # Sleep until the next tick (keeps the loop rate stable)
            time.sleep(max(0.0, n / RATE_HZ - (time.perf_counter() - t0)))
    except KeyboardInterrupt:
        pass

    elapsed = time.perf_counter() - t0
    print(f"Sent {n} targets in {elapsed:.1f} s ({n / elapsed:.1f} Hz)")
    mini.goto_target(head=create_head_pose(), antennas=[0.0, 0.0], duration=1.0)
