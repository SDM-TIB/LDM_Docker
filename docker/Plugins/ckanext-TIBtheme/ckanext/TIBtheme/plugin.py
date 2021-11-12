import ckan.plugins as plugins
import ckan.plugins.toolkit as toolkit
from ckan.common import config
import ckan.lib.helpers as h

class TibthemePlugin(plugins.SingletonPlugin):
    plugins.implements(plugins.IConfigurer)
    plugins.implements(plugins.ITemplateHelpers)

    # IConfigurer

    def update_config(self, config_):
        toolkit.add_template_directory(config_, 'templates')
        toolkit.add_public_directory(config_, 'public')
        toolkit.add_resource('fanstatic', 'TIBtheme')

    def get_helpers(self):
        '''Register the show_object_icon_in_package_item() function above as a template
        helper function.

        '''
        # Template helper function names should begin with the name of the
        # extension they belong to, to avoid clashing with functions from
        # other extensions.
        return {'tibtheme_show_object_icon_in_package_item': show_object_icon_in_package_item,
                'tibtheme_is_dataset_menu_item_selected': is_dataset_menu_itme_selected,
                'tibtheme_get_dataset_type_title': get_dataset_type_title
                }

def show_object_icon_in_package_item():
    '''Return the value of the show_object_icon_in_package_item.
        To enable showing the icon in package lists, add this line to the
        [app:main] section of your CKAN config file::

          ckan.show_vdatasets_virtual_ribbon = True
     Returns ``False`` by default, if the setting is not in the config file.
    :rtype: bool
    '''
    value = config.get('tibtheme.show_object_icon_in_package_item', True)
    value = toolkit.asbool(value)
    return value

def is_dataset_menu_itme_selected():

    current_url = h.current_url()
    return '/dataset/' in current_url or '/vdataset/' in current_url or '/service/' in current_url

def get_dataset_type_title(dataset_type):
    aux_list = {'dataset': 'Dataset',
                'vdataset': 'Imported Dataset',
                'service': 'Service'}
    return aux_list[dataset_type]