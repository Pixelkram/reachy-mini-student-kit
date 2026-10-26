"""05 - See through the robot's eye.

In simulation, MuJoCo renders the head camera ("eye_camera") and streams it
like the real camera. This opens a live OpenCV window while the head scans
the table scene (the default of 2-START-SIMULATOR.command).
Press q in the camera window to quit.
"""

import time

import cv2
import numpy as np

from reachy_mini import ReachyMini
from reachy_mini.utils import create_head_pose

with ReachyMini() as mini:  # default media backend -> camera available
    t0 = time.perf_counter()
    got_frame = False
    while True:
        t = time.perf_counter() - t0
        # Slow scan left/right and a bit down towards the table
        mini.set_target(
            head=create_head_pose(
                yaw=30 * np.sin(2 * np.pi * 0.1 * t), pitch=15, degrees=True
            )
        )
        frame = mini.media.get_frame()
        if frame is not None:
            got_frame = True
            cv2.imshow("Reachy Mini eye camera (q to quit)", frame)
        elif not got_frame and time.perf_counter() - t0 > 10:
            print("No camera frames after 10 s. Was the simulator started with -NoMedia?")
            break
        if cv2.waitKey(1) & 0xFF == ord("q"):
            break
        time.sleep(0.02)

    cv2.destroyAllWindows()
    mini.goto_target(head=create_head_pose(), duration=1.0)
