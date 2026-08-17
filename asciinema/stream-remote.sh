#!/usr/bin/env bash
# Stream a session live via the configured asciinema server (asciinema.org
# by default) AND record it to a local .cast file. PUBLIC once running —
# asciinema prints the shareable stream URL on start.
#
# One-time setup per machine account: `asciinema auth` and open the
# printed URL while logged in to your asciinema.org account.
#
# The watcher inside asciinema detaches with Ctrl-A, which ends stream+recording.
#
# Usage: stream-remote.sh [-f] [session] [title] [human-name]
#   The optional human name becomes the cast file prefix:
#   [human]--[session]-[timestamp].cast — it defaults to the title, so a
#   titled stream gets a human-readable archive name for free.
#
# Runs in the background by default and prints the public stream URL
# once the server allocates it (stop with stop-stream.sh); -f keeps it
# in the foreground, where Ctrl-A detaches and ends stream+recording.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

TITLE="${2:-$SESSION}"
CAST="$(new_cast_path "${3:-${2:-}}")"
echo "streaming session '$SESSION' remotely, recording to $CAST" >&2
if [ "$FOREGROUND" = 1 ]; then
    exec asciinema session --stream-remote --output-file "$CAST" \
        --window-size "$WINDOW_SIZE" -t "$TITLE" -c "$WATCH_CMD"
fi
LOG="$TERM_REPLAY_DIR/$SESSION-stream-remote.log"
# Explicit --headless: without it a backgrounded asciinema that still
# has a controlling TTY paints the session onto the launching terminal.
launch_background "$LOG" \
    asciinema session --headless --stream-remote --output-file "$CAST" \
    --window-size "$WINDOW_SIZE" -t "$TITLE" -c "$WATCH_CMD"

# Surface the public URL from the log (the whole point of streaming).
for _ in $(seq 1 15); do
    URL="$(grep -ao 'https://[^ ]*' "$LOG" | head -1 || true)"
    if [ -n "$URL" ]; then
        echo "live at: $URL"
        exit 0
    fi
    sleep 1
done
echo "warning: no stream URL in $LOG yet; check the log" >&2
