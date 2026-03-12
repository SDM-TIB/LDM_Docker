import ckan.plugins as plugins
import ckan.plugins.toolkit as toolkit

from flask import Blueprint

import ckanext.TIBdcat.utils as utils

class TIBdcatPlugin(plugins.SingletonPlugin):
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

        # 1. rdf/xml
        # 2. xml
        # 3. n3
        # 4. ttl
        # 5. jsonld
        def download_dataset(_type, _id, _format):
            if file_format == "rdf":
                return utils.download_dataset_rdf(_id)  # Pass the ID!
            elif file_format == "xml":
                return utils.download_dataset_xml(_id)
            elif file_format == "n3":
                return utils.download_dataset_n3(_id)
            elif file_format == "ttl":
                return utils.download_dataset_ttl(_id)
            elif file_format == "jsonld":
                return utils.download_dataset_jsonld(_id)
            else:
                # If the format doesn't match, return a clean 404 page
                toolkit.abort(404, f"Format {file_format} is not supported.")

        # Add plugin url rules to Blueprint object
        rules = [
            (u'/<_type>/<_id>.<_format>', u'download_dataset', download_dataset)
        ]

        for rule in rules:
            blueprint.add_url_rule(*rule)

        return blueprint
