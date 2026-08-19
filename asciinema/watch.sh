#!/usr/bin/env bash
# Watch a session read-only in the local terminal (no asciinema involved).
# Detach: Ctrl-\
#
# Usage: watch.sh [session]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

exec term-replay watch -S "$SESSION"
