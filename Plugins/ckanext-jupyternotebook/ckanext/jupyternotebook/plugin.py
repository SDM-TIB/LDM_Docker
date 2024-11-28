import ckan.plugins as plugins
import ckan.plugins.toolkit as toolkit
import ckan.lib.helpers as h
import logging
from ckan.common import config
from .JNFile import JNFile
import requests
from ckan.common import request
from hashlib import sha256
import os
import ckanext.jupyternotebook.views as views

logging.basicConfig(level=logging.DEBUG)

log = logging.getLogger(__name__)
ignore_empty = plugins.toolkit.get_validator('ignore_empty')

API_URL = os.getenv(
    'CKAN_API_JUPYTERHUB')  # 'http://jupyterhub:6000'  #os.environ.get('CKAN_STORAGE_PATH') url_nb = os.getenv('CKAN_JUPYTERNOTEBOOK_URL')

dict_user_session = dict()


def get_data_from_api():
    response = requests.get(API_URL + '/get_user')
    if response.status_code == 200:
        data = response.json()
        log.info(data)
        return data['user']
    else:
        log.error('Failed to retrieve data from API')


def generate_session_id():
    # Retrieve IP address and user agent from the request object
    ip_address = request.environ.get('REMOTE_ADDR')
    user_agent = request.environ.get('HTTP_USER_AGENT')

    # Create a unique string based on IP address and user agent
    unique_string = f"{ip_address}-{user_agent}"

    # Hash the unique string to create a session ID
    session_id = sha256(unique_string.encode()).hexdigest()

    return session_id


def get_user_id(session_id):
    # Invert the session dictionary to map session IDs to user IDs
    session_to_user = {v: k for k, v in dict_user_session.items()}
    return session_to_user.get(session_id)


def remove_session_to_user(user):
    if user in dict_user_session:
        dict_user_session.pop(user)


def get_jupyterhub_env_variable(variable_name, default=''):
    """
    Retrieve a JupyterHub-related environment variable.

    :param variable_name: Name of the environment variable
    :param default: Default value if environment variable is not set
    :return: Value of the environment variable or default
    """
    return os.getenv(variable_name, default)


class JupyternotebookPlugin(plugins.SingletonPlugin):
    plugins.implements(plugins.IConfigurer, inherit=True)
    plugins.implements(plugins.IResourceView, inherit=True)
    plugins.implements(plugins.IBlueprint, inherit=True)
    plugins.implements(plugins.ITemplateHelpers)
    url_nb = os.getenv('CKAN_JUPYTERNOTEBOOK_URL')

    # IResourceView

    def update_config(self, config_):
        toolkit.add_template_directory(config_, 'templates')
        toolkit.add_public_directory(config_, 'public')
        # toolkit.add_resource('fanstatic', 'jupyternotebook')
        toolkit.add_resource('static', 'jupyternotebook')
        if toolkit.check_ckan_version(min_version='2.10'):
            icon = 'magnifying-glass'
        else:
            icon = 'fa fa-file-code-o'  # 'search'
        toolkit.add_ckan_admin_tab(config_, 'jupyternotebook_admin.admin', 'JupyterHub', icon=icon)
        self.formats = ['ipynb']
        jn_filepath_default = "/var/lib/ckan/notebook"
        # jn_filepath_default = "/var/lib/docker/volumes/docker_ckan_storage/_data/notebook"
        jn_url_default = self.url_nb + "user/" + get_data_from_api() + "/notebooks/"  # "http://localhost:8000/user/guest1/notebooks/" # "http://localhost:8000/ldmjupyter/notebooks/"
        self.jn_filepath = config.get('ckan.jupyternotebooks_path', jn_filepath_default)
        self.jn_url = jn_url_default  # config.get('ckan.jupyternotebooks_url', jn_url_default)

        # dict_user_session[user] = session_id

    def get_blueprint(self):
        return views.get_blueprints()

    def get_helpers(self):
        # Register the helper function here
        return {
            'get_jupyterhub_env_variable': get_jupyterhub_env_variable
        }

    def info(self):
        return {'name': 'jupyternotebook',
                'title': plugins.toolkit._('Jupyternotebook'),
                'icon': 'video-camera',
                'schema': {'jupyternotebook_url': [ignore_empty, str]},
                'iframed': False,
                'always_available': False,
                'default_title': plugins.toolkit._('Jupyternotebook'),
                }

    def can_view(self, data_dict):
        return (data_dict['resource'].get('format', '').lower()
                in self.formats)

    def view_template(self, context, data_dict):
        filename = data_dict['resource_view'].get('jupyternotebook_url') or data_dict['resource'].get('url')
        resource_id = data_dict['resource'].get('id')
        resource_date = data_dict['resource'].get('last_modified')
        url_type = data_dict['resource'].get('url_type')

        session_id = generate_session_id()
        log.info(session_id)
        if session_id in dict_user_session.values():
            user = get_user_id(session_id)
        else:
            user = get_data_from_api()
            if user is None:
                toolkit.h.flash_success(toolkit._('Sorry, there is not more free JupyterHub user, wait few minutes please.'))
                # Return the new template when no users are available
                data_dict['nb_file'] = "ERROR"
                data_dict['home_url'] = h.url_for('home')
                return 'jupyterhub_no_users.html'
            dict_user_session[user] = session_id
        jn_url = self.url_nb + "user/" + user + "/notebooks/"
        log.info(dict_user_session)
        log.info(jn_url)
        # jn_url = "http://localhost:8000/user/" + get_data_from_api() + "/notebooks/"
        self.file = JNFile(filename, resource_id, resource_date, self.jn_filepath, jn_url, url_type)
        # self.file = JNFile(filename, resource_id, resource_date, self.jn_filepath, self.jn_url, url_type)
        data_dict['nb_file'] = self.file
        # data_dict['nb_file'].filefullpath = "ERROR"
        return 'jupyternotebook_view.html'

    def form_template(self, context, data_dict):
        return 'jupyternotebook_form.html'
