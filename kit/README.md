# Reachy Mini student kit

Program the **Reachy Mini** robot (by Pollen Robotics / Hugging Face) in Python and watch it move in a 3D simulation on your own laptop. You don't need a robot: the simulator behaves like a real Reachy Mini Lite, and your code will later run unchanged on the real one.

**You need:** Windows 11 (Windows 10 should also work), about 3 GB of free disk space, an internet connection for the installation. No admin rights and no prior Python installation are needed.

## 1. Install (once, about 5 to 10 minutes)

**Option A, one line** (if your instructor gave you an install command): open the Start menu, type `Terminal`, open it, paste the command, press Enter.

**Option B, ZIP file:**

1. Download `reachy-mini-kit.zip`.
2. **Right-click it and choose "Extract All..."**. Don't run anything from inside the ZIP.
3. In the extracted folder, double-click **`1-INSTALL.cmd`**.
   - If Windows shows *"Windows protected your PC"*, click **More info**, then **Run anyway**.

The installer sets up Python, the robot software, the simulator, VS Code (if you don't have it yet) and creates desktop icons. At the end it asks whether to start everything: press **Enter**.

## 2. Start the simulator

Double-click **`2-START-SIMULATOR.cmd`** (or the **Reachy Mini Simulator** desktop icon). A black window opens and, after a few seconds, a 3D window with the robot on a table.

- Mouse in the 3D window: **left-drag** rotate, **right-drag** move, **scroll** zoom.
- Keep the black window open while you work. **Close it to stop the simulator.**
- If Windows Firewall asks about Python, either choice is fine. The simulator only talks to your own computer.

## 3. Write and run code

Double-click **`3-OPEN-VSCODE.cmd`** (or the **Reachy Mini Code (VS Code)** desktop icon).

- If VS Code asks *"Do you trust the authors of the files in this folder?"*, click **Yes, I trust the authors**.
- Open `my-code/my_first_program.py` and press **Ctrl+Shift+B** to run it. Watch the robot nod in the 3D window.
- **F5** runs the open file in the debugger (breakpoints work).
- Put your own programs in `my-code/`. The `examples/` folder shows more:

| Example | What it shows |
| --- | --- |
| `01_hello_sim.py` | Moving head, antennas and body |
| `02_look_and_read_state.py` | Looking at points in space, reading the robot's position |
| `03_control_loop.py` | Generated motion at 50 updates per second |
| `04_emotions.py` | Playing recorded emotions and dances |
| `05_robot_camera.py` | Seeing what the robot's camera sees |

**Notebook:** open `notebooks/reachy_playground.ipynb` in VS Code. If asked for a kernel, choose **Python (Reachy Mini)**. It has sliders to move the robot live.

**Terminal (optional):** `.\run.cmd examples\01_hello_sim.py` runs any file with the kit's Python.

## Cheat sheet

```python
from reachy_mini import ReachyMini
from reachy_mini.utils import create_head_pose
import numpy as np

with ReachyMini(media_backend="no_media") as mini:     # connect (no camera/audio needed)
    # Smooth move: head up 10 mm, tilted 15 degrees, antennas out, body turned
    mini.goto_target(head=create_head_pose(z=10, roll=15, mm=True, degrees=True),
                     antennas=np.deg2rad([30, -30]),    # [right, left]
                     body_yaw=np.deg2rad(20),
                     duration=1.0)                      # seconds
    mini.look_at_world(0.5, 0.1, 0.0)                   # look at a point (meters: forward, left, up)
    mini.set_target(head=create_head_pose(yaw=10, degrees=True))   # instant, for loops
    pose = mini.get_current_head_pose()                 # where the head is now (4x4 matrix)
```

Motion styles for `goto_target(..., method=...)`: `"minjerk"` (default), `"linear"`, `"ease_in_out"`, `"cartoon"`. Out-of-range targets are limited automatically (head tilt about +-40 degrees, body turn +-160 degrees).

## Troubleshooting

| Problem | Fix |
| --- | --- |
| Program says it can't connect | Start the simulator first and keep its window open. |
| "Port 8000 is already in use" | The simulator is already running in another window. Use that one or close it. |
| Install failed | Run `1-INSTALL.cmd` again (it continues where it stopped). The details are in `logs\install.log`. |
| Simulator window doesn't appear | Look at `logs\sim.log`. Update your graphics driver. On ARM laptops (Snapdragon), see the note below. |
| Notebook: "AsyncToSync ... event loop" error | In notebooks, use `await mini.async_play_move(...)` instead of `mini.play_move(...)`. |
| Warning "IK error ... not achievable" in the simulator window | You asked for a pose the robot can't reach. It moves as close as it can. |
| "Circular buffer overrun" in the simulator window | A program opened the camera without reading it. Use `ReachyMini(media_backend="no_media")` if you don't need the camera. |

**ARM laptops (Snapdragon / Copilot+ PCs):** the kit uses the x64 version of Python, which Windows runs under emulation. This setup hasn't been tested on ARM yet. If the 3D window does not open, installing Microsoft's *OpenCL, OpenGL, and Vulkan Compatibility Pack* from the Microsoft Store may help. Please tell your instructor either way.

Send `logs\install.log` and `logs\sim.log` to your instructor when asking for help.

## Uninstall

Start menu, **Reachy Mini Kit**, **Uninstall Reachy Mini Kit** (or `tools\UNINSTALL.cmd`). This removes the kit's Python environment and shortcuts. Your files stay.

## Learn more

- Reachy Mini documentation: <https://huggingface.co/docs/reachy_mini>
- SDK source and more examples: <https://github.com/pollen-robotics/reachy_mini>
