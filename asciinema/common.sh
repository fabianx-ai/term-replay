# Shared defaults for the asciinema helper scripts. Sourced, not executed.
# Expects the sourcing script's $1 to be the session name (optional).

# Strip a -f (foreground) flag from any position in the caller's args;
# set -- in a sourced file rewrites the caller's positional parameters.
FOREGROUND=0
_args=()
for _a in "$@"; do
    if [ "$_a" = "-f" ]; then
        FOREGROUND=1
    else
        _args+=("$_a")
    fi
done
set -- "${_args[@]}"
unset _a _args

# Sockets, PID files AND session logs (the replay history) live here —
# so it must be durable storage, not tmpfs, or history dies with a
# reboot. It must also stay short: SUN_LEN caps socket paths at ~108
# bytes, deep directories fail to bind.
export TERM_REPLAY_DIR="${TERM_REPLAY_DIR:-$HOME/.term-replay}"
mkdir -p "$TERM_REPLAY_DIR"
if [ "${#TERM_REPLAY_DIR}" -gt 80 ]; then
    echo "warning: TERM_REPLAY_DIR is ${#TERM_REPLAY_DIR} chars; socket" \
         "paths near 108 bytes fail to bind (SUN_LEN)" >&2
fi

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

# Launch "$@" in the background, logging to $1. Prints the PID and
# fails loudly (with the log tail) if the process dies right away.
# setsid detaches from the controlling terminal: without it the process
# would paint on the launching terminal and die of SIGHUP when that
# terminal closes (asciinema installs its own handler, defeating nohup).
launch_background() {
    local log="$1"
    shift
    setsid "$@" >"$log" 2>&1 </dev/null &
    BG_PID=$!
    sleep 1
    if ! kill -0 "$BG_PID" 2>/dev/null; then
        echo "error: '$1' exited immediately; log tail:" >&2
        tail -5 "$log" >&2
        exit 1
    fi
    echo "started in background: pid $BG_PID, log $log" >&2
}
