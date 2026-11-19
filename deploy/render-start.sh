#!/usr/bin/env bash
set -eu

# Render Free starts from an empty filesystem and has no pre-deploy command.
python -m alembic upgrade head

python -m tracker.worker.scheduler --on-demand &
worker_pid=$!
uvicorn tracker.web.app:app --host 0.0.0.0 --port "${PORT:?Render must provide PORT}" &
web_pid=$!

trap 'kill "$web_pid" "$worker_pid" 2>/dev/null || true; wait || true' EXIT
trap 'exit 0' INT TERM
wait -n "$web_pid" "$worker_pid"
