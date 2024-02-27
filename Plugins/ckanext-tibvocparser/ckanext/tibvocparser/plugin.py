import ckan.plugins as plugins
import ckan.plugins.toolkit as toolkit

from flask import Blueprint
from flask import render_template_string
from flask import make_response
from flask import Response
from ckanext.tibvocparser.tibparser import TIBVoc_parser
from ckanext.tibvocparser.tests.data_mocks import expected_csl_json_for_check_citation
CONTENT_TYPES = {
    'rdf': 'application/rdf+xml',
    'xml': 'application/rdf+xml',
    'n3': 'text/n3',
    'ttl': 'text/turtle',
    'jsonld': 'application/ld+json',
}


def show_dataset_in_Datacite_format(_type, _id):

    parser = TIBVoc_parser(_id)
    res = parser.get_datacite_dataset()

    r = Response(response=res, status=200, mimetype="application/xml")
    r.headers["Content-Type"] = "text/xml; charset=utf-8"
    return r

def show_dataset_in_CSL_format(_type, _id):

    parser = TIBVoc_parser(_id)
    res = parser.get_csl_dataset()

    r = Response(response=res, status=200, mimetype="application/json")
    r.headers["Content-Type"] = "application/json; charset=utf-8"
    return r

def show_dataset_in_Dublincore_format(_type, _id):

    parser = TIBVoc_parser(_id)
    res = parser.get_dublincore_dataset()

    r = Response(response=res, status=200, mimetype="application/xml")
    r.headers["Content-Type"] = "text/xml; charset=utf-8"
    return r

def show_dataset_in_Bibtex_format(_type, _id):

    parser = TIBVoc_parser(_id)
    res = parser.get_bibtex_dataset()

    return toolkit.render(
        'package/bibtex.html',
        extra_vars={
            u'pkg_dict': parser.ds_dict,
            u'res': res
        }
    )


class TibvocparserPlugin(plugins.SingletonPlugin):
    plugins.implements(plugins.IConfigurer)
    plugins.implements(plugins.IBlueprint)

    # IConfigurer

    def update_config(self, config_):
        toolkit.add_template_directory(config_, 'templates')
        toolkit.add_public_directory(config_, 'public')
        toolkit.add_resource('fanstatic',
            'tibvocparser')

    # IBlueprint

    def get_blueprint(self):
        u'''Return a Flask Blueprint object to be registered by the app.'''

        # Create Blueprint for plugin
        blueprint = Blueprint(self.name, self.__module__)
        blueprint.template_folder = u'templates'
        # Add plugin url rules to Blueprint object
        rules = [
            (u'/<_type>/datacite/<_id>.xml', u'show_datacite', show_dataset_in_Datacite_format),
            (u'/<_type>/csl/<_id>.json', u'show_csl', show_dataset_in_CSL_format),
            (u'/<_type>/dublincore/<_id>.xml', u'show_dublincore', show_dataset_in_Dublincore_format),
            (u'/<_type>/bibtex/<_id>', u'show_bibtex', show_dataset_in_Bibtex_format)

        ]
        for rule in rules:
            blueprint.add_url_rule(*rule)

        return blueprint
