#!/usr/bin/env bash
# Stream a session on a local HTTP port AND record it to a .cast file.
# View at http://<ip:port>/ (SSH tunnel for remote viewing).
# The watcher inside asciinema detaches with Ctrl-A, which ends stream+recording.
#
# Usage: stream-local.sh [-f] [session] [ip:port] [human-name]
#   The optional human name becomes the cast file prefix:
#   [human]--[session]-[timestamp].cast
#
# Runs in the background by default (stop with stop-stream.sh); -f keeps
# it in the foreground, where Ctrl-A detaches and ends stream+recording.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

ADDR="${2:-127.0.0.1:7682}"
CAST="$(new_cast_path "${3:-}")"
echo "streaming session '$SESSION' on http://$ADDR/ recording to $CAST" >&2
if [ "$FOREGROUND" = 1 ]; then
    exec asciinema session --stream-local "$ADDR" --output-file "$CAST" \
        --window-size "$WINDOW_SIZE" -c "$WATCH_CMD"
fi
launch_background "$TERM_REPLAY_DIR/$SESSION-stream-local.log" \
    asciinema session --stream-local "$ADDR" --output-file "$CAST" \
    --window-size "$WINDOW_SIZE" -c "$WATCH_CMD"
