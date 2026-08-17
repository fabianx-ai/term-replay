# Shared defaults for the asciinema helper scripts. Sourced, not executed.
# Expects the sourcing script's $1 to be the session name (optional).

# Unix sockets live here; the path must stay short (SUN_LEN caps socket
# paths at ~108 bytes, deep directories fail to bind).
export TERM_REPLAY_DIR="${TERM_REPLAY_DIR:-${XDG_RUNTIME_DIR:-/tmp}/term-replay}"
mkdir -p "$TERM_REPLAY_DIR"

SESSION="${1:-term-replay}"

# Ctrl-\ (term-replay's default detach key) is asciinema's own
# pause/resume key, so inside asciinema the watcher detaches with Ctrl-A.
WATCH_CMD="term-replay watch -e ^A -S $SESSION"

# A fixed size keeps the stream and recording stable regardless of the
# local terminal, and sidesteps asciinema's stream relay dying on 0x0
# ptys (headless/script contexts).
WINDOW_SIZE="${WINDOW_SIZE:-120x30}"

CAST_DIR="${CAST_DIR:-$HOME/casts}"
mkdir -p "$CAST_DIR"

new_cast_path() {
    echo "$CAST_DIR/$SESSION-$(date +%Y%m%d-%H%M%S).cast"
}

require() {
    command -v "$1" >/dev/null 2>&1 || {
        echo "error: '$1' not found on PATH" >&2
        exit 1
    }
}

require term-replay
require asciinema
