
from logging import getLogger

import ckan.plugins as p
import ckan.plugins.toolkit as toolkit
from ckan.lib.helpers import url_for

log = getLogger(__name__)
ignore_empty = p.toolkit.get_validator('ignore_empty')
natural_number_validator = p.toolkit.get_validator('natural_number_validator')
Invalid = p.toolkit.Invalid


def each_datastore_field_to_schema_type(dstore_type):
    # Adopted from https://github.com/frictionlessdata/datapackage-pipelines-ckan-driver/blob/master/tableschema_ckan_datastore/mapper.py
    """
    For a given datastore type, return the corresponding schema type.
    datastore int and float may have a trailing digit, which is stripped.
    datastore arrays begin with an '_'.
    """
    dstore_type = dstore_type.rstrip('0123456789')
    if dstore_type.startswith('_'):
        dstore_type = 'array'
    DATASTORE_TYPE_MAPPING = {
        'int': ('integer', None),
        'float': ('number', None),
        'smallint': ('integer', None),
        'bigint': ('integer', None),
        'integer': ('integer', None),
        'numeric': ('number', None),
        'money': ('number', None),
        'timestamp': ('datetime', 'any'),
        'date': ('date', 'any'),
        'time': ('time', 'any'),
        'interval': ('duration', None),
        'text': ('string', None),
        'varchar': ('string', None),
        'char': ('string', None),
        'uuid': ('string', 'uuid'),
        'boolean': ('boolean', None),
        'bool': ('boolean', None),
        'json': ('object', None),
        'jsonb': ('object', None),
        'array': ('array', None)
    }
    try:
        return DATASTORE_TYPE_MAPPING[dstore_type]
    except KeyError:
        log.warning('Unsupported DataStore type \'{}\'. Using \'string\'.'.format(dstore_type))
        return 'string', None


def datastore_fields_to_schema(resource):
    """
    Return a table schema from a DataStore field types.
    :param resource: resource dict
    :type resource: dict
    """
    data = {'resource_id': resource['id'], 'limit': 0}

    fields = toolkit.get_action('datastore_search')({}, data)['fields']
    ts_fields = []
    for f in fields:
        if f['id'] == '_id':
            continue
        datastore_type = f['type']
        datastore_id = f['id']
        ts_type, ts_format = each_datastore_field_to_schema_type(
            datastore_type)
        ts_field = {
            'name': datastore_id,
            'type': ts_type
        }
        if ts_format is not None:
            ts_field['format'] = ts_format
        ts_fields.append(ts_field)
    return ts_fields


def valid_fields_as_options(schema, valid_field_types=[]):
    """
    Return a list of all datastore schema fields types for a given resource, as long as
    the field type is in valid_field_types.

    :param schema: schema dict
    :type schema: dict
    :param valid_field_types: field types to include in returned list
    :type valid_field_types: list of strings
    """

    return [{'value': f['name'], 'text': f['name']} for f in schema
            if f['type'] in valid_field_types or valid_field_types == []]


def in_list(list_possible_values):
    """
    Validator that checks that the input value is one of the given
    possible values.

    :param list_possible_values: function that returns list of possible values
        for validated field
    :type list_possible_values: function
    """
    def validate(key, data, errors, context):
        if not data[key] in list_possible_values():
            raise Invalid('"{0}" is not a valid parameter'.format(data[key]))
    return validate


def can_view_resource(data_dict):
    resource = data_dict['resource']

    if (resource.get('datastore_active') or
            '_datastore_only_resource' in resource.get('url', '')):
        return True
    resource_format = resource.get('format', None)
    if resource_format:
        return resource_format.lower() in ['csv', 'xls', 'xlsx', 'tsv']
    else:
        return False


def _setup_template_variables(context, data_dict):
    data_dict['resource'].update({
        'title': data_dict['resource']['name'],
        'path': data_dict['resource']['url'],
    })

    if data_dict['resource'].get('datastore_active'):
        schema = datastore_fields_to_schema(data_dict['resource'])
        data_dict['resource'].update({
            'schema': {'fields': schema},
            'api': url_for('api.action', ver=3, logic_function='datastore_search',
                           resource_id=data_dict['resource']['id'], _external=True),
        })

    return {
        'api': url_for('api.action', ver=3, logic_function='resource_search', _external=True),
        'resources': [data_dict['resource']]
    }

class DataComparisonView(p.SingletonPlugin):
    """
        This extension provides views capable of comparing resources.
    """
    p.implements(p.IConfigurable, inherit=True)
    p.implements(p.IConfigurer, inherit=True)
    p.implements(p.IResourceView, inherit=True)
    p.implements(p.ITemplateHelpers, inherit=True)

    # IConfigurable
    def configure(self, config):
        toolkit.add_resource('static', 'datacomparison')

    # IConfigurer
    def update_config(self, config_):
        toolkit.add_template_directory(config_, 'templates')
        toolkit.add_public_directory(config_, 'public')
        toolkit.add_resource('static', 'datacomparison')

    def info(self):
        return {
            'name': 'datacomparison_view',
            'title': 'DataComparison',
            'icon': 'table',
            'requires_datastore': False,
            'default_title': p.toolkit._('Data Comparison'),
        }

    def setup_template_variables(self, context, data_dict):
        return _setup_template_variables(context, data_dict)

    def can_view(self, data_dict):
        return can_view_resource(data_dict)

    def get_helpers(self):
        return {}

    def view_template(self, context, data_dict):
        return 'datacomparison.jinja2'


class DataExplorerView(p.SingletonPlugin):
    """
        This extension provides a simple data explorer for a single resource.
    """
    p.implements(p.IConfigurable, inherit=True)
    p.implements(p.IConfigurer, inherit=True)
    p.implements(p.IResourceView, inherit=True)
    p.implements(p.ITemplateHelpers, inherit=True)

    # IConfigurable
    def configure(self, config):
        toolkit.add_resource('static', 'datacomparison')

    # IConfigurer
    def update_config(self, config_):
        toolkit.add_template_directory(config_, 'templates')
        toolkit.add_public_directory(config_, 'public')
        toolkit.add_resource('static', 'datacomparison')

    def info(self):
        return {
            'name': 'datacomparison_explorer_view',
            'title': 'DataExplorerSDM',
            'icon': 'table',
            'requires_datastore': False,
            'default_title': p.toolkit._('Data Explorer (TIB-SDM)'),
        }

    def setup_template_variables(self, context, data_dict):
        return _setup_template_variables(context, data_dict)

    def can_view(self, data_dict):
        return can_view_resource(data_dict)

    def get_helpers(self):
        return {}

    def view_template(self, context, data_dict):
        return 'dataexplorer.jinja2'
