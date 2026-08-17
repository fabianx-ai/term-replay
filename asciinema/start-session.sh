#!/usr/bin/env bash
# Start a term-replay session server (foreground).
#
# Usage: start-session.sh [session] [command...]
#   start-session.sh                     # session 'term-replay', runs bash -l
#   start-session.sh kimi bash -l        # named session with explicit command
#
# Run this in its own terminal (or under nohup/systemd) — attach to it
# from elsewhere with attach.sh, watch.sh, or the stream-* scripts.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

if [ $# -gt 0 ]; then shift; fi
echo "session '$SESSION' in $TERM_REPLAY_DIR" >&2
exec term-replay server -S "$SESSION" "$@"
