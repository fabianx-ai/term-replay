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
# Usage: stream-remote.sh [session] [title] [human-name]
#   The optional human name becomes the cast file prefix:
#   [human]--[session]-[timestamp].cast — it defaults to the title, so a
#   titled stream gets a human-readable archive name for free.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

TITLE="${2:-$SESSION}"
CAST="$(new_cast_path "${3:-${2:-}}")"
echo "streaming session '$SESSION' remotely, recording to $CAST" >&2
exec asciinema session --stream-remote --output-file "$CAST" \
    --window-size "$WINDOW_SIZE" -t "$TITLE" -c "$WATCH_CMD"
