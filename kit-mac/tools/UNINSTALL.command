#!/bin/bash
# Reachy Mini kit: remove the kit's Python environment and Jupyter kernel (your files stay)
SELF="$0"; [ -L "$SELF" ] && SELF="$(readlink "$SELF")"
bash "$(cd "$(dirname "$SELF")" && pwd)/uninstall.sh"
