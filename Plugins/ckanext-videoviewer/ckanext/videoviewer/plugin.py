import ckan.plugins as plugins
import ckan.plugins.toolkit as toolkit
import logging

log = logging.getLogger(__name__)
ignore_empty = plugins.toolkit.get_validator('ignore_empty')

class VideoviewerPlugin(plugins.SingletonPlugin):

    '''This plugin makes views of video resources, using an <video> tag'''

    plugins.implements(plugins.IConfigurer, inherit=True)
    plugins.implements(plugins.IResourceView, inherit=True)

    # IResourceView

    def update_config(self, config):
        plugins.toolkit.add_template_directory(config, 'theme/templates')
        self.formats = ['video/mp4', 'video/ogg', 'video/webm', 'mp4', 'ogg', 'webm']

    def info(self):
        return {'name': 'videoviewer',
                'title': plugins.toolkit._('Video'),
                'icon': 'video-camera',
                'schema': {'video_url': [ignore_empty, str]},
                'iframed': False,
                'always_available': False,
                'default_title': plugins.toolkit._('Video'),
                }

    def can_view(self, data_dict):
        return (data_dict['resource'].get('format', '').lower()
                in self.formats)

    def view_template(self, context, data_dict):
        return 'video_view.html'

    def form_template(self, context, data_dict):
        return 'video_form.html'