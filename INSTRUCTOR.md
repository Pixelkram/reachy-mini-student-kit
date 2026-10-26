# Reachy Mini student kit: instructor notes

Kit version 2026.10.1: `reachy-mini` 1.12.0, Python 3.12, MuJoCo 3.3.0. All dependencies are pinned per platform in `kit/tools/requirements.lock.txt` (Windows x64) and `kit-mac/tools/requirements.lock.txt` (macOS 14+, Apple Silicon).

## What students do

| Step | Windows (`kit/`) | Mac (`kit-mac/`) |
| --- | --- | --- |
| Get + install | One-liner, or ZIP + `1-INSTALL.cmd` | One-liner, or ZIP + `bash 1-INSTALL.command` in Terminal |
| Simulator | `2-START-SIMULATOR.cmd` (or desktop icon) | `2-START-SIMULATOR.command` |
| Code | `3-OPEN-VSCODE.cmd`, Ctrl+Shift+B runs the open file | `3-OPEN-VSCODE.command`, Cmd+Shift+B runs the open file |

The installers set up uv, a private Python 3.12, a venv with the pinned packages, the Jupyter kernel *Python (Reachy Mini)*, the recorded emotion/dance datasets, VS Code + Python/Jupyter extensions (only if VS Code is missing) and a generated `reachy-mini.code-workspace` (interpreter, tasks, F5 debugging). They end with an environment check and offer to start the simulator and VS Code. The simulator opens the table scene by default (`empty` for the bare robot).

No admin rights or password needed. Re-running the installer repairs or updates the setup and doesn't touch students' code.

## Distributing

Published at <https://github.com/Pixelkram/reachy-mini-student-kit>. Both ZIPs are attached to the latest GitHub release, and the `releases/latest/download/...` links always point to the newest release.

**Windows**

- One-liner (Start menu > Terminal):

  ```
  powershell -ExecutionPolicy Bypass -c "irm https://raw.githubusercontent.com/Pixelkram/reachy-mini-student-kit/main/get-reachy-kit.ps1 | iex"
  ```

- ZIP: <https://github.com/Pixelkram/reachy-mini-student-kit/releases/latest/download/reachy-mini-kit.zip>. Students must extract it first: double-clicking inside the ZIP view fails, and `1-INSTALL.cmd` detects that and says so.

**Mac** (Apple Silicon, macOS 14 or newer)

- One-liner (Cmd+Space > Terminal). This is the recommended route on Mac because it avoids Gatekeeper entirely:

  ```
  curl -fsSL https://raw.githubusercontent.com/Pixelkram/reachy-mini-student-kit/main/get-reachy-kit.sh | bash
  ```

- ZIP: <https://github.com/Pixelkram/reachy-mini-student-kit/releases/latest/download/reachy-mini-kit-mac.zip>. macOS blocks double-clicking downloaded scripts, so students start the installer with `bash ` + drag `1-INSTALL.command` into Terminal. The installer then clears the quarantine flag on the kit so the other launchers can be double-clicked.

Both one-liners extract to `reachy-mini-kit` in the home folder (not synced by OneDrive or iCloud) and run the installer. Running them again updates the kit from the latest release: they replace `tools/`, the launchers and README, add new example files, and keep every file the student changed or created.

**Intel Macs and macOS 13 or older can't run reachy-mini 1.12.0:** it pins `onnxruntime==1.27.0`, which only has a Mac build for Apple Silicon on macOS 14+. The Mac installer checks this first and stops with a clear message.

## Where things end up on a student laptop

| What | Windows | Mac |
| --- | --- | --- |
| uv | `%USERPROFILE%\.local\bin` | `~/.local/bin` |
| Python 3.12 (uv-managed, doesn't interfere with other Pythons) | `%APPDATA%\uv\python` | `~/.local/share/uv/python` |
| Kit venv (~1.5 GB) | `%LOCALAPPDATA%\ReachyMiniKit\venv` (`C:\ReachyMiniKit\venv` if the user path has non-ASCII characters) | `~/.reachy-mini-kit/venv` |
| Download cache | `%LOCALAPPDATA%\uv\cache` | `~/.cache/uv` |
| Recorded moves datasets | `%USERPROFILE%\.cache\huggingface` | `~/.cache/huggingface` |
| Jupyter kernel | `%APPDATA%\jupyter\kernels\reachy-mini-kit` | `~/Library/Jupyter/kernels/reachy-mini-kit` |
| VS Code (if installed by the kit) | user install via winget | `/Applications` (or `~/Applications` if not writable) |
| Shortcuts | Start menu folder *Reachy Mini Kit*, 2 desktop icons | none (kit folder opens in Finder) |

Windows only: if PowerShell scripts are blocked for the user (policy *Restricted*), the installer sets the CurrentUser execution policy to *RemoteSigned*, the same step the official Reachy Mini guide asks for. It changes nothing if a policy is already set (e.g. by IT).

Mac only: the 3D viewer runs through MuJoCo's `mjpython` launcher, as the official guide requires. The installer also disables GStreamer's Python plugin, which crashes under `mjpython` (documented in the Reachy Mini simulation guide, no effect on audio/video). As a precaution it links `libpython3.12.dylib` into the venv for an older `mjpython`/uv incompatibility ([MuJoCo #1923](https://github.com/google-deepmind/mujoco/issues/1923)).

The uninstaller (Start menu on Windows, `tools/UNINSTALL.command` on Mac) removes the venv, kernel and workspace file (and the Windows shortcuts). It leaves uv, the uv-managed Python and VS Code, since other courses may use them.

## Tested vs. not tested

Tested:
- The SDK, all motion examples (01 to 04), `my_first_program.py` and the notebook ran start to finish against the simulator (headless, Linux).
- Windows: the pinned package set is identical to the one that installed and ran on a Windows 11 x64 laptop, with the 3D viewer and example runs. All PowerShell scripts parse and pass PSScriptAnalyzer's compatibility checks for Windows PowerShell 5.1.
- Mac: the Mac lockfile resolves for macOS 14 / Apple Silicon. All Mac scripts pass shellcheck and ran end to end on Linux in a test mode, also under bash 3.2 (macOS's default bash): install, one-line install and update (student files kept), simulator launcher, port-conflict guard, run.sh, notebook kernel, uninstall.

Not tested yet:
- Windows: a full run of `1-INSTALL.cmd` on Windows, and the camera example `05_robot_camera.py`.
- Windows on ARM (Snapdragon). The installer uses x64 Python under emulation because MuJoCo, GStreamer and the robot's motor/kinematics packages have no Windows-ARM64 wheels. Whether the MuJoCo viewer gets OpenGL there is open.
- Windows: user names with umlauts/spaces, the winget VS Code install on a machine without VS Code, SmartScreen behaviour for the downloaded ZIP, university-managed laptops.
- **Mac: everything Mac-specific has never run on a real Mac.** That covers the `mjpython` 3D viewer, the hardware/version checks, the VS Code download, macOS permission prompts (microphone, local network, Downloads folder) and Gatekeeper behaviour. Have one student with an Apple Silicon Mac run it first and send `logs/install.log` and `logs/sim.log`. Fallback if the 3D window fails: the official Reachy Mini Control app can run the simulation, and the kit's programs connect to it the same way.

## Classroom tips

- The first install downloads about 1 GB per laptop. Ask students to install at home before the first session rather than on shared Wi-Fi.
- Ask for `logs/install.log` and `logs/sim.log` when helping. Both are in the kit folder.
- The notebook's `play_move` gotcha: inside Jupyter, students must use `await mini.async_play_move(...)`.

## Updating the kit

`kit/` (Windows) and `kit-mac/` (Mac) each contain a full copy of `examples/`, `my-code/`, `notebooks/`, `tools/check_env.py` and `tools/requirements.in`. Keep them in sync. The Mac copies only differ in wording (`.command` instead of `.cmd`, Cmd instead of Ctrl).

1. Edit `tools/requirements.in` in both kits (e.g. a new `reachy-mini` version).
2. Regenerate both locks (on any OS with uv):

   ```
   uv pip compile kit/tools/requirements.in --python-platform x86_64-pc-windows-msvc --python-version 3.12 --annotation-style line --no-header -o kit/tools/requirements.lock.txt
   MACOSX_DEPLOYMENT_TARGET=14.0 uv pip compile kit-mac/tools/requirements.in --python-platform aarch64-apple-darwin --python-version 3.12 --annotation-style line --no-header -o kit-mac/tools/requirements.lock.txt
   ```

   If the Mac compile fails, a dependency has no build for Apple Silicon/macOS 14. Check its wheels before raising the deployment target.
3. Bump `tools/kit-version.txt`, re-run the examples against the sim, and zip the *contents* of each kit folder so the files sit at the ZIP root:
   - Windows ZIP, PowerShell inside `kit`: `Compress-Archive -Path * -DestinationPath ..\reachy-mini-kit.zip -Force`
   - Mac ZIP: inside `kit-mac`, `zip -r ../reachy-mini-kit-mac.zip . -x '*__pycache__*'` (Mac/Linux), or on Windows `tar -a -cf ..\reachy-mini-kit-mac.zip *`. Don't use Compress-Archive for the Mac ZIP: Windows PowerShell 5.1 writes backslashes into the ZIP paths. Lost executable bits are fine, because the installer restores them.
4. Commit the changed files and create a new GitHub release with both ZIPs attached under exactly these names: `reachy-mini-kit.zip` and `reachy-mini-kit-mac.zip`.
5. Students update by running their one-liner again, or by extracting the new ZIP and running its installer, which reuses the existing environment and installs the new pinned versions.
