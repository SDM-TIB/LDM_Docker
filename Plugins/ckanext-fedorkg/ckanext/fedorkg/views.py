
import os

from DeTrusty import __version__ as detrusty_version
from DeTrusty import run_query
from DeTrusty.Molecule.MTManager import get_config
from ckan.common import request, config
from ckan.plugins import toolkit
from ckanext.fedorkg import __version__ as fedorkg_version
from ckanext.fedorkg.controller import FedORKGController, DEFAULT_QUERY_KEY, DEFAULT_QUERY_NAME_KEY
from flask import Blueprint, jsonify, request

fedorkg = Blueprint('fedorkg', __name__, url_prefix='/fedorkg')
admin_bp = Blueprint('fedorkg_admin', __name__ + '_admin', url_prefix='/ckan-admin')


def init_config():
    storage_path = os.environ.get('CKAN_STORAGE_PATH', '/var/lib/ckan')
    fedorkg_path = os.path.join(storage_path, 'fedorkg')
    os.makedirs(fedorkg_path, exist_ok=True)
    return get_config(os.path.join(fedorkg_path, 'rdfmts.json'))


detrusty_config = init_config()


def query_editor():
    return toolkit.render('sparql.jinja2',
                          extra_vars={
                              'detrusty_version': detrusty_version,
                              'fedorkg_version': fedorkg_version,
                              'default_query': config.get(DEFAULT_QUERY_KEY, ''),
                              'default_query_name': config.get(DEFAULT_QUERY_NAME_KEY, '')
                          })


def sparql():
    query = request.values.get('query', None)
    if query is None:
        return jsonify({"result": [], "error": "No query passed."})
    yasqe = request.values.get('yasqe', False)
    return jsonify(
        run_query(
            query=query,
            config=detrusty_config,
            join_stars_locally=False,
            yasqe=yasqe
        )
    )


fedorkg.add_url_rule('/sparql', view_func=query_editor, methods=['GET'])
fedorkg.add_url_rule('/sparql', view_func=sparql, methods=['POST'])
admin_bp.add_url_rule('/fedorkg', view_func=FedORKGController.admin, methods=['GET', 'POST'])


def get_blueprints():
    return [fedorkg, admin_bp]
