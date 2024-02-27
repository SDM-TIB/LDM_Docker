
# LDM Service Setup Guide

This guide provides step-by-step instructions for setting up an LDM Service using NGINX as a reverse proxy, configuring environment variables, setting up CKAN entry points, managing Docker containers, and updating configuration files.

## Table of Contents

- [1. NGINX Reverse Proxy Configuration](#1-nginx-reverse-proxy-configuration)
- [2. Environment File Configuration](#2-environment-file-configuration)
- [3. CKAN Entry Point Configuration](#3-ckan-entry-point-configuration)
- [4. Docker Containers Management](#4-docker-containers-management)
- [5. Configuration File Update](#5-configuration-file-update)
- [6. Final Step](#6-final-step)

## 1. NGINX Reverse Proxy Configuration

### Remove Apache2 (If Installed)

To ensure NGINX works correctly, remove Apache2 from your server:

```bash
sudo apt autoremove
sudo apt remove apache2.*
```

### Install NGINX

Install NGINX if it is not already installed:

```bash
sudo apt update
sudo apt install nginx
```

### Configure NGINX for LDM Service

1. Create a configuration file for your website:

    ```bash
    nano /etc/nginx/sites-available/ldmservice
    ```

2. Add the following content to the file:

    ```nginx
    server {
        listen 80;
        server_name coypuldm21.service.tib.eu; # Replace with your server's domain name

        location /ldm_coypu/ldmservice/ { 
            # Important: Replace the paths as per your actual configuration
            rewrite ^/ldm_coypu/ldmservice/(.*)$ /ldm_coypu/ldmservice/$1 redirect;
            add_header 'Access-Control-Allow-Origin' '*';
            rewrite /ldm_coypu/ldmservice(.*) $1 break;
            proxy_pass http://localhost:5000;
            # Timeout and body size configurations
            proxy_connect_timeout 600;
            proxy_send_timeout 600;
            proxy_read_timeout 600;
            send_timeout 600;
            client_max_body_size 2000M;
            # Header configurations
            proxy_set_header X-Forwarded-For $remote_addr;
            proxy_set_header Host $host;
            # Cache configurations
            proxy_cache_bypass $cookie_auth_tkt;
            proxy_no_cache $cookie_auth_tkt;
            proxy_cache_valid 30m;
            proxy_cache_key $host$scheme$proxy_host$request_uri;
        }

        location /ldm_coypu/ldmjupyter/ {
            proxy_pass http://localhost:8000;
            # Header configurations
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
    ```

3. Enable the website in NGINX:

    ```bash
    sudo ln -s /etc/nginx/sites-available/ldmservice /etc/nginx/sites-enabled/
    ```

4. Check for any configuration errors:

    ```bash
    sudo nginx -t
    ```

5. If no issues are found, restart NGINX to apply the changes:

    ```bash
    sudo systemctl restart nginx
    ```

## 2. Environment File Configuration

Update the `.env` file in the root directory where the LDM Docker files are located, changing the following parameters:

```dotenv
CKAN_SITE_URL=https://service.tib.eu/ldm_coypu/ldmservice/
CKAN_JUPYTERNOTEBOOK_URL=https://service.tib.eu/ldm_coypu/ldmjupyter/
```

## 3. CKAN Entry Point Configuration

Adjust the CKAN configuration to match your instance URL:

```bash
ckan config-tool -s app:main $CONFIG "ckan.root_path = /ldm_coypu/ldmservice/{{LANG}}"
```

## 4. Docker Containers Management

Make sure that you have Docker and docker-compose installed
Build and start all containers with the following command:

```bash
docker-compose up -d --build
```

## 5. Configuration File Update

After all containers are up and running, you need to edit the `who.ini` file. Ensure you replace the path to Docker volumes if it has been changed.

```bash
sudo nano /var/lib/docker/volumes/docker_ckan_home/_data/src/ckan
```

Update the following lines as per your configuration:

```ini
post_login_url = /ldm_coypu/ldmservice/user/logged_in
post_logout_url = /ldm_coypu/ldmservice/user/logged_out
```

## 6. Final Step

That's it. You made it :D
