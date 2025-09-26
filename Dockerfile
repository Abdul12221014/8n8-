# Use a specific version with Ubuntu base
FROM n8nio/n8n:0.234.0

# Install netcat for port checking
RUN apt-get update && \
    apt-get install -y --no-install-recommends netcat-traditional && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV NODE_ENV=production \
    N8N_DIAGNOSTICS_ENABLED=false \
    N8N_PERSONALIZATION_ENABLED=false \
    N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true \
    N8N_METRICS_ENABLED=false \
    N8N_USER_MANAGEMENT_DISABLED=true \
    N8N_DEPLOYMENT_TYPE=default \
    N8N_CACHE_ENABLED=true \
    N8N_LOG_LEVEL=error \
    N8N_PROTOCOL=https \
    N8N_EDITOR_BASE_URL=/ \
    N8N_HOST=localhost \
    N8N_SECURITY_RESTRICT_WILDCARDS=true \
    WEBHOOK_TUNNEL_URL=https://localhost:5678/

# Set working directory
WORKDIR /data

# Copy files
COPY workflows ./workflows
COPY scripts/start_render.sh ./scripts/start_render.sh

# Make script executable
RUN chmod +x ./scripts/start_render.sh

# Create and set permissions for n8n user
RUN mkdir -p /home/node/.n8n && \
    chown -R node:node /home/node/.n8n && \
    chown -R node:node /data

# Switch to non-root user
USER node

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:${PORT:-5678}/healthz || exit 1

# Expose port
EXPOSE 5678

# The entrypoint is inherited from the base image

# Render provides PORT. We will set N8N_PORT to PORT at runtime via env.
# Expose is informational only for Docker; Render routes to $PORT.
EXPOSE 5678

# Start via wrapper to map PORT -> N8N_PORT on Render
ENTRYPOINT ["/bin/bash", "/data/scripts/start_render.sh"]


