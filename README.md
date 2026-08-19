# plaza

Allows to replay terminal history and re-connect (dtach / screen / tmux inspired).

A session is a durable place — socket, PID file and replayable history
live together in `$PLAZA_DIR` (default `~/.plaza`) — and every consumer
is just another client: interactive attach (`plaza client`), read-only
viewing (`plaza watch`), web viewers via ttyd, recording and live
streaming via asciinema (see `asciinema/`).

Formerly known as term-replay.
