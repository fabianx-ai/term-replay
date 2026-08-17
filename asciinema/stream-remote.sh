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

# Reuse the stream ID across restarts so a session keeps one stable
# public URL. First background run saves the server-allocated ID; the
# ID file survives reboots (unlike $TERM_REPLAY_DIR on tmpfs).
STREAM_ID_DIR="${STREAM_ID_DIR:-$HOME/.config/term-replay/streams}"
mkdir -p "$STREAM_ID_DIR"
ID_FILE="$STREAM_ID_DIR/$SESSION.stream-id"
REMOTE_FLAG="--stream-remote"
if [ -s "$ID_FILE" ]; then
    REMOTE_FLAG="--stream-remote=$(cat "$ID_FILE")"
    echo "reusing stream id $(cat "$ID_FILE")" >&2
fi

echo "streaming session '$SESSION' remotely, recording to $CAST" >&2
if [ "$FOREGROUND" = 1 ]; then
    # Foreground reuses a saved ID but cannot capture a fresh one
    # (exec replaces the shell before the URL is known).
    exec asciinema session "$REMOTE_FLAG" --output-file "$CAST" \
        --window-size "$WINDOW_SIZE" -t "$TITLE" -c "$WATCH_CMD"
fi
LOG="$TERM_REPLAY_DIR/$SESSION-stream-remote.log"
# Explicit --headless: without it a backgrounded asciinema that still
# has a controlling TTY paints the session onto the launching terminal.
launch_background "$LOG" \
    asciinema session --headless "$REMOTE_FLAG" --output-file "$CAST" \
    --window-size "$WINDOW_SIZE" -t "$TITLE" -c "$WATCH_CMD"

# Surface the public URL from the log (the whole point of streaming),
# and remember its stream ID for the next start.
for _ in $(seq 1 15); do
    URL="$(grep -ao 'https://[^ ]*' "$LOG" | head -1 || true)"
    if [ -n "$URL" ]; then
        echo "live at: $URL"
        printf '%s\n' "${URL##*/}" > "$ID_FILE"
        exit 0
    fi
    sleep 1
done
echo "warning: no stream URL in $LOG yet; check the log" >&2
