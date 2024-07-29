from dockerspawner import DockerSpawner
# from nativeauthenticator import NativeAuthenticator
import os
import sys
from tornado import web, gen
# from subprocess import check_call
from traitlets import Unicode
from jupyterhub.auth import Authenticator  # DummyAuthenticator #Authenticator
from urllib.parse import urlparse
import requests


path_file = 'guest_list.txt'
api_token = '71da5210caf07e63a778c1a9f014c3b1c60de0688c1095dd423a3e9f39d313ab'


def get_guest_list():
    user_list = []
    with open(path_file, 'r') as file:
        for line in file:
            # Remove leading and trailing whitespace and add the user to the list
            user_list.append(line.strip())
    return user_list


def remove_user_from_ckan(username):
    ckan_url = 'http://ckan:6500/rm_session_user'
    data = {'username': username}

    response = requests.post(ckan_url, json=data)

    if response.status_code == 200:
        print('Session removed successfully from CKAN user_session dictionary')
    else:
        print('Failed to remove session from CKAN user_session dictionary')


c.Authenticator.auto_login = True
c.JupyterHub.allow_named_servers = True

c.JupyterHub.bind_url = 'http://localhost:8000'
c.JupyterHub.base_url = '/ldmjupyter'


class DummyAuthenticator(Authenticator):
    password = Unicode(
        None,
        allow_none=True,
        config=True,
        help="""
        Set a global password for all users wanting to log in.

        This allows users with any username to log in with the same static password.
        """
    )

    @gen.coroutine
    def authenticate(self, handler, data):
        # Get the request URI
        uri = handler.request.uri
        # Parse the URI to extract the username
        parsed_uri = urlparse(uri)
        # example parsed_uri: ParseResult(scheme='', netloc='', path='/hub/login', params='', query='next=%2Fhub%2Fuser%2Fguest1%2Fnotebooks%2F31614c67-8577-4cef-bd55-a6a18d58d02c_2022-12-27t112011140519.ipynb', fragment='')
        parts = parsed_uri.query.split('%2F')
        username = parts[4]  # username is the four part of the path
        return username


# c.JupyterHub.authenticator_class = NativeAuthenticator #CustomNativeAuthenticator  #NativeAuthenticator
c.JupyterHub.authenticator_class = DummyAuthenticator

c.GenericOAuthenticator.enable_auth_state = True
c.Spawner.http_timeout = 300
c.JupyterHub.log_level = 'DEBUG' # 'WARN'
c.JupyterHub.hub_ip = '0.0.0.0'

c.DockerSpawner.network_name = 'ldmnetwork'

c.DockerSpawner.remove = True
c.DockerSpawner.stop = True


# === Create a docker volume for the guest user with read-only privilege ===
class GuestDockerSpawner(DockerSpawner):
    user_list = get_guest_list()

    def start(self):
        if self.user.name in self.user_list:
            # add team volume to volumes
            self.volumes['/data/LDM_Installer/LDM_Docker_Server_Installed/docker/LDM_data/docker_ckan_storage/notebook'] = {
            # self.volumes['/var/lib/docker/volumes/docker_ckan_storage/_data/notebook'] = {
                # self.volumes['/var/lib/ckan/notebook'] = {
                'bind': self.notebook_dir, #'/home/shared',
                'mode': 'ro',  # or ro for read-only; rw
            }
            # self.notebook_dir = '/home/shared'
            # Set resource limits: memory and CPU
            self.extra_host_config = {
                "mem_limit": "1G",  # Set memory limit to 1GB
                "cpu_period": 100000,  # Set CPU period to 100ms
                "cpu_quota": 50000  # Set CPU quota to 50ms (half a core)
            }
        else:
            self.volumes['jupyterhub-user-{username}'] = {
                'bind': self.notebook_dir,
                'mode': 'ro',  # or ro for read-only; rw
            }
            # self.notebook_dir = '/home/shared'
        return super().start()


c.JupyterHub.spawner_class = GuestDockerSpawner  # DockerSpawner
# c.NativeAuthenticator.create_system_users = True

# c.Spawner.args = ['--NotebookApp.tornado_settings={"headers":{"Content-Security-Policy": "frame-ancestors * self 0.0.0.0:5000"}}']
# c.JupyterHub.tornado_settings = { 'headers': { 'Content-Security-Policy': "frame-ancestors * self 0.0.0.0:5000"} }
# self host_ip:port
c.Spawner.args = ['--NotebookApp.tornado_settings={"headers":{"Content-Security-Policy": "frame-ancestors *;"}}']
c.JupyterHub.tornado_settings = {'headers': {'Content-Security-Policy': "frame-ancestors *;"}}


# notebook_dir = os.environ.get('CKAN_STORAGE_PATH') +'/notebook' #or '/home/jovyan/work'
notebook_dir = '/home/jovyan/work'
c.DockerSpawner.notebook_dir = notebook_dir  # 'LDM_examples_files/RESOURCES/jupyternotebooks/notebook'

# c.DockerSpawner.volumes = { 'jupyterhub-user-{username}': notebook_dir }

c.DockerSpawner.image = "jupyter/datascience-notebook:2023-10-20"
c.Spawner.mem_limit = '1G'
# Persistence
c.JupyterHub.db_url = "sqlite:///data/jupyterhub.sqlite"


# c.Authenticator.admin_users = {'myadmin'}
# c.NativeAuthenticator.open_signup = True

# Enable user registration
#c.Authenticator.allowed_users = set(get_guest_list() + ['myadmin'])
c.Authenticator.allowed_users = set(get_guest_list())


c.JupyterHub.services = [
    {
        'name': 'idle-culler',
        'api_token': api_token,
        'admin': True,
        'oauth_no_confirm': True,
        'command': [
            sys.executable,
            '-m', 'jupyterhub_idle_culler',
            '--timeout=180',
#            '--cull-every=120', # Check every x minutes
#            '--cull-users', # Cull users
#            '--remove-users' # Remove users
        ],
    },
]

c.JupyterHub.load_roles = [
    {
        "name": "list-and-cull", # name the role
        "services": [
            "idle-culler", # assign the service to this role
        ],
        "scopes": [
            # declare what permissions the service should have
            "list:users", # list users
        ],
    }
]

# Shutdown user servers on logout
c.JupyterHub.shutdown_on_logout = True

# c.Application.log_level = 'INFO'

# http://localhost:8000/hub/authorize
# http://localhost:8000/user/myadmin/lab
# http://194.95.158.86:8000/hub/login
