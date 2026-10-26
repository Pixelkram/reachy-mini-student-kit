"""01 - Hello sim: first moves of head, antennas and body.

Start the simulator first (2-START-SIMULATOR.command or VS Code task "Reachy: start simulator"),
then run this file. The same code runs unchanged on a real Reachy Mini Lite.
"""

import numpy as np

from reachy_mini import ReachyMini
from reachy_mini.utils import create_head_pose

# media_backend="no_media": we only move the robot here, no camera/audio.
with ReachyMini(media_backend="no_media") as mini:
    print("Connected to Reachy Mini daemon.")

    # Head up 15 mm and tilted 10 degrees (roll)
    mini.goto_target(head=create_head_pose(z=15, roll=10, mm=True, degrees=True), duration=1.0)

    # Look left, then right (yaw)
    mini.goto_target(head=create_head_pose(yaw=35, degrees=True), duration=0.8)
    mini.goto_target(head=create_head_pose(yaw=-35, degrees=True), duration=0.8)

    # Wiggle antennas (radians, [right, left])
    for _ in range(2):
        mini.goto_target(antennas=[0.6, -0.6], duration=0.3, body_yaw=None)
        mini.goto_target(antennas=[-0.6, 0.6], duration=0.3, body_yaw=None)

    # Turn the whole body, with a "cartoon" interpolation for character
    mini.goto_target(body_yaw=np.deg2rad(40), duration=1.2, method="cartoon")

    # Back to neutral
    mini.goto_target(head=create_head_pose(), antennas=[0.0, 0.0], body_yaw=0.0, duration=1.0)
    print("Done.")
