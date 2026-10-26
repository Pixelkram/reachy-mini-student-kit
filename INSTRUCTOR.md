# Reachy Mini student kit: instructor notes

Kit version 2026.10.1: `reachy-mini` 1.12.0, Python 3.12, MuJoCo 3.3.0, all dependencies pinned in `tools/requirements.lock.txt`.

## What students do

1. Get the kit (ZIP or one-liner, see below).
2. `1-INSTALL.cmd`: installs uv, a private Python 3.12, a venv with the pinned packages, the Jupyter kernel *Python (Reachy Mini)*, the recorded emotion/dance datasets, VS Code + Python/Jupyter extensions (via winget, only if VS Code is missing), a generated `reachy-mini.code-workspace`, and Start menu/desktop shortcuts. It ends with an environment check and offers to start the simulator and VS Code.
3. `2-START-SIMULATOR.cmd`: MuJoCo sim, table scene by default (`empty` for the bare robot).
4. `3-OPEN-VSCODE.cmd`: workspace with interpreter, tasks (start simulator, run file on Ctrl+Shift+B, check installation) and F5 debugging preconfigured.

No admin rights needed. Re-running `1-INSTALL.cmd` repairs or updates the setup and doesn't touch students' code.

## Distributing

Published at <https://github.com/Pixelkram/reachy-mini-student-kit>. The ZIP is attached to the latest GitHub release.

- **One-liner** (fewest student errors, no ZIP/SmartScreen steps):

  ```
  powershell -ExecutionPolicy Bypass -c "irm https://raw.githubusercontent.com/Pixelkram/reachy-mini-student-kit/main/get-reachy-kit.ps1 | iex"
  ```

  It extracts to `%USERPROFILE%\reachy-mini-kit` (not synced by OneDrive) and runs the installer. Running it again updates the kit from the latest release: it replaces `tools\`, the launchers and README, adds new example files, and keeps every file the student changed or created.
- **ZIP** (Moodle, Teams, direct link): <https://github.com/Pixelkram/reachy-mini-student-kit/releases/latest/download/reachy-mini-kit.zip>. The README inside tells students to extract it first, which matters: double-clicking inside the ZIP view fails, and `1-INSTALL.cmd` detects that and says so.

The `releases/latest/download/reachy-mini-kit.zip` link always points to the newest release, so it never needs to change.

## Where things end up on a student laptop

| What | Where |
| --- | --- |
| uv | `%USERPROFILE%\.local\bin` |
| Python 3.12 (uv-managed, doesn't interfere with other Pythons) | `%APPDATA%\uv\python` |
| Kit venv (~1.5 GB) | `%LOCALAPPDATA%\ReachyMiniKit\venv`. If the user path has non-ASCII characters (umlauts), `C:\ReachyMiniKit\venv` is used instead, as a precaution for the native libraries. |
| Download cache | `%LOCALAPPDATA%\uv\cache` |
| Recorded moves datasets | `%USERPROFILE%\.cache\huggingface` |
| Jupyter kernel | `%APPDATA%\jupyter\kernels\reachy-mini-kit` |
| Shortcuts | Start menu folder *Reachy Mini Kit*, 2 desktop icons |

If PowerShell scripts are blocked for the user (policy *Restricted*), the installer sets the CurrentUser execution policy to *RemoteSigned*, the same step the official Reachy Mini guide asks for, so VS Code terminals can activate the venv. It changes nothing if a policy is already set (e.g. by IT).

`Uninstall Reachy Mini Kit` in the Start menu removes the venv, kernel, workspace file and shortcuts. It leaves uv, the uv-managed Python and VS Code, since other courses may use them.

## Tested vs. not tested

Tested:
- The SDK, all motion examples (01 to 04), `my_first_program.py` and the notebook ran start to finish against the simulator (headless, Linux).
- The pinned package set is identical to the one that installed and ran on a Windows 11 x64 laptop: sim with 3D viewer and example runs.
- All PowerShell scripts parse and pass PSScriptAnalyzer's compatibility checks for Windows PowerShell 5.1.

Not tested yet:
- A full run of the kit's own installer (`1-INSTALL.cmd`) on Windows, and the camera example `05_robot_camera.py`.
- Windows on ARM (Snapdragon). The installer uses x64 Python under emulation because MuJoCo, GStreamer and the robot's motor/kinematics packages have no Windows-ARM64 wheels. Whether the MuJoCo viewer gets OpenGL there is open.
- User names with umlauts/spaces.
- The winget VS Code install on a machine without VS Code.
- SmartScreen behaviour for the downloaded ZIP.
- University-managed laptops with restricted policies.

## Classroom tips

- The first install downloads about 1 GB per laptop. Ask students to install at home before the first session rather than on shared Wi-Fi.
- Ask for `logs\install.log` and `logs\sim.log` when helping. Both are in the kit folder.
- The notebook's `play_move` gotcha: inside Jupyter, students must use `await mini.async_play_move(...)`.

## Updating the kit

1. Edit `tools/requirements.in` (e.g. a new `reachy-mini` version).
2. Regenerate the lock (on any OS with uv):

   ```
   uv pip compile tools/requirements.in --python-platform x86_64-pc-windows-msvc --python-version 3.12 --annotation-style line --no-header -o tools/requirements.lock.txt
   ```

3. Bump `tools/kit-version.txt`, re-run the examples against the sim, and zip the *contents* of `kit/` so the files sit at the ZIP root (PowerShell, inside `kit`: `Compress-Archive -Path * -DestinationPath ..\reachy-mini-kit.zip -Force`).
4. Commit the changed `kit/` files and create a new GitHub release with `reachy-mini-kit.zip` attached under exactly that name.
5. Students update by running the one-liner again, or by extracting the new ZIP and running its `1-INSTALL.cmd`, which reuses the existing environment and installs the new pinned versions.
