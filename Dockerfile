# n8n on Render via official image
FROM n8nio/n8n:latest

# Copy workflows into the image (optional convenience)
WORKDIR /data
COPY workflows ./workflows
COPY scripts ./scripts

# Ensure start script exists at the expected path and is executable
COPY scripts/start_render.sh /data/scripts/start_render.sh

# Default environment values can be overridden in Render dashboard
ENV N8N_DIAGNOSTICS_ENABLED=false \
    N8N_PERSONALIZATION_ENABLED=false \
    N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true \
    N8N_RUNNERS_ENABLED=true \
    N8N_METRICS_ENABLED=false \
    N8N_USER_MANAGEMENT_DISABLED=true \
    N8N_DEPLOYMENT_TYPE=default \
    NODE_ENV=production \
    N8N_INIT_TIMEOUT=60

# Render provides PORT. We will set N8N_PORT to PORT at runtime via env.
# Expose is informational only for Docker; Render routes to $PORT.
EXPOSE 5678

# Start via wrapper to map PORT -> N8N_PORT on Render
ENTRYPOINT ["/bin/bash", "/data/scripts/start_render.sh"]


