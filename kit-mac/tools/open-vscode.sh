#!/bin/bash
# Open the kit in VS Code. Started by 3-OPEN-VSCODE.command.
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

if [ ! -f "$WORKSPACE_FILE" ]; then
    echo "The kit is not installed yet. Double-click 1-INSTALL.command first."
    wait_enter; exit 1
fi
APP="$(find_vscode_app)"
if [ -z "$APP" ]; then
    echo "VS Code was not found. Install it from https://code.visualstudio.com and run 1-INSTALL.command again."
    wait_enter; exit 1
fi
open -a "$APP" "$WORKSPACE_FILE"
