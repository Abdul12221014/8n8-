#!/usr/bin/env bash
set -euo pipefail

# Render provides PORT. n8n expects N8N_PORT. Map it.
export N8N_PORT=${PORT:-5678}

# Recommended n8n runtime flags for hosted usage
export N8N_PROTOCOL=${N8N_PROTOCOL:-https}
export N8N_DIAGNOSTICS_ENABLED=${N8N_DIAGNOSTICS_ENABLED:-false}
export N8N_PERSONALIZATION_ENABLED=${N8N_PERSONALIZATION_ENABLED:-false}
export N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=${N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS:-true}
export N8N_RUNNERS_ENABLED=${N8N_RUNNERS_ENABLED:-true}

exec n8n start


