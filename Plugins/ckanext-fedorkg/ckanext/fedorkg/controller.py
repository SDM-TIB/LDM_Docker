import logging
import os

import ckan.lib.base as base
import ckan.logic as logic
import ckan.model as model
import pyoxigraph
from DeTrusty import get_config
from DeTrusty.Decomposer import Decomposer
from DeTrusty.Molecule import SEMSD
from DeTrusty.Molecule.MTCreation import Endpoint, _accessible_endpoints, get_rdfmts_from_endpoint
from ckan.common import request, config, asbool
from ckan.plugins import toolkit
from pyoxigraph import Store, RdfFormat
from rdflib import Graph
from flask import jsonify

from . import FEDORKG_PATH, SEMSD_PATH, QUERY_DELETE_PROPERTY_RANGE, QUERY_DELETE_SOURCE_FROM_PROPERTY, \
    QUERY_DELETE_PROPERTY_NO_SOURCE, QUERY_DELETE_SOURCE_FROM_CLASS, QUERY_DELETE_CLASS_NO_SOURCE, QUERY_DELETE_SOURCE

DEFAULT_QUERY_KEY = 'ckanext.fedorkg.query'
DEFAULT_QUERY_NAME_KEY = 'ckanext.fedorkg.query.name'
QUERY_TIMEOUT = 'ckanext.fedorkg.timeout'

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
logger.addHandler(logging.StreamHandler())


def init_config():
    os.makedirs(FEDORKG_PATH, exist_ok=True)
    return get_config(SEMSD_PATH)


DETRUSTY_CONFIG = init_config()


class FedORKGController:

    @staticmethod
    def admin():
        context = {
            'model': model,
            'session': model.Session,
            'user': toolkit.c.user,
            'auth_user_obj': toolkit.c.userobj
        }
        try:
            logic.check_access('sysadmin', context, {})
        except logic.NotAuthorized:
            base.abort(403, toolkit._('Need to be system administrator to administer.'))

        msg = ''
        error = False
        if request.method == 'POST':
            action = request.form.get('action', None)
            if action is None:
                error = asbool(request.form.get('error'))
                msg = request.form.get('msg')
            elif action == 'default_query':
                query = request.form.get(DEFAULT_QUERY_KEY, '').strip().replace('\r\n', '\n')
                query_name = request.form.get(DEFAULT_QUERY_NAME_KEY, '').strip()
                if query != '' and query_name != '':
                    decomposed_query = None
                    try:
                        decomposed_query = Decomposer(query, DETRUSTY_CONFIG).decompose()
                    except:
                        error = True
                        msg = toolkit._('The query is malformed. Please, check your syntax.')

                    if not error:
                        if decomposed_query is None:
                            error = True
                            msg = toolkit._('The query cannot be answer by the federation of FedORKG.')
                        else:
                            logic.get_action(u'config_option_update')({
                                u'user': toolkit.c.user
                            }, {
                                DEFAULT_QUERY_KEY: query.replace('\n', '\\n'),
                                DEFAULT_QUERY_NAME_KEY: query_name
                            })
                else:
                    error = True
                    msg = toolkit._('The default query and its name are required.')
            elif action == 'query_timeout':
                timeout = request.form.get(QUERY_TIMEOUT, '')
                try:
                    timeout = int(timeout)
                except ValueError:
                    error = True
                    msg = toolkit._('The query timeout is specified in full seconds. Please, provide input that can be parsed as an integer.')

                if not error:
                    logic.get_action(u'config_option_update')({
                        u'user': toolkit.c.user
                    }, {
                        QUERY_TIMEOUT: timeout
                    })
            else:
                kg = request.form.get('kg')
                if action == '0':
                    try:
                        DETRUSTY_CONFIG.ttl.update(QUERY_DELETE_PROPERTY_RANGE.format(url=kg))
                        DETRUSTY_CONFIG.ttl.update(QUERY_DELETE_SOURCE_FROM_PROPERTY.format(url=kg))
                        DETRUSTY_CONFIG.ttl.update(QUERY_DELETE_PROPERTY_NO_SOURCE)
                        DETRUSTY_CONFIG.ttl.update(QUERY_DELETE_SOURCE_FROM_CLASS.format(url=kg))
                        DETRUSTY_CONFIG.ttl.update(QUERY_DELETE_CLASS_NO_SOURCE)
                        DETRUSTY_CONFIG.ttl.update(QUERY_DELETE_SOURCE.format(url=kg))
                        DETRUSTY_CONFIG.ttl.optimize()
                        ttl_new = pyoxigraph.serialize(DETRUSTY_CONFIG.ttl, format=RdfFormat.TURTLE)
                        sem_source_desc = Graph()
                        sem_source_desc.bind('semsd', SEMSD)
                        sem_source_desc.parse(ttl_new)
                        sem_source_desc.serialize(SEMSD_PATH, format='turtle')
                    except Exception as e:
                        error = True
                        logger.exception(e)
                    if error:
                        msg = toolkit._('There was an error when deleting {kg} from the federation! If you are an admin, check the logs for more details on what happened.').format(kg=kg)
                    else:
                        msg = toolkit._('Successfully removed {kg} from the federation!').format(kg=kg)
                elif action == '1':
                    endpoint = Endpoint(kg)
                    accessible = endpoint in _accessible_endpoints([endpoint])
                    if accessible:
                        try:
                            source_desc = get_rdfmts_from_endpoint(endpoint)
                            sem_source_desc = Graph()
                            sem_source_desc.bind('semsd', SEMSD)
                            sem_source_desc.parse(SEMSD_PATH, format='turtle')
                            [sem_source_desc.add(triple) for triple in endpoint.triples]
                            [sem_source_desc.add(triple) for triple in source_desc]
                            sem_source_desc.serialize(SEMSD_PATH, format='turtle')
                            DETRUSTY_CONFIG.ttl = Store()
                            with open(SEMSD_PATH, 'r', encoding='utf8') as semsd:
                                ttl = semsd.read()
                            DETRUSTY_CONFIG.ttl.load(ttl, RdfFormat.TURTLE)
                            DETRUSTY_CONFIG.ttl.optimize()
                            DETRUSTY_CONFIG.endpoints = DETRUSTY_CONFIG.getEndpoints()
                        except Exception as e:
                            error = True
                            logger.exception(e)
                    else:
                        error = True

                    if error:
                        if not accessible:
                            msg = toolkit._('{kg} is not accessible and, hence, cannot be added to the federation.').format(kg=kg)
                        else:
                            msg = toolkit._('There was an error when adding {kg} to the federation! If you are an admin, check the logs for more details on what happened.').format(kg=kg)
                    else:
                        msg = toolkit._('Successfully added {kg} to the federation!').format(kg=kg)
                return jsonify({
                    'error': error,
                    'msg': msg
                })

        return toolkit.render('admin_fedorkg.jinja2',
                              extra_vars={
                                  'query': config.get(DEFAULT_QUERY_KEY).strip().replace('\\n', '\n'),
                                  'query_name': config.get(DEFAULT_QUERY_NAME_KEY).strip().replace('\\n', '\n'),
                                  'timeout': config.get(QUERY_TIMEOUT),
                                  'kgs': sorted(list(DETRUSTY_CONFIG.getEndpoints().keys())),
                                  'msg': msg,
                                  'error': error
                              })
