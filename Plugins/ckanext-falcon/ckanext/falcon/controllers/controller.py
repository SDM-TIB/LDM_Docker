from flask import Blueprint,  make_response, jsonify , render_template
from ckan.plugins import toolkit
from SPARQLWrapper import SPARQLWrapper, JSON
import requests
import json
import pandas as pd
from ckan.plugins import toolkit



falcon_blueprint = Blueprint('falcon', __name__)

@falcon_blueprint.route('/falcon/get_predicate_data')
def get_predicate_data():
    selected_predicates = toolkit.request.args.get('predicates').split(',')
    entity_uris = toolkit.session.get('falcon_outputs', [])
    original_csv_data = toolkit.session.get('csv_data', [])
    predicate_dict = toolkit.session.get('predicate_dict', {})

    results = []
    for uri, original_row in zip(entity_uris, original_csv_data):
        row_data = original_row.copy()

        for predicate in selected_predicates:
            property_id = predicate.split('/')[-1]
            sparql_query = """
                SELECT ?statementMainValueLabel WHERE {{
                    <{}> p:{} ?statement.
                    ?statement ps:{} ?statementMainValue.
                    SERVICE wikibase:label {{ bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en". }}
                }}
            """.format(uri, property_id, property_id)

            sparql = SPARQLWrapper("https://query.wikidata.org/sparql")
            sparql.setQuery(sparql_query)
            sparql.setReturnFormat(JSON)
            result = sparql.query().convert()

            values_list = []
            if result['results']['bindings']:
                for binding in result['results']['bindings']:
                    if 'statementMainValueLabel' in binding:
                        values_list.append(binding['statementMainValueLabel']['value'])

            if len(values_list) == 1:
                value = values_list[0]
            elif len(values_list) > 1:
                value = ', '.join(values_list)
            else:
                value = None

            row_data[predicate_dict.get(predicate)] = value

        results.append(row_data)

    make_response.headers['Content-Type'] = 'application/json'
    return json.dumps(results)

@falcon_blueprint.route('/falcon/get_shared_predicates')
def get_shared_predicates():
    entity_uris = toolkit.session.get('falcon_outputs', [])
    values_clause = " ".join(f"<{uri}>" for uri in entity_uris)

    sparql_query = """
        SELECT DISTINCT ?predicate ?predicateLabel WHERE {{
            VALUES ?entity {{ {} }}
            ?entity ?predicate ?obj .

            BIND(STRAFTER(STR(?predicate), "http://www.wikidata.org/prop/") AS ?propertyId)
            BIND(IRI(CONCAT("http://www.wikidata.org/entity/", ?propertyId)) AS ?propertyEntity)

            SERVICE wikibase:label {{ bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en". ?propertyEntity rdfs:label ?predicateLabel. }}
        }}
        ORDER BY ?predicate
        LIMIT 200
    """.format(values_clause)

    sparql = SPARQLWrapper("https://query.wikidata.org/sparql")
    sparql.setQuery(sparql_query)
    sparql.setReturnFormat(JSON)
    results = sparql.query().convert()

    shared_predicates = [{
        'uri': result['predicate']['value'],
        'label': result['predicateLabel']['value']
    } for result in results['results']['bindings']]

    predicate_dict = {result['predicate']['value']: result['predicateLabel']['value']
                      for result in results['results']['bindings']}
    toolkit.session['predicate_dict'] = predicate_dict

    make_response.headers['Content-Type'] = 'application/json'
    return json.dumps(shared_predicates)

@falcon_blueprint.route('/falcon/process_data')
def process_data():
    column = toolkit.request.args.get('column')
    original_data = toolkit.session.get('data')[column][:20]

    processed_data = [falcon_call(value) for value in original_data]
    results = [{'input': orig, 'output': proc} for orig, proc in zip(original_data, processed_data)]

    toolkit.session['falcon_outputs'] = [res["output"] for res in results]

    make_response.headers['Content-Type'] = 'application/json'
    return json.dumps(results)

# Define your falcon_call function
# ...
def falcon_call(text):
    headers = {'content-type': 'application/json', 'Accept-Charset': 'UTF-8'}
    url = 'https://labs.tib.eu/falcon/falcon2/api?mode=short'
    entities_wiki = []
    payload = '{"text":"' + text + '"}'
    r = requests.post(url, data=payload.encode('utf-8'), headers=headers)
    if r.status_code == 200:
        response = r.json()
        for result in response['entities_wikidata']:
            entities_wiki.append(result["URI"])
    else:
        r = requests.post(url, data=payload.encode('utf-8'), headers=headers)
        if r.status_code == 200:
            response = r.json()
            for result in response['entities_wikidata']:
                entities_wiki.append(result["URI"])

    return entities_wiki

# Define your save_to_ckan function
# ...
def save_to_ckan(data, resource_id):
    # Connect to the CKAN instance
    ckan = ckanapi.RemoteCKAN(toolkit.config.get("ckan.site_url"), apikey=API_KEY)
    resource_info = ckan.action.resource_show(id=resource_id)
    response = ckan.action.resource_update(
        id=resource_id,
        upload=io.StringIO(data),
        name=resource_info["name"],
        format=resource_info["format"]
    )
    return response

# Helper functions for CKAN integration

# controller.py
@falcon_blueprint.route('/dataset/<id>/resource/<resource_id>/choose_column')
def choose_column(id, resource_id):
    try:
        pkg_dict = toolkit.get_action('package_show')({'ignore_auth': True}, {'id': id})
        columns = pkg_dict.get('resources', [{}])[0].get('columns', [])
    except toolkit.ObjectNotFound:
        toolkit.abort(404, toolkit._('Dataset not found'))
    except toolkit.NotAuthorized:
        toolkit.abort(401, toolkit._('Unauthorized to read dataset'))

    return toolkit.render('choose_column.html', extra_vars={
        'pkg_dict': pkg_dict,
        'resource_id': resource_id,
        'columns': columns
    })


# Register blueprint in your plugin.py
def get_blueprint():
    return [falcon_blueprint]
