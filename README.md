# Reachy Mini student kit (Windows)

A one-click setup for programming the **Reachy Mini** robot in Python with a **MuJoCo simulation**, made for students on Windows 11 laptops. No admin rights, no prior Python, no robot needed. Code written against the simulator runs unchanged on a real Reachy Mini Lite.

Unofficial teaching kit, built on Pollen Robotics' open-source [`reachy-mini`](https://github.com/pollen-robotics/reachy_mini) SDK. Not affiliated with Pollen Robotics or Hugging Face.

## Install (students)

**Option A, one line.** Open the Start menu, type `Terminal`, open it, paste this and press Enter:

```
powershell -ExecutionPolicy Bypass -c "irm https://raw.githubusercontent.com/Pixelkram/reachy-mini-student-kit/main/get-reachy-kit.ps1 | iex"
```

This puts the kit in `%USERPROFILE%\reachy-mini-kit` and runs the installer. Running the same line again later updates the kit and keeps your own files.

**Option B, ZIP.** Download **[reachy-mini-kit.zip](https://github.com/Pixelkram/reachy-mini-student-kit/releases/latest/download/reachy-mini-kit.zip)**, right-click it, choose **Extract All...**, then double-click `1-INSTALL.cmd` in the extracted folder.

Then: `2-START-SIMULATOR.cmd` opens the 3D simulator, `3-OPEN-VSCODE.cmd` opens VS Code, where **Ctrl+Shift+B** runs the open file. The full student guide is in [kit/README.md](kit/README.md).

## What the installer sets up

- [uv](https://docs.astral.sh/uv/) and a private Python 3.12
- `reachy-mini` 1.12.0 with MuJoCo and all dependencies pinned ([kit/tools/requirements.lock.txt](kit/tools/requirements.lock.txt))
- Jupyter kernel *Python (Reachy Mini)* and Pollen's recorded emotion/dance moves
- VS Code with Python and Jupyter extensions (only if VS Code is missing), plus a preconfigured workspace
- Start menu and desktop shortcuts, and an uninstaller

The Python environment lives in `%LOCALAPPDATA%\ReachyMiniKit` (outside OneDrive). About 3 GB of disk space and ~1 GB of download are needed.

## Contents

| Path | |
| --- | --- |
| [kit/](kit/) | The kit itself (same content as the release ZIP) |
| [get-reachy-kit.ps1](get-reachy-kit.ps1) | One-line installer and updater |
| [INSTRUCTOR.md](INSTRUCTOR.md) | Notes for teachers: distribution, what's tested, updating versions |

## Status

The pinned environment and the examples are tested on Windows 11 x64 (simulator with 3D viewer). A first full run of this kit's installer on a fresh Windows laptop is still pending, as are Windows on ARM (Snapdragon), user names with special characters and university-managed laptops. See [INSTRUCTOR.md](INSTRUCTOR.md#tested-vs-not-tested). Feedback and issues are welcome.
