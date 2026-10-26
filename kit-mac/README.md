# Reachy Mini student kit (Mac)

Program the **Reachy Mini** robot (by Pollen Robotics / Hugging Face) in Python and watch it move in a 3D simulation on your own Mac. You don't need a robot: the simulator behaves like a real Reachy Mini Lite, and your code will later run unchanged on the real one.

**You need:** a Mac with **Apple Silicon** (M1 or newer) and **macOS 14 Sonoma or newer**, about 3 GB of free disk space, and an internet connection for the installation. No admin password and no prior Python installation are needed.

To check your Mac: Apple menu, **About This Mac**. "Chip: Apple M..." means Apple Silicon. Intel Macs can't run the robot software at the moment.

> This Mac version is new and hasn't been tested on a real Mac yet. If something doesn't work, please send your instructor `logs/install.log` (and `logs/sim.log`).

## 1. Install (once, about 5 to 10 minutes)

**Recommended, one line:** press **Cmd+Space**, type `Terminal`, press Enter. Paste this line and press Enter:

```
curl -fsSL https://raw.githubusercontent.com/Pixelkram/reachy-mini-student-kit/main/get-reachy-kit.sh | bash
```

The kit goes into the folder `reachy-mini-kit` in your home folder. Running the same line again later updates the kit and keeps your own files.

**Alternative, ZIP file:** download `reachy-mini-kit-mac.zip` and double-click it to unpack. macOS blocks double-clicking downloaded scripts, so start the installer through Terminal: open Terminal, type `bash ` (with a space), drag **`1-INSTALL.command`** from the unpacked folder into the Terminal window, and press Enter. If macOS asks whether Terminal may access your Downloads folder, click **Allow**.

The installer sets up Python, the robot software, the simulator and VS Code (if you don't have it yet). At the end it asks whether to start everything: press **Enter**.

## 2. Start the simulator

Double-click **`2-START-SIMULATOR.command`** in the kit folder. A Terminal window opens and, after a few seconds, a 3D window with the robot on a table.

- In the 3D window: **drag** to rotate, **right-drag** (or two-finger drag) to move, **scroll** to zoom.
- Keep the Terminal window open while you work. **Close it to stop the simulator.**
- macOS may ask whether Terminal may use the **microphone** (for the simulated robot's audio) or find **devices on your local network**. Your choice doesn't matter for moving the robot. The simulator only talks to your own Mac.

Tip: drag the `reachy-mini-kit` folder into the Finder sidebar so you can always find it.

## 3. Write and run code

Double-click **`3-OPEN-VSCODE.command`**.

- If VS Code asks *"Do you trust the authors of the files in this folder?"*, click **Yes, I trust the authors**.
- Open `my-code/my_first_program.py` and press **Cmd+Shift+B** to run it. Watch the robot nod in the 3D window.
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

**Terminal (optional):** in the kit folder, `./run.sh examples/01_hello_sim.py` runs any file with the kit's Python.

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
| "Intel processor" or "macOS too old" during install | The robot software needs Apple Silicon and macOS 14 or newer. Talk to your instructor. |
| Program says it can't connect | Start the simulator first and keep its window open. |
| "Port 8000 is already in use" | The simulator is already running in another window. Use that one or close it. |
| Install failed | Run the one-line command (or `1-INSTALL.command`) again. Details are in `logs/install.log`. |
| The 3D window doesn't open | Look at `logs/sim.log`. As a fallback, install the official [Reachy Mini Control](https://hf.co/reachy-mini/#/download) app and start the simulation there. Your programs connect to it the same way. |
| Double-clicking a `.command` file is blocked | Run the installer once more (it clears the block), or start it in Terminal with `bash` plus the file. |
| Notebook: "AsyncToSync ... event loop" error | In notebooks, use `await mini.async_play_move(...)` instead of `mini.play_move(...)`. |
| Warning "IK error ... not achievable" in the simulator window | You asked for a pose the robot can't reach. It moves as close as it can. |

## Uninstall

Double-click `tools/UNINSTALL.command`. This removes the kit's Python environment (in `~/.reachy-mini-kit`) and its Jupyter kernel. Your files stay.

## Learn more

- Reachy Mini documentation: <https://huggingface.co/docs/reachy_mini>
- SDK source and more examples: <https://github.com/pollen-robotics/reachy_mini>
