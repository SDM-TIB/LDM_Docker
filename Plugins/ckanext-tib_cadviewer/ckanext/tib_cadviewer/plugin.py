import ckan.plugins as plugins
import ckan.plugins.toolkit as toolkit

ignore_empty = plugins.toolkit.get_validator('ignore_empty')

class TibCadviewerPlugin(plugins.SingletonPlugin):

    '''This is a CKAN extension developed for Leibniz Data Manager project of TIB allowing to visualize
    CAD files using the free service provided by https://sharecad.org/.'''

    plugins.implements(plugins.IConfigurer)
    plugins.implements(plugins.IResourceView, inherit=True)

    # IConfigurer

    def update_config(self, config_):
        toolkit.add_template_directory(config_, 'templates')
        toolkit.add_public_directory(config_, 'public')
        toolkit.add_resource('fanstatic', 'tib_cadviewer')

        self.formats = [x.lower() for x in ['DWG', 'DXF', 'DWF', 'HPGL', 'PLT', 'PDF', 'STEP', 'STP', 'IGES', 'IGS', 'X_T', 'X_B',
                        'SLDPRT', 'STL', 'SAT', 'CGM', 'SVG', 'EMF', 'WMF']]


    def info(self):
        return {'name': 'tib_cadviewer',
                'title': plugins.toolkit._('CAD'),
                'icon': 'cubes',
                'schema': {'cad_url': [ignore_empty, str]},
                'iframed': False,
                'always_available': True,
                'default_title': plugins.toolkit._('CAD'),
                }

    def can_view(self, data_dict):
        valid_resource_type = self.get_resource_type_from_url(data_dict['resource'].get('url', ''))
        if not data_dict['resource'].get('format', '') and valid_resource_type:
            data_dict['resource']['format'] = valid_resource_type
        return valid_resource_type

    def view_template(self, context, data_dict):
        return 'cad_view.html'

    def form_template(self, context, data_dict):
        return 'cad_form.html'

    def get_resource_type_from_url(self, url):
        if url == '':
            return False

        for i in range(3, 7):
            ext = url[-i:].lower()
            if ext in self.formats:
                return ext

        return False