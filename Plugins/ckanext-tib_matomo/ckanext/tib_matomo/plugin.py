import ckan.plugins as plugins
import ckan.plugins.toolkit as toolkit
from ckan.common import config
from flask import Blueprint

# ********* HELPERS ************

def is_tib_matomo_enabled():
    value = config.get('tib_matomo.enabled', False)
    return toolkit.asbool(value)

def get_tib_matomo_url():
    return config.get('tib_matomo.url', "")

def get_tib_matomo_id():
    return config.get('tib_matomo.id', "")

#  *************************

# WEBPAGES
# ****************************
def matomo_dashboard_LDM():

    return toolkit.render(
        'matomo_dashboard.html',
        extra_vars={
        }
    )

class TibMatomoPlugin(plugins.SingletonPlugin):
    plugins.implements(plugins.IConfigurer)
    plugins.implements(plugins.ITemplateHelpers)
    plugins.implements(plugins.IBlueprint)

    # IConfigurer

    def update_config(self, config_):
        toolkit.add_template_directory(config_, 'templates')
        toolkit.add_public_directory(config_, 'public')
        toolkit.add_resource('fanstatic', 'tib_matomo')
        toolkit.add_resource('assets', 'ckanext-tib_matomo')

    def get_helpers(self):
        '''Register the show_object_icon_in_package_item() function above as a template
        helper function.

        '''
        # Template helper function names should begin with the name of the
        # extension they belong to, to avoid clashing with functions from
        # other extensions.
        return {'tib_matomo_enabled': is_tib_matomo_enabled,
                'tib_matomo_get_url': get_tib_matomo_url,
                'tib_matomo_get_id': get_tib_matomo_id,
                }

     # IBlueprint
    def get_blueprint(self):
        u'''Return a Flask Blueprint object to be registered by the app.'''

        # Create Blueprint for plugin
        blueprint = Blueprint(self.name, self.__module__)
        blueprint.template_folder = u'templates'
        # Add plugin url rules to Blueprint object
        rules = [
            (u'/matomo', 'matomo_dashboard_LDM', matomo_dashboard_LDM),

        ]
        for rule in rules:
            blueprint.add_url_rule(*rule)

        return blueprint