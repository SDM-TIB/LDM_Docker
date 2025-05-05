import requests
import json
import os
import logging
import subprocess
import sys

logging.basicConfig(level=logging.INFO)

log = logging.getLogger(__name__)

# Set the URL of your JupyterHub instance
url_nb = os.getenv('CKAN_JUPYTERNOTEBOOK_URL')
hub_url = url_nb + 'hub/api/users'
# Set the API token for authentication
api_token = os.getenv('JUPYTERHUB_API_TOKEN')

def get_guest_list(n):
    """
    Generate the lis of users with the maximum number of concurrent users allowed.

    :param n: maximal amount of guest users
    :return: list of all the users
    """
    return ["guest" + str(i) for i in range(0, int(n))]

def get_running_users():
    # Construct the request headers with the API token
    headers = {
        'Authorization': 'token ' + api_token # f'Bearer {api_token}'
    }
    # Make a GET request to the JupyterHub API endpoint with the authentication token
    response = requests.get(hub_url, headers=headers, verify=False)
    # log.info(f"requests in get_running_users: {requests}")
    # log.info(response.text)
    # Check if the request was successful (status code 200)
    if response.status_code == 200:
        try:
            # Parse the JSON response
            users_info = json.loads(response.text)
            # Extract the list of usernames whose servers are running
            running_users = [user['name'] for user in users_info if user.get('server', {})]
            log.info(running_users)
        except json.JSONDecodeError as e:
            log.info("Failed to parse JSON response:", e)
    else:
        log.info("Failed to retrieve user information. Status code: %s", response.status_code)
        return []
    return running_users


def get_free_user():
    guest_list = get_guest_list(os.getenv('CKAN_JUPYTERHUB_USER'))
    running_list = get_running_users()
    set_a = set(guest_list)
    set_b = set(running_list)
    # Retrieve elements from set A that are not in set B
    result = set_a - set_b
    log.info(f"get_free_user {result}")
    if len(result) > 0:
        return result.pop()
    return None


def restart_jupyterhub():
    try:
        # Kill the JupyterHub process
        result = os.system('pkill -f "/usr/local/bin/jupyterhub"')
        if result == 15:
            log.info("JupyterHub successfully killed")

            # Clean up proxy PID file if it exists
            pid_file = "/srv/jupyterhub/jupyterhub-proxy.pid"
            if os.path.exists(pid_file):
                log.info(f"Removing stale proxy PID file: {pid_file}")
                os.remove(pid_file)

            # Start JupyterHub
            result = os.system('jupyterhub &')
            log.info(result)
            if result == 0:
                log.info("JupyterHub successfully restarted")
                return True
            log.error("Error restarting JupyterHub")
            return False
        else:
            log.error("Error killing JupyterHub")
            return False
    except Exception as e:
        log.error(f"Error restarting JupyterHub: {str(e)}")
        return False

def update_env_variable(updates):
    """Update environment variable"""
    for key, value in updates.items():
        try:
            os.environ[key] = str(value)
        except Exception as e:
            log.error(f"Error updating environment variable {key}: {str(e)}")
            return False
    return True


def copy_notebook_to_container(username, notebook_name):
    """Copy a specific notebook to an existing user's volume"""
    try:
        import docker
        client = docker.from_env()

        # Define volume names
        source_volume = os.getenv('CKAN_STORAGE_NOTEBOOK', '/data/notebooks')
        volume_name = f"jupyterhub-{username}"

        # Command to copy the specific notebook
        copy_cmd = f'mkdir -p /target && cp -R /source/{notebook_name} /target/ 2>/dev/null || echo "File not found" && chown -R 1000:100 /target'

        # Run a temporary container to copy files
        temp_container = client.containers.run(
            "alpine:latest",
            f"sh -c '{copy_cmd}'",
            volumes={
                source_volume: {"bind": "/source", "mode": "ro"},
                volume_name: {"bind": "/target", "mode": "rw"}
            },
            remove=True,
            detach=True,
            network=os.getenv('CKAN_NETWORK')
        )

        # Check results
        result = temp_container.wait()
        if result['StatusCode'] != 0:
            log.error(f"File copy failed: {temp_container.logs().decode('utf-8')}")
            return False
        else:
            log.info(f"Notebook {notebook_name} copied successfully to {username}'s container")
            return True

    except Exception as e:
        log.error(f"Error during notebook copy: {str(e)}")
        return False


def cleanup_unused_volumes():
    """Clean up unused jupyterhub guest volumes"""
    try:
        import docker
        client = docker.from_env()

        # Get list of all volumes
        volumes = client.volumes.list()

        # Get list of guest users
        guest_list = get_guest_list(os.getenv('CKAN_JUPYTERHUB_USER'))

        # Get list of running containers
        running_containers = client.containers.list()

        # Extract volume names that are currently in use
        used_volumes = set()
        for container in running_containers:
            for mount in container.attrs['Mounts']:
                if mount['Type'] == 'volume':
                    used_volumes.add(mount['Name'])

        # Count of removed volumes
        removed_count = 0

        # Check each volume
        for volume in volumes:
            volume_name = volume.name
            # Only process jupyterhub guest volumes
            if volume_name.startswith('jupyterhub-guest'):
                # Extract the username from the volume name
                username = volume_name.replace('jupyterhub-', '')

                # If the volume is not in use and belongs to a guest user, remove it
                if volume_name not in used_volumes and username in guest_list:
                    log.info(f"Removing unused volume: {volume_name}")
                    volume.remove(force=True)
                    removed_count += 1

        log.info(f"Cleanup complete. Removed {removed_count} unused volumes.")
        return removed_count

    except Exception as e:
        log.error(f"Error cleaning up volumes: {str(e)}")
        return -1
