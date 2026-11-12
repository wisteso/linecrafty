#!/usr/bin/env bash
# Linecrafty setup for Linux: finds a Python to run setup.py with, then runs it.
#
# It uses, in order: a python3 (3.8+) on your PATH, the Python inside Comfy Desktop (the AppImage),
# or the Python of a ComfyUI checkout in a common place (~/ComfyUI/venv and similar). So nothing extra
# has to be installed. Any arguments are passed on to setup.py, e.g.:
#   ./setup.sh ~/ComfyUI        use that ComfyUI
#   ./setup.sh -y               don't ask before downloading
set -u

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(dirname "$here")"

# Double-clicked in a file manager with no terminal: reopen in one so the questions can be answered.
if [ ! -t 0 ] && [ ! -t 1 ] && [ -z "${LINECRAFTY_IN_TERMINAL:-}" ] && { [ -n "${DISPLAY:-}" ] || [ -n "${WAYLAND_DISPLAY:-}" ]; }; then
    export LINECRAFTY_IN_TERMINAL=1
    self="$here/$(basename "${BASH_SOURCE[0]}")"
    for t in x-terminal-emulator gnome-terminal konsole xfce4-terminal mate-terminal kitty alacritty xterm; do
        command -v "$t" >/dev/null 2>&1 || continue
        case "$t" in
            gnome-terminal) exec "$t" -- bash "$self" "$@" ;;
            xfce4-terminal|mate-terminal) exec "$t" -x bash "$self" "$@" ;;
            kitty) exec "$t" bash "$self" "$@" ;;
            *) exec "$t" -e bash "$self" "$@" ;;
        esac
    done
fi

pause_if_needed() {
    if [ -n "${LINECRAFTY_IN_TERMINAL:-}" ]; then
        echo
        read -r -p "Press Enter to close..." _ || true
    fi
}

is_python3() {  # a Python 3.8 or newer?
    [ -x "$1" ] && "$1" -c 'import sys; sys.exit(sys.version_info < (3, 8))' >/dev/null 2>&1
}

find_python() {
    local c p rel cfg
    # 1. A python3 on PATH (almost every desktop Linux has one)
    for c in python3 python; do
        p="$(command -v "$c" 2>/dev/null)" && is_python3 "$p" && { echo "$p"; return 0; }
    done
    # 2. Comfy Desktop's own Python. Its installations.json lists each install's "installPath".
    cfg="${XDG_CONFIG_HOME:-$HOME/.config}/Comfy Desktop/installations.json"
    if [ -f "$cfg" ]; then
        while IFS= read -r p; do
            for rel in ComfyUI/.venv/bin/python .venv/bin/python standalone-env/bin/python3; do
                is_python3 "$p/$rel" && { echo "$p/$rel"; return 0; }
            done
        done < <(grep -o '"installPath"[[:space:]]*:[[:space:]]*"[^"]*"' "$cfg" | sed 's/.*:[[:space:]]*"\(.*\)"$/\1/')
    fi
    # 3. A ComfyUI checkout in a common place
    for p in "$HOME/ComfyUI" "$HOME/comfyui" "$HOME/dev/ComfyUI" "$HOME/src/ComfyUI" "$HOME/git/ComfyUI" /opt/ComfyUI; do
        for rel in .venv/bin/python venv/bin/python; do
            is_python3 "$p/$rel" && { echo "$p/$rel"; return 0; }
        done
    done
    return 1
}

if ! py="$(find_python)"; then
    echo
    echo "  Couldn't find Python 3.8+ or a ComfyUI install."
    echo "  Install python3 with your package manager (for example: sudo apt install python3),"
    echo "  or install ComfyUI first (https://www.comfy.org/download), then run this again."
    pause_if_needed
    exit 1
fi

"$py" "$root/setup.py" "$@"
code=$?
pause_if_needed
exit $code
