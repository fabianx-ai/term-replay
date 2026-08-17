#!/usr/bin/env bash
# Record a session to a .cast file (no streaming).
# The watcher inside asciinema detaches with Ctrl-A, which ends the recording.
#
# Usage: record.sh [session] [output.cast]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

CAST="${2:-$(new_cast_path)}"
echo "recording session '$SESSION' to $CAST" >&2
exec asciinema rec --window-size "$WINDOW_SIZE" -c "$WATCH_CMD" "$CAST"
