import ckan.plugins as plugins
import ckan.plugins.toolkit as toolkit

from flask import Blueprint

class GraphViewerPlugin(plugins.SingletonPlugin):
    plugins.implements(plugins.IConfigurer)
    plugins.implements(plugins.IBlueprint)

    # IConfigurer

    def update_config(self, config_):
        toolkit.add_template_directory(config_, 'templates')
        toolkit.add_public_directory(config_, 'public')

    # IBlueprint

    def get_blueprint(self):
        u'''Return a Flask Blueprint object to be registered by the app.'''

        # Create Blueprint for plugin
        blueprint = Blueprint(self.name, self.__module__,)
        blueprint.template_folder = u'templates'

        #
        def show_graph_viewer(_type, _id):
            try:
                pkg_dict = toolkit.get_action('package_show')({}, {'id': _id})
            except toolkit.ObjectNotFound:
                toolkit.abort(404, 'Dataset not found')

            # Render the template and pass the dataset metadata
            return toolkit.render(
                'package/graph_export.html',
                extra_vars={'pkg_dict': pkg_dict, 'pkg_type': _type}
            )

        # Add plugin url rules to Blueprint object
        rules = [
            (u'/<_type>/<_id>/graph', u'show_graph', show_graph_viewer),
        ]
        for rule in rules:
            blueprint.add_url_rule(*rule)

        return blueprint
