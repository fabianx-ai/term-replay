#!/usr/bin/env bash
# Attach to a session read-write (for the person driving it).
# Detach: Ctrl-\
#
# Usage: attach.sh [session]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

exec plaza client -S "$SESSION"
