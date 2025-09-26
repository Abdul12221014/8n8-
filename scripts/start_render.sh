#!/usr/bin/env bash
set -e

# Wait for port to be available
timeout=30
while ! nc -z localhost ${PORT:-5678} 2>/dev/null; do
  if [ $timeout -le 0 ]; then
    echo "Timed out waiting for port to be available"
    exit 1
  fi
  timeout=$((timeout - 1))
  sleep 1
done

# Start n8n with minimal config
exec n8n start \
  --metrics=false \
  --diagnostics=false \
  --personalization=false \
  --security-restrict-wildcards=true \
  --disable-usage-stats \
  --disable-error-reporting


