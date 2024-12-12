from flask import Blueprint, request, session, jsonify
import logging
import ckan.plugins as plugins
import ckan.plugins.toolkit as toolkit
log = logging.getLogger(__name__)
import pandas as pd
from collections import OrderedDict
import requests
from SPARQLWrapper import SPARQLWrapper, JSON
import os
import io
import ckan.model as model
#import cgi
from werkzeug.datastructures import FileStorage
import math
falcon_blueprint = Blueprint('falcon_blueprint', __name__)
global predicate_dict


def construct_ckan_resource_path(resource_id):
    base_storage_path='/var/lib/ckan/resources'
    # Split the resource_id for directory structure
    first_dir = resource_id[:3]
    second_dir = resource_id[3:6]
    filename = resource_id[6:]

    # Construct the full path
    full_path = os.path.join(base_storage_path, first_dir, second_dir, filename)

    # Check if the file exists
    if os.path.isfile(full_path):
        return full_path
    else:
        return None

def falcon_call(text):
    try:
        headers = {'content-type': 'application/json', 'Accept-Charset': 'UTF-8'}
        url = 'https://labs.tib.eu/falcon/falcon2/api?mode=short'
        entities_wiki = []
        #log.debug(text)
        if text is None or text == "":
            return ""
        if type(text)== float:
            return ""
        text=str(text)
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
    except:
        log.debug(text)
        raise

@falcon_blueprint.route('/dataset/<id>/resource/<resource_id>/process_column', methods=['POST'])
def process_column(id, resource_id):
    try:
        # Permission check
        context = {'model': model, 'user': toolkit.c.user or toolkit.c.userobj.name}
        toolkit.check_access('resource_update', context, {'id': resource_id})

        selected_column = request.json.get('selectedColumn')
        original_data = session.get('data')[selected_column]
        processed_data = [falcon_call(value) for value in original_data]

        # Replace NaN values with None (which converts to null in JSON) or another placeholder
        results = [{'input': (orig if orig == orig else None), 'output': proc} for orig, proc in zip(original_data, processed_data)]


        # Store the Falcon output URIs in the session
        session['falcon_outputs'] = [res["output"] for res in results]

        return jsonify(results)
    except toolkit.NotAuthorized:
        return jsonify({'error': 'Not authorized to modify this resource'}), 403
    except Exception as e:
        raise
        return jsonify({'error': str(e)}), 500




# Function or part of your code that prepares the JSON response
def prepare_json_response(data):
    # Recursively check for NaN values in the data and replace them with an empty string
    def replace_nan(value):
        if isinstance(value, float) and math.isnan(value):
            return ""
        elif value is None:
            return ""
        elif isinstance(value, dict):
            return {k: replace_nan(v) for k, v in value.items()}
        elif isinstance(value, list):
            return [replace_nan(v) for v in value]
        return value

    return replace_nan(data)



@falcon_blueprint.route('/dataset/<id>/resource/<resource_id>/get_predicate_data', methods=['GET'])
def get_predicate_data(id, resource_id):
    try:
        # Permission check and other initial setup...

        selected_predicates = request.args.get('predicates').split(',')
        entity_uris = session.get('falcon_outputs', [])
        original_csv_data = session.get('csv_data', [])

        results = []
        for uri, original_row in zip(entity_uris, original_csv_data):
            row_data = original_row.copy()  # Start with the original CSV data for this uri
            
            for key in row_data.keys():
                # Check and replace NaN, None, or null values with an empty string
                if row_data[key] is None or row_data[key] != row_data[key]:  # Checks for None and NaN
                    row_data[key] = ""
            # Skip SPARQL query if uri is null or an empty string and set empty string for values
            if not uri or uri[0] in [None, "", float('nan')]:  # Added check for NaN
                for predicate in selected_predicates:
                    row_data[predicate_dict[predicate]] = ""
                results.append(row_data)
                continue

            for predicate in selected_predicates:
                property_id = predicate.split('/')[-1]
                sparql_query = f"""
                    SELECT ?statementMainValueLabel WHERE {{
                        <{uri[0]}> p:{property_id} ?statement.
                            ?statement ps:{property_id} ?statementMainValue.
                            SERVICE wikibase:label {{ bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en". }}
                    }}
                """

                sparql = SPARQLWrapper("https://query.wikidata.org/sparql")
                sparql.setQuery(sparql_query)
                sparql.setReturnFormat(JSON)
                result = sparql.query().convert()

                values_list = []
                if result['results']['bindings']:
                    for binding in result['results']['bindings']:
                        if 'statementMainValueLabel' in binding:
                            values_list.append(binding['statementMainValueLabel']['value'])

                # Set value based on the length of the values list
                value = ', '.join(values_list) if values_list else ""
                row_data[predicate_dict[predicate]] = value

            # Convert any NaN values in row_data to empty strings
            row_data = {k: ("" if isinstance(v, float) and math.isnan(v) else v) for k, v in row_data.items()}

            results.append(row_data)

        return jsonify(results)
    except toolkit.NotAuthorized:
        return jsonify({'error': 'Not authorized to access this resource'}), 403
    except Exception as e:
        return jsonify({'error': str(e)}), 500



@falcon_blueprint.route('/dataset/<id>/resource/<resource_id>/choose_column')
def choose_column(id, resource_id):
    try:
        # Permission check
        context = {'model': model, 'user': toolkit.c.user or toolkit.c.userobj.name}
        toolkit.check_access('package_show', context, {'id': id})
        # Fetch the dataset and resource using CKAN's action API
        dataset = toolkit.get_action('package_show')(data_dict={'id': id})
        resource = toolkit.get_action('resource_show')(data_dict={'id': resource_id})
        # Retrieve the CSV URL from the resource
        csv_url =  construct_ckan_resource_path(resource_id)
        if csv_url is None:
            toolkit.h.flash_error('Error loading CSV file: '. csv_url)
            return toolkit.redirect_to(controller='dataset', action='read', id=id)
        session['csv_url'] = csv_url
        try:
            # Load the CSV file into a Pandas DataFrame
            df = pd.read_csv(csv_url)
            session['data'] = df.to_dict(orient='list')
            records = df.to_dict(orient='records')
            ordered_records = [OrderedDict(row) for row in records]
            session['csv_data'] = ordered_records
            session['columns'] = df.columns.tolist()
            columns = df.columns.tolist()
        except Exception as e:
            raise
            # Handle exceptions (e.g., file not found, invalid CSV)
            toolkit.h.flash_error('Error loading CSV file: {}'.format(str(e)))
            return toolkit.redirect_to(controller='package', action='read', id=id)

        # Render your custom HTML page with the dataset and resource data
        return toolkit.render('choose_column.html', extra_vars={'dataset': dataset, 'resource': resource, 'columns': columns, 'resource_id': resource_id , 'dataset_id': id})
    except toolkit.NotAuthorized:
        toolkit.h.flash_error('Not authorized to view this dataset')
        return toolkit.redirect_to(controller='package', action='read', id=id)
    except Exception as e:
        toolkit.h.flash_error(f'Error: {str(e)}')
        return toolkit.redirect_to(controller='package', action='read', id=id)
@falcon_blueprint.route('/dataset/<id>/resource/<resource_id>/get_shared_predicates')
def get_shared_predicates(id, resource_id):
    entity_uris = session.get('falcon_outputs', [])

    # Now create a VALUES clause with the entity URIs
    values_clause = " ".join(f"<{uri}>" for uri in entity_uris)
    values_clause=values_clause.replace("[","").replace("]","").replace("'","")


    # Modify the SPARQL query to use the VALUES clause and adjust the WHERE clause
    sparql_query = f"""
        SELECT DISTINCT ?predicate ?predicateLabel WHERE {{
            VALUES ?entity {{ {values_clause} }}
            ?entity ?predicate ?obj .

            # Get the property entity associated with the predicate.
            BIND(STRAFTER(STR(?predicate), "http://www.wikidata.org/prop/") AS ?propertyId)
            BIND(IRI(CONCAT("http://www.wikidata.org/entity/", ?propertyId)) AS ?propertyEntity)

            # Fetch label for the property entity
            SERVICE wikibase:label {{ bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en". ?propertyEntity rdfs:label ?predicateLabel. }}
        }}
        ORDER BY ?predicate
        LIMIT 200
    """
    sparql = SPARQLWrapper("https://query.wikidata.org/sparql")
    sparql.setQuery(sparql_query)
    sparql.setReturnFormat(JSON)
    results = sparql.query().convert()

    shared_predicates = [{
        'uri': result['predicate']['value'],
        'label': result['predicateLabel']['value']
    } for result in results['results']['bindings']]

    global predicate_dict
    predicate_dict = {result['predicate']['value']: result['predicateLabel']['value']
                      for result in results['results']['bindings']}



    return jsonify(shared_predicates)
        

@falcon_blueprint.route('/dataset/<id>/resource/<resource_id>/save_extended_data', methods=['POST'])
def save_extended_data(id, resource_id):
    try:
        # Perform a permission check before proceeding
        context = {'model': model, 'user': toolkit.c.user or toolkit.c.userobj.name, 'auth_user_obj': toolkit.c.userobj}
        toolkit.check_access('resource_create', context, {'package_id': id})

        data = request.json.get('data')
        # Proceed with saving the data as a new resource
        new_resource = create_new_resource(data, resource_id, id)

        if new_resource:
            resource_url = new_resource.get('url')
            return jsonify({"success": True, "resource_url": resource_url})
        else:
            return jsonify({"success": False})
    except toolkit.NotAuthorized:
        return jsonify({'error': 'Not authorized to create a resource in this dataset'}), 403
    except Exception as e:
        return jsonify({'error': str(e)}), 500



def create_new_resource(data, original_resource_id, dataset_id):
    try:
        # Context for the action API call
        user = toolkit.get_action('get_site_user')({'ignore_auth': True}, {})
        context = {'model': model, 'user': user['name']}

        # Get information about the original resource
        original_resource = toolkit.get_action('resource_show')(context, {'id': original_resource_id})
        #log.debug(original_resource)

        # New resource name
        new_resource_name = original_resource["name"] + "_extended"

        # Step 1: Create the new resource without file content
        new_resource = toolkit.get_action('resource_create')(
            context,
            {
                'package_id': dataset_id,
                'name': new_resource_name,
                'format': original_resource["format"],
                'description': original_resource["description"],        
            }
        )

        # Step 2: Update the newly created resource with file content
        return update_resource_file(new_resource['id'], data, new_resource_name,original_resource["mimetype"])

    except toolkit.ValidationError as e:
        raise
        toolkit.h.flash_error(f'Error creating new resource: {e.error_summary}')
        return None
    except Exception as e:
        raise
        toolkit.h.flash_error(f'Error: {str(e)}')
        return None



def update_resource_file(resource_id, data, file_name,mimetype):
    # Get the current logged-in user's name
    user_name = toolkit.c.user or toolkit.c.userobj.name

    context = {
        'ignore_auth': True,
        'user': user_name  # Use the current logged-in user's name
    }

    # Prepare the file-like object using Flask's FileStorage
    file_stream = io.BytesIO(data.encode('utf-8'))
    upload = FileStorage(stream=file_stream, filename=file_name)

    data_dict = {
        'id': resource_id,
        'name': file_name,
        'upload': upload,
        'mimetype': mimetype
    }
    return toolkit.get_action('resource_update')(context, data_dict)
        
class FalconPlugin(plugins.SingletonPlugin):
    plugins.implements(plugins.IConfigurer, inherit=True)
    plugins.implements(plugins.ITemplateHelpers)
    #plugins.implements(plugins.IRoutes, inherit=True)
    plugins.implements(plugins.IBlueprint)
    #plugins.implements(plugins.IResourceView, inherit=True)

    # IConfigurer

    def update_config(self, config_):
        toolkit.add_template_directory(config_, 'templates/')
        toolkit.add_public_directory(config_, 'public')
        toolkit.add_resource('fanstatic','falcon')
            
            
    def get_helpers(self):
        return {'falcon_template_directory': self.get_template_directory}

    def get_template_directory(self):
        # Return the path to your templates directory relative to the `ckanext-falcon` directory
        return '/ckanext/falcon/templates'
  
    def get_blueprint(self):
        # Register the Blueprint defined earlier
        return [falcon_blueprint]
    
 
        

            
        
        
plugins.plugin = FalconPlugin()