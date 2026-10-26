#!/bin/bash
# Reachy Mini student kit - installer for macOS (Apple Silicon, macOS 14 or newer).
# Started by 1-INSTALL.command or the one-line installer. No admin password needed.
# Safe to run again (repairs / updates the setup).
#
# Steps: checks -> uv -> Python 3.12 -> virtual environment -> pinned packages ->
#        MuJoCo viewer fix -> Jupyter kernel -> robot motion datasets -> VS Code ->
#        VS Code workspace -> environment check
#
# Options: --no-vscode   do not install VS Code / extensions
#          --no-prompt   do not ask to start the simulator at the end

set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

NO_VSCODE=0
NO_PROMPT=0
for arg in "$@"; do
    case "$arg" in
        --no-vscode) NO_VSCODE=1 ;;
        --no-prompt) NO_PROMPT=1 ;;
    esac
done

mkdir -p "$KIT_DIR/logs"
LOG="$KIT_DIR/logs/install.log"
exec > >(tee "$LOG") 2>&1

# shellcheck disable=SC2317  # called via trap
on_error() {
    echo ""
    echo "INSTALL FAILED (line $1). The full log is in logs/install.log."
    echo "Running the installer again often fixes network hiccups."
    [ "$NO_PROMPT" = 1 ] || wait_enter
}
trap 'on_error $LINENO' ERR

step() { echo ""; echo "==> $*"; }
info() { echo "    $*"; }

echo "Reachy Mini student kit $(head -n 1 "$TOOLS_DIR/kit-version.txt") for macOS"
echo "Kit folder: $KIT_DIR"

# 0. Checks --------------------------------------------------------------------
step "0/8  Checking this Mac"
PY_REQUEST="cpython-3.12-macos-aarch64"
LOCKFILE="$TOOLS_DIR/requirements.lock.txt"
if [ "$TEST_LINUX" = 1 ]; then
    PY_REQUEST="3.12"
    LOCKFILE="$TOOLS_DIR/requirements.in"
    info "TEST MODE on $(uname -s): macOS-only steps are skipped"
else
    if [ "$(uname -s)" != "Darwin" ]; then
        echo "This installer is for macOS. On Windows, use the Windows kit."; exit 1
    fi
    if [ "$(sysctl -n hw.optional.arm64 2>/dev/null || echo 0)" != "1" ]; then
        echo "Sorry: this Mac has an Intel processor. The robot software (reachy-mini) currently"
        echo "needs a Mac with Apple Silicon (M1 or newer). Please ask your instructor."
        exit 1
    fi
    macos_major="$(sw_vers -productVersion | cut -d. -f1)"
    if [ "$macos_major" -lt 14 ]; then
        echo "Sorry: macOS $(sw_vers -productVersion) is too old. The robot software needs macOS 14 (Sonoma)"
        echo "or newer. Update via System Settings > General > Software Update, then run this again."
        exit 1
    fi
    info "Apple Silicon, macOS $(sw_vers -productVersion): OK"
    # Files from a downloaded ZIP are marked as 'from the internet'; clear that so the
    # launchers can be double-clicked later.
    xattr -dr com.apple.quarantine "$KIT_DIR" 2>/dev/null || true
fi
chmod +x "$KIT_DIR"/*.command "$KIT_DIR"/run.sh "$TOOLS_DIR"/*.sh "$TOOLS_DIR"/*.command 2>/dev/null || true

# 1. uv ------------------------------------------------------------------------
step "1/8  uv (Python installer by Astral)"
export PATH="$HOME/.local/bin:$PATH"
if ! command -v uv >/dev/null 2>&1; then
    info "installing uv from astral.sh ..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
fi
uv --version

# 2. Python --------------------------------------------------------------------
step "2/8  Python 3.12"
uv python install "$PY_REQUEST"

# 3. Virtual environment -------------------------------------------------------
step "3/8  Virtual environment"
VENV="$(kit_venv)"
[ -n "$VENV" ] || VENV="$HOME/.reachy-mini-kit/venv"
PY="$VENV/bin/python"
if [ -x "$PY" ]; then
    info "reusing $VENV"
else
    mkdir -p "$(dirname "$VENV")"
    uv venv "$VENV" --python "$PY_REQUEST"
fi
printf '%s\n' "$VENV" > "$VENV_PATH_FILE"

# 4. Packages ------------------------------------------------------------------
step "4/8  Reachy Mini SDK, MuJoCo simulator and tools (first time: ~1 GB download)"
uv pip install --python "$PY" -r "$LOCKFILE"

# 5. MuJoCo viewer fixes (macOS) -----------------------------------------------
step "5/8  MuJoCo 3D viewer fixes"
if [ "$TEST_LINUX" = 1 ]; then
    info "skipped (test mode)"
else
    # Precaution: mjpython (needed for the 3D window on macOS) could not find libpython in
    # uv-made environments with older Python builds (MuJoCo issue #1923). Link it where
    # mjpython looks. Harmless when not needed.
    base_lib="$("$PY" -c 'import os, sys; print(os.path.join(sys.base_prefix, "lib"))')"
    if [ -f "$base_lib/libpython3.12.dylib" ]; then
        mkdir -p "$VENV/lib"
        ln -sf "$base_lib/libpython3.12.dylib" "$VENV/lib/libpython3.12.dylib"
        ln -sf "$base_lib/libpython3.12.dylib" "$VENV/libpython3.12.dylib"
        info "linked libpython3.12.dylib"
    else
        info "WARNING: libpython3.12.dylib not found in $base_lib"
    fi
    # GStreamer's Python plugin crashes under mjpython (documented in the Reachy Mini
    # simulation guide). Disabling it does not affect audio/video.
    gst_py_plugin="$("$PY" -c 'import gstreamer_python, pathlib; print(pathlib.Path(gstreamer_python.__file__).parent / "lib/gstreamer-1.0/libgstpython.dylib")' 2>/dev/null || true)"
    if [ -n "$gst_py_plugin" ] && [ -f "$gst_py_plugin" ]; then
        mv -f "$gst_py_plugin" "$gst_py_plugin.disabled"
        info "disabled GStreamer python plugin"
    fi
fi

# 6. Jupyter kernel + recorded moves -------------------------------------------
step "6/8  Jupyter kernel 'Python (Reachy Mini)' and recorded emotions/dances"
"$PY" -m ipykernel install --user --name "$KERNEL_NAME" --display-name "Python (Reachy Mini)"
HF_HUB_DISABLE_PROGRESS_BARS=1 "$PY" -c "from huggingface_hub import snapshot_download as d; [d(r, repo_type='dataset') for r in ('pollen-robotics/reachy-mini-emotions-library', 'pollen-robotics/reachy-mini-dances-library')]; print('    datasets ok')" \
    || info "datasets skipped (no internet?) - they will download on first use"

# 7. VS Code -------------------------------------------------------------------
step "7/8  VS Code"
APP=""
if [ "$TEST_LINUX" = 1 ] || [ "$NO_VSCODE" = 1 ]; then
    info "skipped"
else
    APP="$(find_vscode_app)"
    if [ -z "$APP" ]; then
        target_dir="/Applications"
        [ -w "$target_dir" ] || target_dir="$HOME/Applications"
        mkdir -p "$target_dir"
        info "downloading VS Code (Microsoft) into $target_dir ..."
        tmp_dir="$(mktemp -d)"
        if curl -fL --progress-bar "https://update.code.visualstudio.com/latest/darwin-universal/stable" -o "$tmp_dir/vscode.zip" \
            && ditto -x -k "$tmp_dir/vscode.zip" "$target_dir"; then
            APP="$target_dir/Visual Studio Code.app"
        else
            info "Could not install VS Code automatically. Get it from https://code.visualstudio.com and run this again."
        fi
        rm -rf "$tmp_dir"
    fi
    if [ -n "$APP" ]; then
        info "VS Code: $APP"
        info "installing extensions: Python, Jupyter"
        "$(vscode_cli "$APP")" --install-extension ms-python.python --install-extension ms-toolsai.jupyter \
            || info "extension install failed, VS Code will offer them when you open the workspace"
    fi
fi

# 8. VS Code workspace ---------------------------------------------------------
step "8/8  VS Code workspace (reachy-mini.code-workspace)"
"$PY" - "$TOOLS_DIR/workspace.template.json" "$WORKSPACE_FILE" "$PY" <<'PYEOF'
import json, sys
template, out, python = sys.argv[1:4]
text = open(template, encoding="utf-8").read()
text = text.replace('"__PYTHON__"', json.dumps(python))
json.loads(text)  # validate
open(out, "w", encoding="utf-8").write(text)
PYEOF
info "interpreter: $PY"

# Check ------------------------------------------------------------------------
step "Checking the installation"
trap - ERR
if "$PY" "$TOOLS_DIR/check_env.py"; then
    echo ""; echo "Installation complete!"
else
    echo ""; echo "Installed, but some checks failed (see above and logs/install.log)."
fi
echo "Next: double-click 2-START-SIMULATOR.command, then 3-OPEN-VSCODE.command"
echo "      and run my-code/my_first_program.py with Cmd+Shift+B."

if [ "$NO_PROMPT" = 0 ] && [ "$TEST_LINUX" = 0 ] && [ -r /dev/tty ]; then
    echo ""
    read -r -p "Start the simulator and open VS Code now? [Y/n] " answer </dev/tty || answer="n"
    case "$answer" in
        [nN]*) open "$KIT_DIR" ;;
        *)
            open "$KIT_DIR/2-START-SIMULATOR.command"
            if [ -n "$APP" ]; then "$(vscode_cli "$APP")" "$WORKSPACE_FILE" || true; fi
            ;;
    esac
fi
exit 0
