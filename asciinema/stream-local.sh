#!/usr/bin/env bash
# Stream a session on a local HTTP port AND record it to a .cast file.
# View at http://<ip:port>/ (SSH tunnel for remote viewing).
# The watcher inside asciinema detaches with Ctrl-A, which ends stream+recording.
#
# Usage: stream-local.sh [session] [ip:port]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

ADDR="${2:-127.0.0.1:7682}"
CAST="$(new_cast_path)"
echo "streaming session '$SESSION' on http://$ADDR/ recording to $CAST" >&2
exec asciinema session --stream-local "$ADDR" --output-file "$CAST" \
    --window-size "$WINDOW_SIZE" -c "$WATCH_CMD"
