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

# Cast names combine a human name with a machine name: the optional $1
# becomes a sanitized human-readable prefix, the session+timestamp part
# stays machine-parsable: [human]--[session]-[timestamp].cast
new_cast_path() {
    local human="${1:-}"
    local machine="$SESSION-$(date +%Y%m%d-%H%M%S)"
    if [ -n "$human" ]; then
        human="$(printf '%s' "$human" | tr -cs 'A-Za-z0-9._-' '-' | sed 's/^-*//; s/-*$//')"
    fi
    if [ -n "$human" ]; then
        echo "$CAST_DIR/$human--$machine.cast"
    else
        echo "$CAST_DIR/$machine.cast"
    fi
}

require() {
    command -v "$1" >/dev/null 2>&1 || {
        echo "error: '$1' not found on PATH" >&2
        exit 1
    }
}

require term-replay
require asciinema
