#!/usr/bin/env bash
set -euo pipefail

echo "🔧 Fixing workflows with HTTP Request nodes..."

# Load .env if present
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

# Stop existing n8n
echo "Stopping n8n..."
pkill -f "node .*n8n" >/dev/null 2>&1 || true
sleep 2

# Import fixed workflows
echo "Importing fixed workflows..."
n8n import:workflow --input=workflows/onboarding_fixed.json --force
n8n import:workflow --input=workflows/tutor_fixed.json --force

# Activate workflows
echo "Activating workflows..."
n8n update:workflow --id 5SmfM12w7CgNovGf --active=true || true
n8n update:workflow --id FMvUGf9rs9lvzxmx --active=true || true

# Start n8n with environment variables
echo "Starting n8n with fixed workflows..."
N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true \
N8N_DIAGNOSTICS_ENABLED=false \
N8N_PERSONALIZATION_ENABLED=false \
N8N_RUNNERS_ENABLED=true \
N8N_BLOCK_ENV_ACCESS_IN_NODE=false \
DB_SQLITE_POOL_SIZE=1 \
nohup n8n start >/tmp/n8n.log 2>&1 &

# Wait for n8n to be ready
echo "Waiting for n8n to start..."
for i in {1..60}; do
  if curl -sS http://localhost:5678 >/dev/null 2>&1; then
    echo "✅ n8n is running at http://localhost:5678"
    break
  fi
  sleep 1
done

# Test the workflows
echo "Testing workflows..."
./scripts/test_workflows.sh

echo "🎉 Fixed workflows are now running!"
