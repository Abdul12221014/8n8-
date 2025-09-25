# n8n on Render via official image
FROM n8nio/n8n:latest

# Copy workflows into the image (optional convenience)
WORKDIR /data
COPY workflows ./workflows
COPY scripts ./scripts

# Default environment values can be overridden in Render dashboard
ENV N8N_DIAGNOSTICS_ENABLED=false \
    N8N_PERSONALIZATION_ENABLED=false \
    N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true \
    N8N_RUNNERS_ENABLED=true

# Render provides PORT. We will set N8N_PORT to PORT at runtime via env.
# Expose is informational only for Docker; Render routes to $PORT.
EXPOSE 5678

# Start via wrapper to map PORT -> N8N_PORT on Render
ENTRYPOINT ["/bin/bash", "/data/scripts/start_render.sh"]


