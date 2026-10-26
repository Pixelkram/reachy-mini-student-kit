"""My first Reachy Mini program.

Put your own code in this folder. To run it:
  1. Start the simulator (2-START-SIMULATOR.command, or VS Code task "Reachy: start simulator")
  2. In VS Code press Cmd+Shift+B (runs the open file), or F5 to debug it

The same code runs unchanged on a real Reachy Mini Lite.
"""

import numpy as np

from reachy_mini import ReachyMini
from reachy_mini.utils import create_head_pose

with ReachyMini(media_backend="no_media") as mini:
    # Nod "yes" three times
    for _ in range(3):
        mini.goto_target(head=create_head_pose(pitch=15, degrees=True), duration=0.3)
        mini.goto_target(head=create_head_pose(pitch=-10, degrees=True), duration=0.3)

    # Happy antennas
    mini.goto_target(antennas=np.deg2rad([40, -40]), duration=0.4, body_yaw=None)

    # Back to neutral
    mini.goto_target(head=create_head_pose(), antennas=[0.0, 0.0], duration=1.0)

    # Your turn: try look_at_world(x, y, z), set_target() in a loop,
    # or recorded emotions (see the examples folder).
