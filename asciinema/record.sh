#!/usr/bin/env bash
# Record a session to a .cast file (no streaming).
# The watcher inside asciinema detaches with Ctrl-A, which ends the recording.
#
# Usage: record.sh [session] [human-name|output.cast]
#   A second argument ending in .cast is used as the output path verbatim;
#   anything else becomes the human prefix of the generated name:
#   [human]--[session]-[timestamp].cast
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

case "${2:-}" in
    *.cast) CAST="$2" ;;
    *)      CAST="$(new_cast_path "${2:-}")" ;;
esac
echo "recording session '$SESSION' to $CAST" >&2
exec asciinema rec --window-size "$WINDOW_SIZE" -c "$WATCH_CMD" "$CAST"
