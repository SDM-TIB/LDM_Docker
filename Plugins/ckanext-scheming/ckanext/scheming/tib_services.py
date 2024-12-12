import logging

from ckan.plugins import toolkit
import ckan.model as model
import ckan.logic as logic
import ckan.model as model
from ckantoolkit import h

log = logging.getLogger(__name__)

NotFound = logic.NotFound
NotAuthorized = logic.NotAuthorized

from ckanext.scheming.model.crud import Dataset_ServiceQuery as DSQuery

dataset_types = ['dataset', 'vdataset']

def get_local_datasets_for_services_data(user, service_id, ds_list=''):
    # http://docs.ckan.org/en/2.9/api/index.html#ckan.logic.action.get.package_search

    if ds_list:
        ds_list = ' +id:(' + ds_list + ')'

    params = {'fq': '!type:service' +  ds_list,
              'sort': 'organization asc,title_string asc',
              'rows': 1000,
              'use_default_schema': False}
    context = {'model': model,
               'session': model.Session,
               'user': user}

    try:
        result = toolkit.get_action('package_search')(context, params)
    except NotFound as e:
        return {}
    return result


def get_local_datasets_for_services(user, service_id, ds_list=''):

    result = get_local_datasets_for_services_data(user, service_id, ds_list)
    organizations = {}
    sources = {'Local': {'name': 'Local',
                         'id': 'local'},
               'Leibniz University Hannover': {'name': 'Leibniz University Hannover',
                                               'id': 'LUH'},
               'RADAR (Research Data Repository)': {'name': 'RADAR',
                         'id': 'RDR'},
               'PANGEA (Data Publisher for Earth & Environmental Science)': {'name': 'PANGEA',
                         'id': 'PNG'}
               }
    selected_ds = DSQuery.read_datasets_for_service(service_id)

    datasets = {}

    # Setting to True shows a box with the current
    # selected values on the front-end interface
    show_testing_box = False;

    if 'results' in result:
        for dataset in result["results"]:
            log.error(dataset["name"])

            # Avoid error on datasets without org
            if dataset['organization'] is None:
                continue

            org_name = dataset['organization']['name']
            if org_name not in organizations:
                org_name_styled = org_name.replace("-", " ").title()
                organizations.update({org_name: {'title': org_name_styled,
                                                 'name': org_name }})
            ds_source = 'Local' if "repository_name" not in dataset or not dataset['repository_name'] else dataset['repository_name']
            ds_source = sources[ds_source]['id']
            datasets.update({ dataset['name']: {'id': dataset['id'],
                                                'name': dataset['name'],
                                                'title': short_label(dataset['title'],70),
                                                'source': ds_source,
                                                'organization': short_label(org_name_styled, 25),
                                                'organization_name': org_name,
                                                'local_url': h.url_for('dataset.read', id=dataset['name'])}})
    data = { 'organizations': organizations,
             'sources': sources,
             'selected_ds': selected_ds,
             'datasets': datasets,
             'show_testing_box': show_testing_box}
    return data

def short_label(label, max):
    if len(label) > max:
        return label[0:max] + ".."
    else:
        return label



def get_local_services_for_datasets_data(user, dataset_id, serv_list=''):
    # http://docs.ckan.org/en/2.9/api/index.html#ckan.logic.action.get.package_search

    if serv_list:
        serv_list = ' +id:(' + serv_list + ')'

    params = {'fq': 'type:service' + serv_list,
              'sort': 'organization asc,title_string asc',
              'rows': 1000,
              'use_default_schema': False}
    context = {'model': model,
               'session': model.Session,
               'user': user}

    try:
        result = toolkit.get_action('package_search')(context, params)
    except NotFound as e:
        return {}

    return result

def get_local_services_for_datasets(user, dataset_id, serv_list=''):

    result = get_local_services_for_datasets_data(user, dataset_id, serv_list)
    organizations = {}
    sources = {'Local': {'name': 'Local',
                         'id': 'local'}
               }

    selected_ds = DSQuery.read_services_for_dataset(dataset_id)

    datasets = {}

    # Setting to True shows a box with the current
    # selected values on the front-end interface
    show_testing_box = False;

    if 'results' in result:
        for dataset in result["results"]:
            org_name = dataset['organization']['name']
            if org_name not in organizations:
                org_name_styled = org_name.replace("-", " ").title()
                organizations.update({org_name: {'title': org_name_styled,
                                                 'name': org_name }})
            ds_source = 'Local'
            ds_source = sources[ds_source]['id']
            datasets.update({ dataset['name']: {'id': dataset['id'],
                                                'name': dataset['name'],
                                                'title': short_label(dataset['title'],70),
                                                'source': ds_source,
                                                'organization': short_label(org_name_styled, 25),
                                                'organization_name': org_name,
                                                'local_url': h.url_for('dataset.read', id=dataset['name']).replace('/dataset/', '/service/')}})
    data = { 'organizations': organizations,
             'sources': sources,
             'selected_ds': selected_ds,
             'datasets': datasets,
             'show_testing_box': show_testing_box}
    return data

def update_service_dataset_relationship(pkg_dict):

    package_id = pkg_dict.get('id')
    pkg_type = pkg_dict['type']

    if pkg_type in dataset_types:
        # Delete previous values
        DSQuery.delete_dataset(package_id)
        # Insert services
        insert_services_to_dataset(package_id, pkg_dict.get('services_used_list', ""))
    elif pkg_type == 'service':
        # Delete previous values
        DSQuery.delete_service(package_id)
        # insert datasets
        insert_datasets_to_service(package_id, pkg_dict.get('datasets_served_list', ""))

def insert_services_to_dataset(dataset_id, services_list):
    ser_list = services_list.split(',')
    for s in ser_list:
        if s:
            DSQuery.create(dataset_id, s)


def insert_datasets_to_service(service_id, ds_list):
    ds_list = ds_list.split(',')
    for ds in ds_list:
        if ds:
            DSQuery.create(ds, service_id)

def add_service_data_to_dataset_show(pkg_dict):

    pkg_type = pkg_dict['type']

    if pkg_type in dataset_types:
        pkg_dict = add_services_data_to_dataset(pkg_dict)

    elif pkg_type == 'service':
        pkg_dict = add_datasets_served_to_service(pkg_dict)

    return pkg_dict

def add_services_data_to_dataset(ds_dict):

    exclude_resources = False
    ds_id = ds_dict.get('id')
    selected_services = DSQuery.read_services_for_dataset(ds_id)
    serv_list = adjust_list_to_solr_fq(selected_services)

    services = []
    if serv_list:
        try:
            user = toolkit.g.user
        except:
            user = 'admin'
        services = get_local_services_for_datasets_data(user, ds_id, serv_list)

    if services:
        ds_dict['services'] = {}
        ds_dict['services']['count'] = services['count']
        ds_dict['services']['results'] = services['results']

    if exclude_resources and "services" in ds_dict:
        for s in ds_dict['services']['results']:
            s.pop('resources', None)

    # Update comma list of services
    ds_dict['services_used_list'] = serv_list.replace(' OR ', ',')

    return ds_dict


def add_datasets_served_to_service(serv_dict):

    exclude_resources = True
    service_id = serv_dict.get('id')

    selected_ds = DSQuery.read_datasets_for_service(service_id)
    ds_list = adjust_list_to_solr_fq(selected_ds)

    dsets = []
    if ds_list:
        try:
            user = toolkit.g.user
        except:
            user = 'admin'

        dsets = get_local_datasets_for_services_data(user, service_id, ds_list)

    if dsets:
        serv_dict['datasets_served'] = {}
        serv_dict['datasets_served']['count'] = dsets['count']
        serv_dict['datasets_served']['results'] = dsets['results']

    if "datasets_served" in serv_dict:
        if exclude_resources:
            for ds in serv_dict['datasets_served']['results']:
                ds.pop('resources', None)

        # Add URI
        for ds in serv_dict['datasets_served']['results']:
            ds['uri'] = h.url_for('/', qualified=True)+h.url_for('dataset.read', id=ds['name'])

    # Update comma list of datasets served
    serv_dict['datasets_served_list'] = ds_list.replace(' OR ',',')

    return serv_dict

def adjust_list_to_solr_fq(ds_list):
    res_list = ''
    for ds in ds_list:
        if res_list == '':
            res_list = ds
        else:
            res_list = res_list + ' OR ' + ds

    return res_list


def get_services_for_dataset_display(ds_id):
    selected_services = DSQuery.read_services_for_dataset(ds_id)
    serv_list = adjust_list_to_solr_fq(selected_services)

    services = {"results": []}
    if serv_list:
        services = get_local_services_for_datasets_data(toolkit.g.user, ds_id, serv_list)

    for service in services["results"]:
        org_name = service['organization']['name'].replace("-", " ").title()
        service['org_name'] = short_label(org_name, 25)
        service['s_title'] = short_label(service['title'],70)
        service['s_url'] = h.url_for('dataset.read', id=service['name']).replace('dataset', service['type'],1)

    return services['results']


def get_datasets_for_service_display(service_id):
    selected_datasets = DSQuery.read_datasets_for_service(service_id)
    ds_list = adjust_list_to_solr_fq(selected_datasets)

    datasets = []
    if ds_list:
        datasets = get_local_datasets_for_services_data(toolkit.g.user, service_id, ds_list)

    if "results" not in datasets:
        return []

    for dataset in datasets["results"]:
        org_name = dataset['organization']['name'].replace("-", " ").title()
        dataset['org_name'] = short_label(org_name, 25)
        dataset['ds_title'] = short_label(dataset['title'],70)
        dataset['ds_url'] = h.url_for('dataset.read', id=dataset['name']).replace('dataset', dataset['type'],1)

    return datasets['results']

