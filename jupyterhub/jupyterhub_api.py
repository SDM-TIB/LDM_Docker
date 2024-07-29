import requests
import json
import os
import logging

logging.basicConfig(level=logging.DEBUG)

log = logging.getLogger(__name__)

# Set the URL of your JupyterHub instance
url_nb = os.getenv('CKAN_JUPYTERNOTEBOOK_URL')
hub_url = url_nb + 'hub/api/users'
# hub_url = 'http://ldm01.develop.service.tib.eu:8000/ldmjupyter/hub/api/users'
# Set the API token for authentication
api_token = '71da5210caf07e63a778c1a9f014c3b1c60de0688c1095dd423a3e9f39d313ab'
path_file = 'guest_list.txt'


def get_guest_list():
    user_list = []
    with open(path_file, 'r') as file:
        for line in file:
            # Remove leading and trailing whitespace and add the user to the list
            user_list.append(line.strip())
    return user_list


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
            print("Failed to parse JSON response:", e)
    else:
        print("Failed to retrieve user information. Status code:", response.status_code)
        return []
    return running_users


def get_free_user():
    guest_list = get_guest_list()
    running_list = get_running_users()
    set_a = set(guest_list)
    set_b = set(running_list)
    # Retrieve elements from set A that are not in set B
    result = set_a - set_b
    if len(result) > 0:
        return result.pop()
    return None
