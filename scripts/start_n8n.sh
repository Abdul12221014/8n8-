#!/usr/bin/env bash
set -euo pipefail

# Load .env if present
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

# Stop existing n8n
pkill -f "node .*n8n" >/dev/null 2>&1 || true

# Start n8n with safe local flags
N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true \
N8N_DIAGNOSTICS_ENABLED=false \
N8N_PERSONALIZATION_ENABLED=false \
N8N_RUNNERS_ENABLED=true \
DB_SQLITE_POOL_SIZE=1 \
nohup n8n start >/tmp/n8n.log 2>&1 &

# Wait until up
for i in {1..60}; do
  if curl -sS http://localhost:5678 >/dev/null 2>&1; then
    echo "n8n is up at http://localhost:5678"
    exit 0
  fi
  sleep 1
done

echo "Timed out waiting for n8n on :5678" >&2
exit 1
