#!/bin/bash
# Run a Python file with the kit's Python, e.g.:  ./run.sh examples/01_hello_sim.py
KIT="$(cd "$(dirname "$0")" && pwd)"
VENV="$(head -n 1 "$KIT/tools/venv-path.txt" 2>/dev/null)"
if [ -z "$VENV" ] || [ ! -x "$VENV/bin/python" ]; then
    echo "The kit is not installed yet. Double-click 1-INSTALL.command first."
    exit 1
fi
exec "$VENV/bin/python" "$@"
