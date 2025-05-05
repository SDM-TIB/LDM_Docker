FROM jupyterhub/jupyterhub:4.1.6
ARG CKAN_STORAGE_PATH
ARG CKAN_SITE_URL

RUN pip install --no-cache \
    oauthenticator \
    dockerspawner \
    jupyterhub-nativeauthenticator \
    jupyterhub-idle-culler \
    flask \
	docker

COPY jupyterhub_config.py /srv/jupyterhub/jupyterhub_config.py
COPY jupyterhub_api.py /srv/jupyterhub/jupyterhub_api.py
COPY api.py /srv/jupyterhub/api.py

# Copy the startup script into the container
COPY start_api.sh /usr/local/bin/start.sh

# Make the startup script executable
RUN chmod +x /usr/local/bin/start.sh

# Expose the necessary ports (informational)
EXPOSE 8000 6000

# Set the startup script as the entrypoint
ENTRYPOINT ["/usr/local/bin/start.sh"]

# CMD ["python", "/srv/jupyterhub/api.py"]
