# common.sh - shared helpers for the Reachy Mini kit scripts on macOS (sourced, not run).
# shellcheck disable=SC2034  # variables are used by the scripts that source this file

TOOLS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIT_DIR="$(cd "$TOOLS_DIR/.." && pwd)"
VENV_PATH_FILE="$TOOLS_DIR/venv-path.txt"
KERNEL_NAME="reachy-mini-kit"
WORKSPACE_FILE="$KIT_DIR/reachy-mini.code-workspace"

# Set REACHY_KIT_TEST_LINUX=1 only to exercise these scripts on Linux (CI/testing).
TEST_LINUX="${REACHY_KIT_TEST_LINUX:-0}"

kit_venv() {
    # Where install.sh put the virtual environment (empty if not installed yet).
    if [ -f "$VENV_PATH_FILE" ]; then
        head -n 1 "$VENV_PATH_FILE"
    fi
}

find_vscode_app() {
    # Prints the path of "Visual Studio Code.app", or nothing.
    local app
    for app in "/Applications/Visual Studio Code.app" "$HOME/Applications/Visual Studio Code.app"; do
        if [ -d "$app" ]; then
            echo "$app"
            return 0
        fi
    done
    if command -v mdfind >/dev/null 2>&1; then
        app="$(mdfind "kMDItemCFBundleIdentifier == 'com.microsoft.VSCode'" 2>/dev/null | head -n 1)"
        if [ -n "$app" ] && [ -d "$app" ]; then
            echo "$app"
            return 0
        fi
    fi
    return 0
}

vscode_cli() {
    # The 'code' command line tool inside the app bundle.
    echo "$1/Contents/Resources/app/bin/code"
}

wait_enter() {
    echo ""
    if [ -r /dev/tty ]; then
        read -r -p "${1:-Press Enter to close this window}" _ </dev/tty || true
    fi
}
