import ckan.plugins as plugins
import ckan.plugins.toolkit as toolkit
from ckan.common import config
import ckan.lib.helpers as h
from flask import Blueprint
from six import text_type

# HELPERS
# *******
legal_config = {'en':
                    {'terms_of_use_link': 'https://www.tib.eu/en/service/terms-of-use/'},
                'de':
                    {'terms_of_use_link': 'https://www.tib.eu/de/service/benutzungsordnung'}
                }

def get_legal_notice_link(lang='en', term=''):
    if lang!='de':
        lang = 'en'
    return legal_config[lang][term]

def show_cookies_alert():
    value = config.get('tibtheme.show_cookies_alert', True)
    return toolkit.asbool(value)

def styled_header_enabled():
    value = config.get('tibtheme.styled_header_enabled', False)
    return toolkit.asbool(value)

def styled_footer_enabled():
    value = config.get('tibtheme.styled_footer_enabled', False)
    return toolkit.asbool(value)

def get_site_logo_filename():
    return config.get('ckan.site_logo', h.url_for('home')+'/images/TIB_logo.png')

def legal_notices_enabled():
    value = config.get('tibtheme.legal_notices_enabled', False)
    return toolkit.asbool(value)

def legal_notices_TIB_terms_use_enabled():
    value = config.get('tibtheme.legal_notices_TIB_terms_use_enabled', False)
    return toolkit.asbool(value)

def special_conditions_LDM_enabled():
    value = config.get('tibtheme.special_conditions_LDM_enabled', False)
    return toolkit.asbool(value)

def special_conditions_label():
    return config.get('tibtheme.special_conditions_label', 'Special Conditions TIB LDM')

def data_privacy_enabled():
    value = config.get('tibtheme.data_privacy_enabled', False)
    return toolkit.asbool(value)

def imprint_enabled():
    value = config.get('tibtheme.imprint_enabled', False)
    return toolkit.asbool(value)

def accessibility_statement_enabled():
    value = config.get('tibtheme.accessibility_statement_enabled', False)
    return toolkit.asbool(value)

def is_matomo_plugin_enabled():
    m_enabled = toolkit.asbool(config.get('tib_matomo.enabled', False))
    m_installed = 'tib_matomo' in config.get('ckan.plugins', "")
    return m_installed and m_enabled


# *********************

# DEMO PAGE
# ****************************
def demo():

    return toolkit.render(
        'home/demo.html',
        extra_vars={
        }
    )
# ****************************

# LEGAL PAGES
# ****************************
def imprint_page():

    return toolkit.render(
        'home/imprint.html',
        extra_vars={
        }
    )

def accessibility_statement():

    return toolkit.render(
        'home/accessibility_statement.html',
        extra_vars={
        }
    )

def special_conditions_LDM():

    return toolkit.render(
        'home/special_conditions_LDM.html',
        extra_vars={
        }
    )

def data_privacy():

    return toolkit.render(
        'home/data_privacy.html',
        extra_vars={
        }
    )

# **********************************





class TibthemePlugin(plugins.SingletonPlugin):
    plugins.implements(plugins.IConfigurer)
    plugins.implements(plugins.ITemplateHelpers)
    plugins.implements(plugins.IBlueprint)

    # IConfigurer

    def update_config(self, config_):
        toolkit.add_template_directory(config_, 'templates')
        toolkit.add_public_directory(config_, 'public')
        toolkit.add_resource('fanstatic', 'TIBtheme')
        toolkit.add_resource('public/assets', 'ckanext-TIBtheme')

    def update_config_schema(self, schema):
        ignore_missing = toolkit.get_validator('ignore_missing')
        boolean_validator = toolkit.get_validator('boolean_validator')

        schema.update({
            # This is a custom configuration option
            'tibtheme.legal_notices_enabled': [ignore_missing, boolean_validator],
            'tibtheme.show_cookies_alert':  [ignore_missing, boolean_validator],
            'tibtheme.legal_notices_TIB_terms_use_enabled': [ignore_missing, boolean_validator],
            'tibtheme.special_conditions_LDM_enabled': [ignore_missing, boolean_validator],
            'tibtheme.special_conditions_label': [ignore_missing, text_type],
            'tibtheme.data_privacy_enabled': [ignore_missing, boolean_validator],
            'tibtheme.imprint_enabled': [ignore_missing, boolean_validator],
            'tibtheme.accessibility_statement_enabled':[ignore_missing, boolean_validator],
        })

        return schema

    def get_helpers(self):
        '''Register the show_object_icon_in_package_item() function above as a template
        helper function.

        '''
        # Template helper function names should begin with the name of the
        # extension they belong to, to avoid clashing with functions from
        # other extensions.
        return {'tibtheme_show_object_icon_in_package_item': show_object_icon_in_package_item,
                'tibtheme_is_dataset_menu_item_selected': is_dataset_menu_item_selected,
                'tibtheme_get_dataset_type_title': get_dataset_type_title,
                'tibtheme_get_legal_notice_link': get_legal_notice_link,
                'tibtheme_show_cookies_alert': show_cookies_alert,
                'tibtheme_is_matomo_enabled': is_matomo_plugin_enabled,
                'tibtheme_styled_header_enabled': styled_header_enabled,
                'tibtheme_styled_footer_enabled': styled_footer_enabled,
                'tibtheme_get_site_logo_filename': get_site_logo_filename,
                'tibtheme_legal_notices_enabled': legal_notices_enabled,
                'tibtheme_legal_notices_TIB_terms_use_enabled': legal_notices_TIB_terms_use_enabled,
                'tibtheme_special_conditions_LDM_enabled': special_conditions_LDM_enabled,
                'tibtheme_special_conditions_label': special_conditions_label,
                'tibtheme_data_privacy_enabled': data_privacy_enabled,
                'tibtheme_imprint_enabled': imprint_enabled,
                'tibtheme_accessibility_statement_enabled': accessibility_statement_enabled,
                }
     # IBlueprint
    def get_blueprint(self):
        u'''Return a Flask Blueprint object to be registered by the app.'''

        # Create Blueprint for plugin
        blueprint = Blueprint(self.name, self.__module__)
        blueprint.template_folder = u'templates'
        # Add plugin url rules to Blueprint object
        rules = [
            (u'/imprint', 'imprint', imprint_page),
            (u'/accessibility_statement', 'accessibility_statement', accessibility_statement),
            (u'/special_conditions_LDM', 'special_conditions_LDM', special_conditions_LDM),
            (u'/data_privacy', 'data_privacy', data_privacy),
            (u'/demo', 'demo_page', demo),

        ]
        for rule in rules:
            blueprint.add_url_rule(*rule)

        return blueprint

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

def is_dataset_menu_item_selected():

    current_url = h.current_url()
    return '/dataset/' in current_url or '/vdataset/' in current_url or '/service/' in current_url

def get_dataset_type_title(dataset_type):
    aux_list = {'dataset': 'Dataset',
                'vdataset': 'Imported Dataset',
                'service': 'Service'}
    return aux_list[dataset_type]