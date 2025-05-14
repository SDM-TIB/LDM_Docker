# pytest --ckan-ini=test.ini ckanext/tibimport/tests/test_GOETTINGEN_profile.py -s

from ckanext.tibimport.GOETTINGEN_ParserProfile import GOETTINGEN_ParserProfile
from ckanext.tibimport.logic2 import LDM_DatasetImport
import pytest

from GOETTINGEN_Profile_Mocks import goettingen_dataset_parsed_to_dict, goettingen_dataset_parsed_to_ckan_dict, resumption_token_ok, \
    resumption_token_empty, expected_list_of_dict_from_goettingen, goettingen_all_datasets_list_response, \
    ckan_dict_of_imported_dataset, goettingen_dict_of_imported_dataset, local_organization_data, local_dataset_data

import sqlalchemy as sa

import requests
from requests.models import Response
import json
from unittest.mock import Mock, patch
from ckan.plugins import toolkit

skip_test_over_server = True
skip_test_DatasetImport = True
#@pytest.mark.skipif(skip_test1, reason="slows all the work") # put before conditional test to skip

#logged_user = "test.ckan.net"


# TEST LDM_DatasetImport
# **********************

# SEARCH ORGANIZATION - NOT FOUND
@pytest.mark.skipif(skip_test_DatasetImport, reason="slows all the work")
def test_search_local_org_not_found():
    parser = GOETTINGEN_ParserProfile()
    obj = LDM_DatasetImport(parser)

    org_name = "TEST-3499-944kdf20"
    res_dict = obj.get_local_organization(org_name)
    assert res_dict == {}

# INSERT ORGANIZATION
@pytest.mark.skipif(skip_test_DatasetImport, reason="slows all the work")
def test_insert_local_org():
    parser = GOETTINGEN_ParserProfile()
    obj = LDM_DatasetImport(parser)

    org_dict = local_organization_data
    obj.insert_organization(org_dict)

    res_dict = obj.get_local_organization(org_dict['name'])
    print(res_dict)
    assert res_dict['name'] == org_dict['name']

# SEARCH ORGANIZATION - FOUND
@pytest.mark.skipif(skip_test_DatasetImport, reason="slows all the work")
def test_search_local_org_found():
    parser = GOETTINGEN_ParserProfile()
    obj = LDM_DatasetImport(parser)

    org_dict = local_organization_data
    res_dict = obj.get_local_organization(org_dict['name'])
    assert res_dict['name'] == org_dict['name']

# SEARCH DATASET NOT FOUND
@pytest.mark.skipif(skip_test_DatasetImport, reason="slows all the work")
def test_search_local_dataset_not_found():
    parser = GOETTINGEN_ParserProfile()
    obj = LDM_DatasetImport(parser)

    ds_name = "TEST-3499-944kdf20"
    res_dict = obj.get_local_dataset(ds_name)
    assert res_dict == {}


# INSERT DATASET
@pytest.mark.skipif(skip_test_DatasetImport, reason="slows all the work")
def test_insert_local_dataset():

    # Delete test dataset from DB
    db_url = toolkit.config['sqlalchemy.url']
    engine = sa.create_engine(db_url)
    result = engine.execute(u"DELETE FROM package_extra WHERE package_id = '476cdf71-1048-4a6f-a28a-58fff547dae5'")
    result = engine.execute(u"DELETE FROM package WHERE id = '476cdf71-1048-4a6f-a28a-58fff547dae5'")

    parser = GOETTINGEN_ParserProfile()
    obj = LDM_DatasetImport(parser)

    ds_dict = local_dataset_data
    obj.insert_dataset(ds_dict)

    res_dict = obj.get_local_dataset(ds_dict['name'])
    ds_dict['metadata_created'] = res_dict['metadata_created']
    ds_dict['metadata_modified'] = res_dict['metadata_modified']

    print(res_dict)
    assert res_dict['name'] == ds_dict['name']

# SEARCH DATASET FOUND
@pytest.mark.skipif(skip_test_DatasetImport, reason="slows all the work")
def test_search_local_dataset_found():
    parser = GOETTINGEN_ParserProfile()
    obj = LDM_DatasetImport(parser)

    ds_dict = local_dataset_data

    ds_name = local_dataset_data['name']
    res_dict = obj.get_local_dataset(ds_name)
    ds_dict['metadata_created'] = res_dict['metadata_created']
    ds_dict['metadata_modified'] = res_dict['metadata_modified']
    ds_dict['state'] = res_dict['state']
    assert res_dict['name'] == ds_dict['name']

# UPDATE DATASET
@pytest.mark.skipif(skip_test_DatasetImport, reason="slows all the work")
def test_update_local_dataset():

    parser = GOETTINGEN_ParserProfile()
    obj = LDM_DatasetImport(parser)

    ds_dict = local_dataset_data

    ds_name = local_dataset_data['name']
    ds_dict['author'] = "New Test Author"
    obj.update_dataset(ds_dict)

    res_dict = obj.get_local_dataset(ds_name)
    assert res_dict['author'] == ds_dict['author']


# DELETE DATASET
@pytest.mark.skipif(skip_test_DatasetImport, reason="slows all the work")
def test_delete_local_dataset():
    parser = GOETTINGEN_ParserProfile()
    obj = LDM_DatasetImport(parser)

    ds_dict = local_dataset_data
    obj.delete_dataset(ds_dict['name'])

    res_dict = obj.get_local_dataset(ds_dict['name'])

    assert res_dict['state'] == 'deleted'

# DELETE ORGANIZATION
@pytest.mark.skipif(skip_test_DatasetImport, reason="slows all the work")
def test_delete_local_org(app):
    parser = GOETTINGEN_ParserProfile()
    obj = LDM_DatasetImport(parser)

    org_dict = local_organization_data
    obj.delete_organization(org_dict['name'])

    res_dict = obj.get_local_organization(org_dict['name'])

    assert res_dict == {}


# TEST GOETTINGEN API
# *******************

# Test remote connections
# ***********************
#https://leopard.tu-braunschweig.de/servlets/OAIDataProvider
#LeoPARD Harvesting tool docs: https://www.openarchives.org/OAI/openarchivesprotocol.html
def test_goettingen_harvesting_remote_ok():
    parser = GOETTINGEN_ParserProfile()
    
    url = parser.goettingen_ListRecords_url

    response = requests.get(url)

    # print('XML fist page response:', response.content, url)
    assert response.ok

    doi = response.json()['data']['items'][1]['global_id'].replace('doi:', '')
    # doi = "3A10.25625/BZYLZ0"
    url2 = parser.goettingen_export_to_schema_org_url + doi
    # print("\n\nURL EXPORT:", url2)
    response = requests.get(url2)

    print("\n\nFIRST DATASET:", response._content)

    assert response.ok


# Test Application logic mocking API responses
# ********************************************

def mocked_requests_get(*args, **kwargs):
    print("\n\nCALL URL", args[0])
    response_content = None
    request_url = args[0]
    
    response = Response()
    response.status_code = 200

    if request_url == 'test_goettingen_get_datasets_list_error':
        with open('./ckanext/tibimport/tests/goettingen_error.json', 'r') as file:
            json_data = file.read()
        response_content = json_data
    # seccond page should be with no results    
    elif request_url == 'test_goettingen_get_datasets_list_ok&start=500' or request_url == 'test_get_all_datasets_dicts&start=500':
        json_data = '{"status":"OK","data":{"q":"*","total_count":2077,"start":10000,"spelling_alternatives":{},"items":[],"count_in_response":0}}'
        response_content = json_data

    elif request_url == 'test_goettingen_get_datasets_list_ok' or request_url == 'test_get_all_datasets_dicts':
        # Emule harvester response from file
        with open('./ckanext/tibimport/tests/goettingen_dataset.json', 'r') as file:
            json_data = file.read()
        response_content = json_data
        # print("\n\nJSON DATA:", json_data)

    elif request_url == 'test_goettingen_get_datasets_list_no_response':
        response_content = 'ERROR'
        response.status_code = 404

    elif 'test_goettingen_export_dataset' in request_url:
        
        id = request_url.replace("test_goettingen_export_dataset10.25625/","")

        # Emule harvester response from file
        with open('./ckanext/tibimport/tests/goettingen_export_'+id+'.json', 'r') as file:
            json_data = file.read()
        response_content = json_data

    response._content = str.encode(response_content)
    return response


# TEST Goettingen get_dataset_list
@patch('ckanext.tibimport.GOETTINGEN_ParserProfile.requests.get', side_effect=mocked_requests_get)
def test_goettingen_get_datasets_list_error(mock_get):

    obj = GOETTINGEN_ParserProfile()
    obj.goettingen_ListRecords_url = 'test_goettingen_get_datasets_list_error'
    res_dict = obj.get_datasets_list()

       # print("RES DICT:\n", res_dict)
    assert res_dict == []


@patch('ckanext.tibimport.GOETTINGEN_ParserProfile.requests.get', side_effect=mocked_requests_get)
def test_goettingen_get_datasets_list_ok(mock_get):

    obj = GOETTINGEN_ParserProfile()
    obj.goettingen_ListRecords_url = 'test_goettingen_get_datasets_list_ok'
    obj.goettingen_export_to_schema_org_url = 'test_goettingen_export_dataset'
    res_dict = obj.get_datasets_list()

    #print('LIST LENGHT:', len(res_dict))

    assert 5 == len(res_dict)

    print('DATASETS LIST: ', res_dict)

    assert res_dict == expected_list_of_dict_from_goettingen

@patch('ckanext.tibimport.GOETTINGEN_ParserProfile.requests.get', side_effect=mocked_requests_get)
def test_goettingen_get_datasets_list_no_response(mock_get):

    # Emule harvester NO response

    obj = GOETTINGEN_ParserProfile()
    obj.goettingen_ListRecords_url = 'test_goettingen_get_datasets_list_no_response'

    res_dict = obj.get_datasets_list()

    print("RES DICT:\n", res_dict)
    assert res_dict == []


def test_parse_goettingen_RECORD_DICT_to_LDM_CKAN_DICT():
    goettingen_dict = goettingen_dataset_parsed_to_dict

    parser = GOETTINGEN_ParserProfile()

    res_dict = parser.parse_goettingen_RECORD_DICT_to_LDM_CKAN_DICT(goettingen_dict)

    print("\n\nPARSED DICT: \n", res_dict)

    assert res_dict == goettingen_dataset_parsed_to_ckan_dict


@patch('ckanext.tibimport.GOETTINGEN_ParserProfile.requests.get', side_effect=mocked_requests_get)
def test_get_all_datasets_dicts(mock_get):


    obj = GOETTINGEN_ParserProfile()
    obj.goettingen_ListRecords_url = 'test_get_all_datasets_dicts'
    obj.goettingen_export_to_schema_org_url = 'test_goettingen_export_dataset'
    #res_list = obj.get_datasets_list()
    res_list = obj.get_all_datasets_dicts()
    print("\nALL Datasets List:\n", res_list)
    print("\nLEN:", len(res_list))
    assert res_list == goettingen_all_datasets_list_response

@pytest.mark.skipif(skip_test_over_server, reason="slows all the work") # put before conditional test to skip
def test_all_datasets_are_retrieved():
    obj = GOETTINGEN_ParserProfile()

    res_list = obj.get_all_datasets_dicts()
   # print("\nALL Datasets List:\n", res_list)
    print("\nTOTAL GOETTINGEN DS:", len(res_list))
    assert len(res_list) == obj.total_goettingen_datasets


def test_should_be_updated_false():
    obj = GOETTINGEN_ParserProfile()

    local_dataset = ckan_dict_of_imported_dataset
    remote_dataset = goettingen_dict_of_imported_dataset

    res = obj.should_be_updated(local_dataset, remote_dataset)

    assert res == False


def test_should_be_updated_true():
    obj = GOETTINGEN_ParserProfile()

    local_dataset = ckan_dict_of_imported_dataset
    remote_dataset = goettingen_dict_of_imported_dataset
    remote_dataset['title'] = 'New Title'
    print("\n\nCKAN DATASET:\n", local_dataset)
    print("\n\nLEO IMPORTED DATASET:\n", remote_dataset)
    res = obj.should_be_updated(local_dataset, remote_dataset)

    assert res == True

def test_check_current_schema():
    obj = GOETTINGEN_ParserProfile()
    res = obj.check_current_schema()

    print("\nSCHEMA REPORT: ", res)

    assert res['status_ok']





