#!/bin/bash
# Reachy Mini kit: one-time setup (about 5-10 minutes, no admin password needed)
SELF="$0"; [ -L "$SELF" ] && SELF="$(readlink "$SELF")"
KIT="$(cd "$(dirname "$SELF")" && pwd)"
bash "$KIT/tools/install.sh" "$@"
