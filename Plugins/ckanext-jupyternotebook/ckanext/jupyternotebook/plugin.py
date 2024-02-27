import ckan.plugins as plugins
import ckan.plugins.toolkit as toolkit
import ckan.lib.helpers as h
import logging
from ckan.common import config
from .JNFile import JNFile

log = logging.getLogger(__name__)
ignore_empty = plugins.toolkit.get_validator('ignore_empty')



class JupyternotebookPlugin(plugins.SingletonPlugin):
    plugins.implements(plugins.IConfigurer, inherit=True)
    plugins.implements(plugins.IResourceView, inherit=True)

    # IResourceView

    def update_config(self, config_):
        toolkit.add_template_directory(config_, 'templates')
        toolkit.add_public_directory(config_, 'public')
        toolkit.add_resource('fanstatic',
            'jupyternotebook')
        self.formats = ['ipynb']
        jn_filepath_default = "/var/lib/ckan/notebook"
        jn_url_default = "http://localhost:8000/ldmjupyter/notebooks/"
        self.jn_filepath = config.get('ckan.jupyternotebooks_path', jn_filepath_default)
        self.jn_url = config.get('ckan.jupyternotebooks_url', jn_url_default)

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

        self.file = JNFile(filename, resource_id, resource_date, self.jn_filepath, self.jn_url, url_type)
        data_dict['nb_file'] = self.file
        #data_dict['nb_file'].filefullpath = "ERROR"
        return 'jupyternotebook_view.html'

    def form_template(self, context, data_dict):
        return 'jupyternotebook_form.html'
