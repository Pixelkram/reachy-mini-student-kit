# Reachy Mini student kit (Windows and Mac)

A one-click setup for programming the **Reachy Mini** robot in Python with a **MuJoCo simulation**, made for students on their own laptops. No admin rights, no prior Python, no robot needed. Code written against the simulator runs unchanged on a real Reachy Mini Lite.

Unofficial teaching kit, built on Pollen Robotics' open-source [`reachy-mini`](https://github.com/pollen-robotics/reachy_mini) SDK. Not affiliated with Pollen Robotics or Hugging Face.

## Install on Windows 10/11

**Option A, one line.** Open the Start menu, type `Terminal`, open it, paste this and press Enter:

```
powershell -ExecutionPolicy Bypass -c "irm https://raw.githubusercontent.com/Pixelkram/reachy-mini-student-kit/main/get-reachy-kit.ps1 | iex"
```

**Option B, ZIP.** Download **[reachy-mini-kit.zip](https://github.com/Pixelkram/reachy-mini-student-kit/releases/latest/download/reachy-mini-kit.zip)**, right-click it, choose **Extract All...**, then double-click `1-INSTALL.cmd` in the extracted folder.

Then: `2-START-SIMULATOR.cmd` opens the 3D simulator, `3-OPEN-VSCODE.cmd` opens VS Code, where **Ctrl+Shift+B** runs the open file. Full guide: [kit/README.md](kit/README.md).

## Install on a Mac (Apple Silicon, macOS 14+)

Needs a Mac with an M1 or newer chip and macOS 14 Sonoma or newer. Intel Macs aren't supported by the current robot software.

**Option A, one line (recommended).** Press Cmd+Space, type `Terminal`, press Enter, paste this and press Enter:

```
curl -fsSL https://raw.githubusercontent.com/Pixelkram/reachy-mini-student-kit/main/get-reachy-kit.sh | bash
```

**Option B, ZIP.** Download **[reachy-mini-kit-mac.zip](https://github.com/Pixelkram/reachy-mini-student-kit/releases/latest/download/reachy-mini-kit-mac.zip)** and unpack it. In Terminal, type `bash `, drag `1-INSTALL.command` into the window, and press Enter (macOS blocks double-clicking downloaded scripts).

Then: `2-START-SIMULATOR.command` opens the 3D simulator, `3-OPEN-VSCODE.command` opens VS Code, where **Cmd+Shift+B** runs the open file. Full guide: [kit-mac/README.md](kit-mac/README.md).

On both systems the kit lands in a `reachy-mini-kit` folder in your home folder (one-liner), and running the same line again later updates the kit while keeping your own files.

## What the installer sets up

- [uv](https://docs.astral.sh/uv/) and a private Python 3.12
- `reachy-mini` 1.12.0 with MuJoCo, all dependencies pinned per platform
- Jupyter kernel *Python (Reachy Mini)* and Pollen's recorded emotion/dance moves
- VS Code with Python and Jupyter extensions (only if VS Code is missing), plus a preconfigured workspace
- Launchers for the simulator and VS Code, and an uninstaller (Windows also gets Start menu and desktop shortcuts)

About 3 GB of disk space and ~1 GB of download are needed.

## Contents

| Path | |
| --- | --- |
| [kit/](kit/) | Windows kit (same content as `reachy-mini-kit.zip`) |
| [kit-mac/](kit-mac/) | Mac kit (same content as `reachy-mini-kit-mac.zip`) |
| [get-reachy-kit.ps1](get-reachy-kit.ps1) | Windows one-line installer and updater |
| [get-reachy-kit.sh](get-reachy-kit.sh) | Mac one-line installer and updater |
| [INSTRUCTOR.md](INSTRUCTOR.md) | Notes for teachers: distribution, what's tested, updating versions |

## Status

- **Windows:** the pinned environment and the examples are tested on Windows 11 x64 (simulator with 3D viewer). A first full run of the kit's installer on a fresh laptop is still pending.
- **Mac:** new and **not yet tested on a real Mac**. The scripts are tested on Linux (including with macOS's bash 3.2), but the Mac-specific steps (3D viewer, VS Code download, macOS permission prompts) still need a first run on an Apple Silicon Mac.

See [INSTRUCTOR.md](INSTRUCTOR.md#tested-vs-not-tested). Feedback and issues are welcome.
