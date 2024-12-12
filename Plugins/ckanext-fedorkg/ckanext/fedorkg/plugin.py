
from logging import getLogger

import ckan.plugins as p
import ckan.plugins.toolkit as toolkit
import ckanext.fedorkg.helpers as helpers
import ckanext.fedorkg.views as views
from ckan.lib.plugins import DefaultTranslation
from ckanext.fedorkg.controller import DEFAULT_QUERY_KEY, DEFAULT_QUERY_NAME_KEY, QUERY_TIMEOUT

log = getLogger(__name__)


class FedORKG(p.SingletonPlugin, DefaultTranslation):
    p.implements(p.IConfigurer, inherit=True)
    p.implements(p.IBlueprint, inherit=True)
    p.implements(p.ITemplateHelpers)
    p.implements(p.ITranslation)
    if toolkit.check_ckan_version(min_version='2.10'):
        p.implements(p.IConfigDeclaration)

    def update_config(self, config_):
        toolkit.add_template_directory(config_, 'templates')
        toolkit.add_public_directory(config_, 'public')
        toolkit.add_resource('static', 'fedorkg')
        if toolkit.check_ckan_version(min_version='2.10'):
            icon = 'magnifying-glass'
        else:
            icon = 'search'
        toolkit.add_ckan_admin_tab(config_, 'fedorkg_admin.admin', 'FedORKG', icon=icon)
        if config_.get(DEFAULT_QUERY_NAME_KEY, None) is None:
            config_[DEFAULT_QUERY_NAME_KEY] = 'Covered Concepts'
        if config_.get(DEFAULT_QUERY_KEY, None) is None:
            config_[DEFAULT_QUERY_KEY] = 'SELECT DISTINCT ?c WHERE { ?s a ?c }'
        if config_.get(QUERY_TIMEOUT, None) is None:
            config_[QUERY_TIMEOUT] = 60

    def get_blueprint(self):
        return views.get_blueprints()

    def get_helpers(self):
        return {
            'fedorkg_is_fedorkg_page': helpers.is_fedorkg_page
        }

    def update_config_schema(self, schema):
        ignore_missing = toolkit.get_validator('ignore_missing')

        schema.update({
            DEFAULT_QUERY_KEY: [ignore_missing],
            DEFAULT_QUERY_NAME_KEY: [ignore_missing],
            QUERY_TIMEOUT: [ignore_missing]
        })

        return schema

    def declare_config_options(self, declaration, key):
        declaration.annotate('FedORKG Config Section')
        declaration.declare(DEFAULT_QUERY_KEY, 'SELECT DISTINCT ?c WHERE { ?s a ?c }').set_description('Default query')
        declaration.declare(DEFAULT_QUERY_NAME_KEY, 'Covered Concepts').set_description('Name of the default query')
        declaration.declare(QUERY_TIMEOUT, 60).set_description('Query timeout in seconds')
