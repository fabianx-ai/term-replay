#!/usr/bin/env bash
# Stop asciinema streams/recordings attached to a session. The session
# itself keeps running — only the asciinema processes watching it stop.
# SIGTERM lets asciinema close remote/local streams and finalize casts.
#
# Only this user's processes are considered. Matches asciinema processes
# whose command watches exactly this session (-S <session>).
#
# Usage: stop-stream.sh [session] [-n]
#   -n  dry run: list what would be stopped without stopping it
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

DRY_RUN="${2:-}"

found=0
for pid in $(pgrep -u "$(id -u)" -x asciinema || true); do
    args="$(ps -o args= -p "$pid" 2>/dev/null || true)"
    case "$args" in
        *"-S $SESSION"|*"-S $SESSION "*|*"-S $SESSION'"*)
            found=1
            if [ "$DRY_RUN" = "-n" ]; then
                echo "would stop: $pid  $args"
            else
                echo "stopping asciinema pid $pid" >&2
                kill "$pid" || true
            fi
            ;;
    esac
done

if [ "$found" = 0 ]; then
    echo "no asciinema stream/recording found for session '$SESSION'" >&2
    exit 1
fi
