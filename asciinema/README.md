# asciinema helpers for term-replay

Stream and/or record a term-replay session with [asciinema](https://asciinema.org)
(CLI 3.x — Ubuntu's apt packages 2.x, which cannot stream; use
`cargo install --locked asciinema`). Both `term-replay` and `asciinema`
must be on PATH.

Viewers through these helpers are **read-only twice over**: the scripts
attach with `term-replay watch` (input is discarded by term-replay
itself), and an asciinema stream is a one-way broadcast with no input
channel at all.

## Quickstart

```sh
# Terminal 1 — the session being streamed (e.g. what kimi works in):
./start-session.sh demo bash -l

# Terminal 2 — pick any combination:
./attach.sh demo          # drive the session (read-write, detach: Ctrl-\)
./watch.sh demo           # look over the shoulder (read-only)
./record.sh demo          # -> ~/casts/demo-<timestamp>.cast
./stream-local.sh demo    # live at http://127.0.0.1:7682/ + recording
./stream-remote.sh demo "Porting UML to ARM64"   # PUBLIC stream + recording
```

Cast files combine a human name and a machine name:
`[human]--[session]-[timestamp].cast`. The human part is the third
argument (`stream-local.sh demo 127.0.0.1:7682 uml-day-1`), is
sanitized for filesystem safety, and is omitted from the name when not
given. For `stream-remote.sh` it defaults to the title, so the example
above records to `Porting-UML-to-ARM64--demo-<timestamp>.cast`.

`stream-remote.sh` needs a one-time `asciinema auth` (open the printed
URL while logged in to your asciinema.org account). It prints the public
stream URL when it starts.

## Knobs (environment variables)

| Variable          | Default                             | Meaning                        |
|-------------------|-------------------------------------|--------------------------------|
| `TERM_REPLAY_DIR` | `$XDG_RUNTIME_DIR/term-replay`      | sockets + logs (keep it short) |
| `WINDOW_SIZE`     | `120x30`                            | fixed stream/recording size    |
| `CAST_DIR`        | `~/casts`                           | where recordings land          |

## Gotchas these scripts already handle

- **Socket path length:** Unix sockets cap at ~108 bytes (`SUN_LEN`);
  `TERM_REPLAY_DIR` defaults to the short `$XDG_RUNTIME_DIR/term-replay`.
- **Detach-key collision:** Ctrl-\ (term-replay's default detach) is
  asciinema's pause key, so watchers under asciinema use `-e ^A` —
  detach with Ctrl-A to end a recording/stream.
- **0x0 terminals:** without `--window-size`, asciinema's stream relay
  dies silently when started from a headless/0x0 pty and every web
  viewer gets an instant disconnect.
- **Recording scope:** a recording starts with the session history
  term-replay replays at attach (a burst at t=0) and covers only from
  the moment the script starts — start streaming/recording before the
  interesting work begins.
