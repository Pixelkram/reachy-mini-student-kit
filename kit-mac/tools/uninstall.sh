#!/bin/bash
# Remove what the Reachy Mini kit installed: its Python environment, Jupyter kernel and
# VS Code workspace file. Your code in the kit folder is NOT deleted. Shared tools (uv,
# the uv-managed Python, VS Code) stay installed, since other projects may use them.
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

echo "This removes the Reachy Mini kit's Python environment (~1.5 GB) and Jupyter kernel."
echo "Your files in $KIT_DIR are kept."
read -r -p "Type YES to continue: " answer </dev/tty || answer=""
if [ "$answer" != "YES" ]; then echo "Cancelled."; wait_enter; exit 0; fi

VENV="$(kit_venv)"
if [ -n "$VENV" ] && [ -d "$VENV" ]; then
    echo "Removing $VENV"
    rm -rf "$VENV"
    rmdir "$(dirname "$VENV")" 2>/dev/null || true
fi
for kdir in "$HOME/Library/Jupyter/kernels/$KERNEL_NAME" "$HOME/.local/share/jupyter/kernels/$KERNEL_NAME"; do
    if [ -d "$kdir" ]; then echo "Removing Jupyter kernel"; rm -rf "$kdir"; fi
done
rm -f "$WORKSPACE_FILE" "$VENV_PATH_FILE"
echo ""
echo "Done. You can delete the kit folder yourself if you don't need your code anymore."
wait_enter
