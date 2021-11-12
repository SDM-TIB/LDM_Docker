# pytest --ckan-ini=test.ini ckanext/tibimport/tests -s

from ckanext.tibimport.logic2 import LUH_CKAN_API_ParserProfile
from ckanext.tibimport.logic2 import LDM_DatasetImport
import pytest
from LUH_Profile_Mocks import local_organization_data, local_dataset_data, luh_api_package_list_no_results,\
    luh_api_package_list_with_results, luh_api_package_show_no_results, luh_api_package_show_with_results, \
    luh_api_organization_show_no_results, luh_api_organization_show_with_results, luh_datasets_and_resources_keys

import sqlalchemy as sa

import requests
import json
from unittest.mock import Mock, patch
from ckan.plugins import toolkit

skip_test1 = True
#@pytest.mark.skipif(skip_test1, reason="slows all the work") # put before conditional test to skip

logged_user = "test.ckan.net"


# TEST LDM_DatasetImport
# **********************

# SEARCH ORGANIZATION - NOT FOUND
def test_search_local_org_not_found():
    parser = LUH_CKAN_API_ParserProfile()
    obj = LDM_DatasetImport(parser, logged_user)

    org_name = "TEST-3499-944kdf20"
    res_dict = obj.get_local_organization(org_name)
    assert res_dict == {}

# INSERT ORGANIZATION
def test_insert_local_org():
    parser = LUH_CKAN_API_ParserProfile()
    obj = LDM_DatasetImport(parser, logged_user)

    org_dict = local_organization_data
    obj.insert_organization(org_dict)

    res_dict = obj.get_local_organization(org_dict['name'])
    print(res_dict)
    assert res_dict == org_dict

# SEARCH ORGANIZATION - FOUND
def test_search_local_org_found():
    parser = LUH_CKAN_API_ParserProfile()
    obj = LDM_DatasetImport(parser, logged_user)

    org_dict = local_organization_data
    res_dict = obj.get_local_organization(org_dict['name'])
    assert res_dict == org_dict

# SEARCH DATASET NOT FOUND
def test_search_local_dataset_not_found():
    parser = LUH_CKAN_API_ParserProfile()
    obj = LDM_DatasetImport(parser, logged_user)

    ds_name = "TEST-3499-944kdf20"
    res_dict = obj.get_local_dataset(ds_name)
    assert res_dict == {}


# INSERT DATASET
def test_insert_local_dataset():

    # Delete test dataset from DB
    db_url = toolkit.config['sqlalchemy.url']
    engine = sa.create_engine(db_url)
    result = engine.execute(u"DELETE FROM package_extra WHERE package_id = '476cdf71-1048-4a6f-a28a-58fff547dae5'")
    result = engine.execute(u"DELETE FROM package WHERE id = '476cdf71-1048-4a6f-a28a-58fff547dae5'")

    parser = LUH_CKAN_API_ParserProfile()
    obj = LDM_DatasetImport(parser, logged_user)

    ds_dict = local_dataset_data
    obj.insert_dataset(ds_dict)

    res_dict = obj.get_local_dataset(ds_dict['name'])
    ds_dict['metadata_created'] = res_dict['metadata_created']
    ds_dict['metadata_modified'] = res_dict['metadata_modified']

    print(res_dict)
    assert res_dict == ds_dict

# SEARCH DATASET FOUND
def test_search_local_dataset_found():
    parser = LUH_CKAN_API_ParserProfile()
    obj = LDM_DatasetImport(parser, logged_user)

    ds_dict = local_dataset_data

    ds_name = local_dataset_data['name']
    res_dict = obj.get_local_dataset(ds_name)
    ds_dict['metadata_created'] = res_dict['metadata_created']
    ds_dict['metadata_modified'] = res_dict['metadata_modified']
    ds_dict['state'] = res_dict['state']
    assert res_dict == local_dataset_data

# UPDATE DATASET
def test_update_local_dataset():

    parser = LUH_CKAN_API_ParserProfile()
    obj = LDM_DatasetImport(parser, logged_user)

    ds_dict = local_dataset_data

    ds_name = local_dataset_data['name']
    ds_dict['author'] = "New Test Author"
    obj.update_dataset(ds_dict)

    res_dict = obj.get_local_dataset(ds_name)
    assert res_dict['author'] == ds_dict['author']


# DELETE DATASET
def test_delete_local_dataset():
    parser = LUH_CKAN_API_ParserProfile()
    obj = LDM_DatasetImport(parser, logged_user)

    ds_dict = local_dataset_data
    obj.delete_dataset(ds_dict['name'])

    res_dict = obj.get_local_dataset(ds_dict['name'])

    assert res_dict['state'] == 'deleted'

# DELETE ORGANIZATION
def test_delete_local_org(app):
    parser = LUH_CKAN_API_ParserProfile()
    obj = LDM_DatasetImport(parser, logged_user)

    org_dict = local_organization_data
    obj.delete_organization(org_dict['name'])

    res_dict = obj.get_local_organization(org_dict['name'])

    assert res_dict == {}


# TEST LUH API
# ************

# Test remote connections
# ***********************
#self.ckan_api_url_package_list = "https://data.uni-hannover.de/api/3/action/package_list"
def test_luh_api_package_list_remote():
    parser = LUH_CKAN_API_ParserProfile()
    response = requests.get(parser.ckan_api_url_package_list)

    assert response.ok

#self.ckan_api_url_package_show = "https://data.uni-hannover.de/api/3/action/package_show"
def test_luh_api_package_show_remote():
    parser = LUH_CKAN_API_ParserProfile()

    response = requests.get(parser.ckan_api_url_package_list)
    res = json.loads(response.content)
    print(res['result'][0])
    ds_title = res['result'][0]
    data = {'id': ds_title}
    response = requests.post(parser.ckan_api_url_package_show, data = data)

    assert response.ok

#self.ckan_api_url_organization_show = "https://data.uni-hannover.de/api/3/action/organization_show"
def test_luh_api_organization_show_remote():
    parser = LUH_CKAN_API_ParserProfile()

    # get list of dataset
    response = requests.get(parser.ckan_api_url_package_list)
    res = json.loads(response.content)
    # get data from first listed dataset
    ds_title = res['result'][0]
    data = {'id': ds_title}
    response = requests.post(parser.ckan_api_url_package_show, data = data)
    # get data from organization
    org_name = json.loads(response.content)['result']['organization']['name']
    response = requests.get(parser.ckan_api_url_organization_show, params= {'id': org_name})

    assert response.ok



# Test Application logic mocking API responses
# ********************************************

#self.ckan_api_url_package_list = "https://data.uni-hannover.de/api/3/action/package_list"
# TEST API package_list - CONNECTION FAILING
def test_luh_api_package_list_fail():

    with patch('ckanext.tibimport.logic2.requests.get') as mock_get:
        # Configure the mock to return a response with an OK status code
        mock_get.return_value.ok = False

        obj = LUH_CKAN_API_ParserProfile()
        res_dict = obj.get_datasets_list()

    assert res_dict == {}

# TEST API package_list - NO DATA
def test_luh_api_package_list_no_data():

    with patch('ckanext.tibimport.logic2.requests.get') as mock_get:
        # Configure the mock to return a response with an OK status code and data
        mock_get.return_value.ok = True
        mock_get.return_value.json.return_value = luh_api_package_list_no_results

        obj = LUH_CKAN_API_ParserProfile()

        res_dict = obj.get_datasets_list()
        print("API response package_list fail:\n", luh_api_package_list_no_results)

    assert res_dict == {}

# TEST API package_list - RETRIEVING DATA
def test_luh_api_package_list_ok():

    with patch('ckanext.tibimport.logic2.requests.get') as mock_get:
        # Configure the mock to return a response with an OK status code and data
        mock_get.return_value.ok = True
        mock_get.return_value.json.return_value = luh_api_package_list_with_results

        obj = LUH_CKAN_API_ParserProfile()

        res_dict = obj.get_datasets_list()
        print("API response package_list with results:\n", res_dict)

    assert res_dict == luh_api_package_list_with_results['result']

#self.ckan_api_url_package_show = "https://data.uni-hannover.de/api/3/action/package_show"
# TEST API package_show - CONNECTION FAILING
def test_luh_api_package_show_fail():

    with patch('ckanext.tibimport.logic2.requests.post') as mock_get:
        # Configure the mock to return a response with an OK status code
        mock_get.return_value.ok = False

        obj = LUH_CKAN_API_ParserProfile()
        ds_name = "the name is not used here"
        res_dict = obj.get_dataset_data(ds_name)
    assert res_dict == {}

# TEST API package_show - NO DATA
def test_luh_api_package_show_no_data():

    with patch('ckanext.tibimport.logic2.requests.post') as mock_get:
        # Configure the mock to return a response with an OK status code and data
        mock_get.return_value.ok = True
        mock_get.return_value.json.return_value = luh_api_package_show_no_results

        obj = LUH_CKAN_API_ParserProfile()

        ds_name = "the name is not used here"
        res_dict = obj.get_dataset_data(ds_name)
        print("API response package_show fail:\n", luh_api_package_show_no_results)

    assert res_dict == {}

# TEST API package_show - RETRIEVING DATA
def test_luh_api_package_show_ok():

    with patch('ckanext.tibimport.logic2.requests.post') as mock_get:
        # Configure the mock to return a response with an OK status code and data
        mock_get.return_value.ok = True
        mock_get.return_value.json.return_value = luh_api_package_show_with_results

        obj = LUH_CKAN_API_ParserProfile()
        ds_name = "the name is not used here"

        res_dict = obj.get_dataset_data(ds_name)
        print("API response package_show with results:\n", res_dict)

    assert res_dict == luh_api_package_show_with_results['result']

#self.ckan_api_url_organization_show = "https://data.uni-hannover.de/api/3/action/organization_show"
# TEST API organization_show - CONNECTION FAILING
def test_luh_api_organization_show_fail():

    with patch('ckanext.tibimport.logic2.requests.get') as mock_get:
        # Configure the mock to return a response with an OK status code
        mock_get.return_value.ok = False

        obj = LUH_CKAN_API_ParserProfile()
        org_name = "the name is not used here"

        res_dict = obj.get_organization(org_name)

    assert res_dict == {}

# TEST API organization_show - NO DATA
def test_luh_api_organization_show_no_data():

    with patch('ckanext.tibimport.logic2.requests.get') as mock_get:
        # Configure the mock to return a response with an OK status code and data
        mock_get.return_value.ok = True
        mock_get.return_value.json.return_value = luh_api_organization_show_no_results

        obj = LUH_CKAN_API_ParserProfile()
        org_name = "the name is not used here"

        res_dict = obj.get_organization(org_name)
        print("API response organization_show fail:\n", luh_api_organization_show_no_results)

    assert res_dict == {}

# TEST API organization_show - RETRIEVING DATA
def test_luh_api_organization_show_ok():

    with patch('ckanext.tibimport.logic2.requests.get') as mock_get:
        # Configure the mock to return a response with an OK status code and data
        mock_get.return_value.ok = True
        mock_get.return_value.json.return_value = luh_api_organization_show_with_results

        obj = LUH_CKAN_API_ParserProfile()
        org_name = "the name is not used here"

        res_dict = obj.get_organization(org_name)
        print("API response organization_show with results:\n", res_dict)

    assert res_dict == luh_api_organization_show_with_results['result']


def test_remote_dataset_schema_updated():
    obj = LUH_CKAN_API_ParserProfile()
    schema_keys = obj.get_remote_dataset_schema()

    actual_datasets_keys = schema_keys['dataset_keys']
    actual_resource_keys = schema_keys['resource_keys']

    previous_datasets_keys = luh_datasets_and_resources_keys['dataset_keys']
    previous_resource_keys = luh_datasets_and_resources_keys['resource_keys']

    check_ds_keys = all(item in actual_datasets_keys for item in previous_datasets_keys)
    check_rs_keys = all(item in actual_resource_keys for item in previous_resource_keys)

    print("LUH dataset schema:\n", schema_keys)
    assert check_ds_keys and check_rs_keys

@pytest.mark.skipif(skip_test1, reason="test against API directly - slows all the work")
def test_get_datasets_list():
    obj = LUH_CKAN_API_ParserProfile()

    res_dict = obj.get_datasets_list()
#    print(res_dict)
    print(len(res_dict))
    assert bool(res_dict)

@pytest.mark.skipif(skip_test1, reason="test against API directly - slows all the work")
def test_get_dataset_data():
    ds_title = "a-generic-gust-definition-and-detection-method-based-on-wavelet-analysis"
    obj = LUH_CKAN_API_ParserProfile()

    res_dict = obj.get_dataset_data(ds_title)
    print(res_dict)

    assert ds_title==res_dict['name']

@pytest.mark.skipif(skip_test1, reason="test against API directly - slows all the work")
def test_get_all_datasets_dicts():
    obj = LUH_CKAN_API_ParserProfile()

    res_dict = obj.get_all_datasets_dicts()
    print("Datasets found in LUH:\n", len(res_dict))
    print("Datasets dictionaries:\n", res_dict[0])
    assert 'name' in res_dict[0]

@pytest.mark.skipif(skip_test1, reason="test against API directly - slows all the work")
def test_get_remote_datasets():
    parser = LUH_CKAN_API_ParserProfile()
    obj = LDM_DatasetImport(parser, logged_user)

    datasets_dict = obj.get_remote_datasets()
    print(len(datasets_dict))
    assert len(datasets_dict)>0
