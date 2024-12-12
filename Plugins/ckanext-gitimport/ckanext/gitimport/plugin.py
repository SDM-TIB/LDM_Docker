import ckan.plugins as plugins
import ckan.plugins.toolkit as toolkit
from ckan.plugins import interfaces, SingletonPlugin, implements
from .views import gitimport


class GitimportPlugin(SingletonPlugin):
    plugins.implements(plugins.IConfigurer)
    implements(interfaces.IBlueprint)

    def update_config(self, config_):
        toolkit.add_template_directory(config_, "templates")
        toolkit.add_public_directory(config_, "public")
        toolkit.add_resource("public", "gitimport")

    def get_blueprint(self):
        return [gitimport]
