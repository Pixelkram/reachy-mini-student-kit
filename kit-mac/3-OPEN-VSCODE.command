#!/bin/bash
# Reachy Mini kit: open the kit in VS Code with everything preconfigured
SELF="$0"; [ -L "$SELF" ] && SELF="$(readlink "$SELF")"
KIT="$(cd "$(dirname "$SELF")" && pwd)"
bash "$KIT/tools/open-vscode.sh"
