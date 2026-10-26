"""02 - Look at points in space and read back the robot state.

look_at_world(x, y, z) uses the world frame at the neutral head origin:
x forward, y left, z up, in meters.
"""

import numpy as np

from reachy_mini import ReachyMini
from reachy_mini.utils import create_head_pose
from reachy_mini.utils.rotation import Rotation as R  # scipy-like, ships with the SDK

TARGETS = {
    "front": (0.5, 0.0, 0.0),
    "left, low": (0.4, 0.25, -0.15),
    "right, high": (0.4, -0.25, 0.15),
    "far left": (0.3, 0.4, 0.0),
}


def describe_pose(pose: np.ndarray) -> str:
    """Return xyz (mm) and roll/pitch/yaw (deg) of a 4x4 head pose."""
    xyz_mm = pose[:3, 3] * 1000
    rpy = R.from_matrix(pose[:3, :3]).as_euler("xyz", degrees=True)
    return (
        f"xyz=({xyz_mm[0]:6.1f}, {xyz_mm[1]:6.1f}, {xyz_mm[2]:6.1f}) mm  "
        f"rpy=({rpy[0]:6.1f}, {rpy[1]:6.1f}, {rpy[2]:6.1f}) deg"
    )


with ReachyMini(media_backend="no_media") as mini:
    for name, (x, y, z) in TARGETS.items():
        mini.look_at_world(x, y, z, duration=1.0)
        head_joints, antenna_joints = mini.get_current_joint_positions()
        print(f"{name:12s} -> {describe_pose(mini.get_current_head_pose())}")
        print(f"{'':12s}    head joints (rad): {np.round(head_joints, 3).tolist()}")
        print(f"{'':12s}    antennas    (rad): {np.round(antenna_joints, 3).tolist()}")

    mini.goto_target(head=create_head_pose(), antennas=[0.0, 0.0], duration=1.0)
