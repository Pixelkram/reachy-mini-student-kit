#!/bin/bash
# get-reachy-kit.sh - one-line installer / updater for the Reachy Mini student kit on macOS.
#
# Students run (Cmd+Space, type "Terminal", Enter, paste, Enter):
#   curl -fsSL https://raw.githubusercontent.com/Pixelkram/reachy-mini-student-kit/main/get-reachy-kit.sh | bash
#
# First run: downloads the Mac kit ZIP, extracts it to ~/reachy-mini-kit, runs the installer.
# Later runs: downloads the current ZIP, updates the kit's own files (tools/, launchers, README),
# adds new example files, keeps everything the student changed or created, re-runs the installer.
#
# The ZIP comes from the latest GitHub release of Pixelkram/reachy-mini-student-kit.
# To use another host, set REACHY_KIT_URL.

set -euo pipefail

# Everything runs inside main() so bash reads the whole script before executing it
# (it arrives through a pipe from curl).
main() {
    URL="${REACHY_KIT_URL:-https://github.com/Pixelkram/reachy-mini-student-kit/releases/latest/download/reachy-mini-kit-mac.zip}"
    DEST="${REACHY_KIT_DIR:-$HOME/reachy-mini-kit}"

    echo "Reachy Mini student kit (macOS)"
    TMP="$(mktemp -d)"
    trap 'rm -rf "$TMP"' EXIT

    echo "Downloading $URL ..."
    curl -fsSL "$URL" -o "$TMP/kit.zip"
    unzip -q "$TMP/kit.zip" -d "$TMP/x"

    # The kit's files are either at the ZIP root or inside one top-level folder
    ROOT="$TMP/x"
    if [ ! -f "$ROOT/tools/install.sh" ]; then
        ROOT="$(dirname "$(dirname "$(find "$TMP/x" -maxdepth 3 -path '*/tools/install.sh' | head -n 1)")")"
    fi
    [ -f "$ROOT/tools/install.sh" ] || { echo "Unexpected ZIP layout: tools/install.sh not found."; exit 1; }

    if [ ! -f "$DEST/tools/install.sh" ]; then
        mkdir -p "$(dirname "$DEST")"
        mv "$ROOT" "$DEST"
        echo "Extracted to $DEST"
    else
        echo "Updating the kit in $DEST (your own files are kept) ..."
        (cd "$ROOT" && find . -type f) | while IFS= read -r f; do
            rel="${f#./}"
            case "$rel" in
                tools/*|*.command|run.sh|README.md) kit_owned=1 ;;
                *) kit_owned=0 ;;
            esac
            if [ "$kit_owned" = 1 ] || [ ! -e "$DEST/$rel" ]; then
                mkdir -p "$(dirname "$DEST/$rel")"
                cp -p "$ROOT/$rel" "$DEST/$rel"
            fi
        done
    fi

    # The installer asks questions at the end, so give it the keyboard (stdin is this script).
    if (exec </dev/tty) 2>/dev/null; then
        bash "$DEST/tools/install.sh" </dev/tty
    else
        bash "$DEST/tools/install.sh" --no-prompt
    fi
}

main "$@"
