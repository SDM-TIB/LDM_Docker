# CKAN MCP server (ondata/ckan-mcp-server) for the LDM Assistant (ckanext-mcp_assistant).
# Runs the Streamable HTTP transport on port 3000, inside the Docker network only.
FROM node:22-alpine

ARG CKAN_MCP_SERVER_VERSION=0.4.134
RUN npm install -g @aborruso/ckan-mcp-server@${CKAN_MCP_SERVER_VERSION} \
    && npm cache clean --force

ENV TRANSPORT=http \
    PORT=3000 \
    CKAN_HTTP_HOST=0.0.0.0 \
    NODE_ENV=production

USER node
EXPOSE 3000
CMD ["ckan-mcp-server"]
