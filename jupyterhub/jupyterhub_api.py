import requests
import json
import os
import logging

logging.basicConfig(level=logging.DEBUG)

log = logging.getLogger(__name__)

# Set the URL of your JupyterHub instance
url_nb = os.getenv('CKAN_JUPYTERNOTEBOOK_URL')
hub_url = url_nb + 'hub/api/users'
# Set the API token for authentication
api_token = '71da5210caf07e63a778c1a9f014c3b1c60de0688c1095dd423a3e9f39d313ab'
path_file = 'guest_list.txt'


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
    log.info(response)
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
    log.info(result)
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