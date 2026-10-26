#!/bin/bash
# Start the Reachy Mini simulator (MuJoCo). Started by 2-START-SIMULATOR.command.
#
#   2-START-SIMULATOR.command              robot on a table with objects (default)
#   2-START-SIMULATOR.command empty        robot alone
#   2-START-SIMULATOR.command --no-media   without simulated camera/audio (lighter)
#
# Your programs connect to http://localhost:8000, exactly like to a real robot.
# Stop: close this window (or press Ctrl+C).

set -uo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

SCENE="minimal"
EXTRA=()
HEADLESS=0
for arg in "$@"; do
    case "$arg" in
        minimal|empty) SCENE="$arg" ;;
        --no-media|-NoMedia) EXTRA+=("--no-media") ;;
        --headless|-Headless) HEADLESS=1 ;;
    esac
done
[ "$TEST_LINUX" = 1 ] && HEADLESS=1

printf '\033]0;Reachy Mini Simulator - close this window to stop\007'

VENV="$(kit_venv)"
PY="$VENV/bin/python"
if [ -z "$VENV" ] || [ ! -x "$PY" ]; then
    echo "The kit is not installed yet. Double-click 1-INSTALL.command first."
    wait_enter; exit 1
fi

# Only one simulator (or robot daemon) can use port 8000
if "$PY" -c "import socket, sys; s = socket.socket(); sys.exit(0 if s.connect_ex(('127.0.0.1', 8000)) == 0 else 1)"; then
    echo "Port 8000 is already in use. Is the simulator already running in another window?"
    echo "Close that window first (or the program using port 8000)."
    wait_enter; exit 1
fi

export NO_PROXY="${NO_PROXY:+$NO_PROXY,}localhost,127.0.0.1"
mkdir -p "$KIT_DIR/logs"
LOG="$KIT_DIR/logs/sim.log"
rm -f "$LOG"

if [ "$HEADLESS" = 1 ]; then
    RUNNER=("$PY")
    EXTRA+=("--headless")
else
    # The 3D window needs MuJoCo's mjpython launcher on macOS. Precaution so it finds
    # libpython (MuJoCo issue #1923 with uv-made environments).
    base_lib="$("$PY" -c 'import os, sys; print(os.path.join(sys.base_prefix, "lib"))')"
    export DYLD_FALLBACK_LIBRARY_PATH="$base_lib${DYLD_FALLBACK_LIBRARY_PATH:+:$DYLD_FALLBACK_LIBRARY_PATH}"
    RUNNER=("$VENV/bin/mjpython")
fi

echo "Starting the Reachy Mini simulator (scene: $SCENE). The 3D window opens in a few seconds."
echo "Mouse in the 3D window: drag to rotate, right-drag (two-finger drag) to move, scroll to zoom."
echo "Keep this window open while you run programs. Close it to stop the simulator."
echo ""
"${RUNNER[@]}" -m reachy_mini.daemon.app.main --sim --scene "$SCENE" --log-file "$LOG" ${EXTRA[@]+"${EXTRA[@]}"}
code=$?
if [ "$code" -ne 0 ]; then
    echo ""
    echo "The simulator stopped (exit code $code). Details: logs/sim.log"
    wait_enter
fi
