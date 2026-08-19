#!/usr/bin/env bash
# Start a term-replay session server (foreground).
#
# Usage: start-session.sh [-f] [session] [command...]
#   start-session.sh                     # session 'term-replay', runs bash -l
#   start-session.sh kimi bash -l        # named session with explicit command
#
# Runs in the background by default (log in $TERM_REPLAY_DIR); -f keeps
# it in the foreground. Attach from elsewhere with attach.sh, watch.sh,
# or the stream-* scripts.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

if [ $# -gt 0 ]; then shift; fi
echo "session '$SESSION' in $TERM_REPLAY_DIR" >&2
if [ "$FOREGROUND" = 1 ]; then
    exec term-replay server -S "$SESSION" "$@"
fi
launch_background "$TERM_REPLAY_DIR/$SESSION-server.log" \
    term-replay server -S "$SESSION" "$@"
