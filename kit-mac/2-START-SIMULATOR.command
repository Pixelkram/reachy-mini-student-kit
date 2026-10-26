#!/bin/bash
# Reachy Mini kit: start the simulator. Options: empty, --no-media
SELF="$0"; [ -L "$SELF" ] && SELF="$(readlink "$SELF")"
KIT="$(cd "$(dirname "$SELF")" && pwd)"
exec bash "$KIT/tools/start-sim.sh" "$@"
