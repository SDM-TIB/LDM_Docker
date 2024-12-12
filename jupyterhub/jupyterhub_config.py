from dockerspawner import DockerSpawner
import os
import sys
from tornado import web, gen
from traitlets import Unicode
from jupyterhub.auth import Authenticator
from urllib.parse import urlparse, parse_qs
import requests
import re


path_file = 'guest_list.txt'
api_token = '71da5210caf07e63a778c1a9f014c3b1c60de0688c1095dd423a3e9f39d313ab'



def get_guest_list(n):
    """
    Generate the lis of users with the maximum number of concurrent users allowed.

    :param n: maximal amount of guest users
    :return: list of all the users
    """
    return ["guest" + str(i) for i in range(0, int(n))]


c.Authenticator.auto_login = True
c.JupyterHub.allow_named_servers = True

c.JupyterHub.bind_url = 'http://localhost:8000'
c.JupyterHub.base_url = os.getenv('CKAN_JUPYTERHUB_BASE_URL')


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

        # Parse the URI to extract the query string
        parsed_uri = urlparse(uri)
        # example parsed_uri: ParseResult(scheme='', netloc='', path='/hub/login', params='', query='next=%2Fhub%2Fuser%2Fguest1%2Fnotebooks%2F31614c67-8577-4cef-bd55-a6a18d58d02c_2022-12-27t112011140519.ipynb', fragment='')
        query_params = parse_qs(parsed_uri.query)

        # Extract the 'next' parameter from the query string
        next_param = query_params.get('next', [None])[0]

        if next_param:
            # Use regex to find '/user/<username>/' pattern
            match = re.search(r'/user/([^/]+)/', next_param)
            if match:
                username = match.group(1)
                return username
            else:
                return None
        else:
            return None


c.JupyterHub.authenticator_class = DummyAuthenticator

c.GenericOAuthenticator.enable_auth_state = True
c.Spawner.http_timeout = 300
c.JupyterHub.log_level = 'DEBUG' # 'WARN'
c.JupyterHub.hub_ip = '0.0.0.0'

c.DockerSpawner.network_name = os.getenv('CKAN_NETWORK')

c.DockerSpawner.remove = True
c.DockerSpawner.stop = True


# === Create a docker volume for the guest user with read-only privilege ===
class GuestDockerSpawner(DockerSpawner):
    user_list = get_guest_list(os.getenv('CKAN_JUPYTERHUB_USER'))

    def start(self):
        if self.user.name in self.user_list:
            # add team volume to volumes
            self.volumes[os.getenv('CKAN_STORAGE_NOTEBOOK')] = {
            # self.volumes['/var/lib/docker/volumes/docker_ckan_storage/_data/notebook'] = {
                # self.volumes['/var/lib/ckan/notebook'] = {
                'bind': self.notebook_dir, #'/home/shared',
                'mode': 'ro',  # or ro for read-only; rw
            }
            # self.notebook_dir = '/home/shared'
            # Set resource limits: memory and CPU
            self.extra_host_config = {
                "mem_limit": os.getenv('CKAN_JUPYTERHUB_MEMORY_LIMIT'),  # Set memory limit to xG
                "cpu_period": 100000,  # Set CPU period to 100ms
                "cpu_quota": int(os.getenv('CKAN_JUPYTERHUB_PERCENTAGE_CPU')) * 1000  # Set CPU quota to x (x of a core)
            }
        else:
            self.volumes['jupyterhub-user-{username}'] = {
                'bind': self.notebook_dir,
                'mode': 'ro',  # or ro for read-only; rw
            }
            # self.notebook_dir = '/home/shared'
        return super().start() #return super().start()


c.JupyterHub.spawner_class = GuestDockerSpawner  # DockerSpawner
# c.NativeAuthenticator.create_system_users = True


c.Spawner.args = ['--NotebookApp.tornado_settings={"headers":{"Content-Security-Policy": "frame-ancestors *;"}}']
c.JupyterHub.tornado_settings = {'headers': {'Content-Security-Policy': "frame-ancestors *;"}}


notebook_dir = '/home/jovyan/work'
c.DockerSpawner.notebook_dir = notebook_dir  # 'LDM_examples_files/RESOURCES/jupyternotebooks/notebook'


c.DockerSpawner.image = "jupyter/datascience-notebook:latest"
c.Spawner.mem_limit = '1G'
# Persistence
c.JupyterHub.db_url = "sqlite:///data/jupyterhub.sqlite"


# c.Authenticator.admin_users = {'myadmin'}
# c.NativeAuthenticator.open_signup = True

# Enable user registration
#c.Authenticator.allowed_users = set(get_guest_list() + ['myadmin'])
c.Authenticator.allowed_users = set(get_guest_list(os.getenv('CKAN_JUPYTERHUB_USER')))


c.JupyterHub.services = [
    {
        'name': 'idle-culler',
        'api_token': api_token,
        'admin': True,
        'oauth_no_confirm': True,
        'command': [
            sys.executable,
            '-m', 'jupyterhub_idle_culler',
            '--timeout=' + os.getenv('CKAN_JUPYTERHUB_TIMEOUT'),
            '--cull-users', # Cull users
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

# c.DockerSpawner.post_stop_hook = GuestDockerSpawner.post_stop_hook

# Shutdown user servers on logout
c.JupyterHub.shutdown_on_logout = True


# http://localhost:8000/hub/authorize
# http://localhost:8000/user/myadmin/lab
# http://194.95.158.86:8000/hub/login
