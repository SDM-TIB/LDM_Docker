# pytest --ckan-ini=test.ini ckanext/tibimport/tests/test_OSNADATA_profile.py -s

from ckanext.tibimport.OSNADATA_ParserProfile import OSNADATA_ParserProfile
from ckanext.tibimport.logic2 import LDM_DatasetImport
import pytest

from OSNADATA_Profile_Mocks import osnadata_dataset_parsed_to_dict, osnadata_dataset_parsed_to_ckan_dict, resumption_token_ok, \
    resumption_token_empty, expected_list_of_dict_from_osnadata, osnadata_all_datasets_list_response, \
    ckan_dict_of_imported_dataset, osnadata_dict_of_imported_dataset, local_organization_data, local_dataset_data

import sqlalchemy as sa


import xmltodict
from xml.etree import ElementTree

import pprint

import requests
from requests.models import Response
import json
from unittest.mock import Mock, patch
from ckan.plugins import toolkit

skip_test1 = False
skip_test_DatasetImport = True
#@pytest.mark.skipif(skip_test1, reason="slows all the work") # put before conditional test to skip

#logged_user = "test.ckan.net"


# TEST LDM_DatasetImport
# **********************

# SEARCH ORGANIZATION - NOT FOUND
@pytest.mark.skipif(skip_test_DatasetImport, reason="slows all the work")
def test_search_local_org_not_found():
    parser = OSNADATA_ParserProfile()
    obj = LDM_DatasetImport(parser)

    org_name = "TEST-3499-944kdf20"
    res_dict = obj.get_local_organization(org_name)
    assert res_dict == {}

# INSERT ORGANIZATION
@pytest.mark.skipif(skip_test_DatasetImport, reason="slows all the work")
def test_insert_local_org():
    parser = OSNADATA_ParserProfile()
    obj = LDM_DatasetImport(parser)

    org_dict = local_organization_data
    obj.insert_organization(org_dict)

    res_dict = obj.get_local_organization(org_dict['name'])
    print(res_dict)
    assert res_dict['name'] == org_dict['name']

# SEARCH ORGANIZATION - FOUND
@pytest.mark.skipif(skip_test_DatasetImport, reason="slows all the work")
def test_search_local_org_found():
    parser = OSNADATA_ParserProfile()
    obj = LDM_DatasetImport(parser)

    org_dict = local_organization_data
    res_dict = obj.get_local_organization(org_dict['name'])
    assert res_dict['name'] == org_dict['name']

# SEARCH DATASET NOT FOUND
@pytest.mark.skipif(skip_test_DatasetImport, reason="slows all the work")
def test_search_local_dataset_not_found():
    parser = OSNADATA_ParserProfile()
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

    parser = OSNADATA_ParserProfile()
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
    parser = OSNADATA_ParserProfile()
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

    parser = OSNADATA_ParserProfile()
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
    parser = OSNADATA_ParserProfile()
    obj = LDM_DatasetImport(parser)

    ds_dict = local_dataset_data
    obj.delete_dataset(ds_dict['name'])

    res_dict = obj.get_local_dataset(ds_dict['name'])

    assert res_dict['state'] == 'deleted'

# DELETE ORGANIZATION
@pytest.mark.skipif(skip_test_DatasetImport, reason="slows all the work")
def test_delete_local_org(app):
    parser = OSNADATA_ParserProfile()
    obj = LDM_DatasetImport(parser)

    org_dict = local_organization_data
    obj.delete_organization(org_dict['name'])

    res_dict = obj.get_local_organization(org_dict['name'])

    assert res_dict == {}


# TEST osnaData API
# *****************

# Test remote connections
# ***********************
#https://osnadata.ub.uni-osnabrueck.de/oai
#LeoPARD Harvesting tool docs: https://www.openarchives.org/OAI/openarchivesprotocol.html
def test_osnadata_harvesting_remote_ok():
    parser = OSNADATA_ParserProfile()
    # https://osnadata.ub.uni-osnabrueck.de/oai?verb=ListRecords&metadataPrefix=oai_datacite
    url = parser.osnaData_ListRecords_url+parser.osnaData_metadata_schema_response_prefix
       
    response = requests.get(url)

    print('XML fist page response:', response.content[-1000:], url)
    assert response.ok



# Test Application logic mocking API responses
# ********************************************

def mocked_requests_get(*args, **kwargs):
    response_content = None
    request_url = args[0]
    # request_url = request_url.replace('&from=0001-01-01T00:00:00Z&until=9999-12-31T23:59:59Z&metadataPrefix=radar', '')
    response = Response()
    response.status_code = 200

    if request_url == 'test_osnadata_get_datasets_list_error':
        with open('./ckanext/tibimport/tests/osnadata_error.xml', 'r') as file:
            xml_data = file.read()
        response_content = xml_data

    elif request_url == 'test_osnadata_get_datasets_list_ok' or request_url == 'test_get_all_datasets_dicts':
        # Emule harvester response from file
        with open('./ckanext/tibimport/tests/osnadata_dataset.xml', 'r') as file:
            xml_data = file.read()
        # empty resumption token to avoid endless loop
        # xml_data = xml_data.replace(
            # '<resumptionToken completeListSize="179">rows=100@@searchMark=10.22000/72@@from=0001-01-01T00:00:00Z'
            # '@@total=179@@until=9999-12-31T23:59:59Z@@metadataPrefix=radar</resumptionToken>', '<resumptionToken />')
        response_content = xml_data
    
    elif request_url == 'test_osnadata_get_datasets_list_all':
        # Emule harvester response from file
        with open('./ckanext/tibimport/tests/osnadata_response.xml', 'r') as file:
            xml_data = file.read()
        
        response_content = xml_data

    elif request_url == 'test_osnadata_get_datasets_list_no_response':
        response_content = 'ERROR'
        response.status_code = 404

    elif 'test_osnadata_export_dataset' in request_url:
        
        id = request_url.replace("test_osnadata_export_datasetdoi:10.26249/FK2/","")
        # osnadata_export_test_osnadata_export_datasetdoi:10.26249/FK2/48FTWW.json
        # Fix for testing All datasets search (test_osnadata_get_datasets_list_complete)
        if id not in ['48FTWW', '4B3NSO', '5AXRBJ']:
            id = '48FTWW'

        # Emule harvester response from file
        with open('./ckanext/tibimport/tests/osnadata_export_'+id+'.json', 'r') as file:
            json_data = file.read()
        
        response_content = json_data
        response._content = response_content

    response._content = str.encode(response_content)
    return response


# TEST osnaData get_dataset_list
@patch('ckanext.tibimport.OSNADATA_ParserProfile.requests.get', side_effect=mocked_requests_get)
def test_osnadata_get_datasets_list_error(mock_get):

    obj = OSNADATA_ParserProfile()
    obj.osnaData_ListRecords_url = 'test_osnadata_get_datasets_list_error'
    res_dict = obj.get_datasets_list()

       # print("RES DICT:\n", res_dict)
    assert res_dict == []


@patch('ckanext.tibimport.OSNADATA_ParserProfile.requests.get', side_effect=mocked_requests_get)
def test_osnadata_get_datasets_list_ok(mock_get):

    # # Emule harvester response from file
    # with open('./ckanext/tibimport/tests/leopard_dataset.xml', 'r') as file:
    #     xml_data = file.read()
    # # empty resumption token to avoid endless loop
    # xml_data = xml_data.replace(
    #     '<resumptionToken completeListSize="179">rows=100@@searchMark=10.22000/72@@from=0001-01-01T00:00:00Z'
    #     '@@total=179@@until=9999-12-31T23:59:59Z@@metadataPrefix=radar</resumptionToken>', '<resumptionToken />')

    obj = OSNADATA_ParserProfile()
    obj.osnaData_ListRecords_url = 'test_osnadata_get_datasets_list_ok'
    obj.osnadata_export_to_dataverse_json_url = 'test_osnadata_export_dataset'
    res_dict = obj.get_datasets_list()

    #print('LIST LENGHT:', len(res_dict))

    assert 3 == len(res_dict)

    print('\n\nDATASETS LIST: ', res_dict)

    assert res_dict == expected_list_of_dict_from_osnadata

@patch('ckanext.tibimport.OSNADATA_ParserProfile.requests.get', side_effect=mocked_requests_get)
def test_osnadata_get_datasets_list_complete(mock_get):

    # The system should filter only open Datasets

    obj = OSNADATA_ParserProfile()
    obj.osnaData_ListRecords_url = 'test_osnadata_get_datasets_list_all'
    obj.osnadata_export_to_dataverse_json_url = 'test_osnadata_export_dataset'
    res_dict = obj.get_datasets_list()

    #print('LIST LENGHT:', len(res_dict))

    
    #license_list = [dataset['metadata']['osnaDataDataset']['rightsList'] for dataset in res_dict]
    #type_list = [dataset['metadata']['osnaDataDataset']['resourceType']['resourceTypeGeneral'] for dataset in res_dict]
    #print('LICENSES:\n', license_list)
    #print('LICENSES:\n', type_list)
    
    assert 45 == len(res_dict)
    #assert res_dict == expected_list_of_dict_from_osnadata





@patch('ckanext.tibimport.OSNADATA_ParserProfile.requests.get', side_effect=mocked_requests_get)
def test_osnadata_get_datasets_list_no_response(mock_get):

    # Emule harvester NO response

    obj = OSNADATA_ParserProfile()
    obj.osnaData_ListRecords_url = 'test_osnadata_get_datasets_list_no_response'

    res_dict = obj.get_datasets_list()

    print("RES DICT:\n", res_dict)
    assert res_dict == []



def test_get_osnadata_resumption_token_empty():
    obj = OSNADATA_ParserProfile()

    # Emule harvester response from file
    with open('./ckanext/tibimport/tests/osnadata_dataset.xml', 'r') as file:
        xml_data = file.read()
    # with empty token
    
    xml_tree_data = ElementTree.fromstring(xml_data)

    resumption_token = obj._get_osnaData_resumption_token(xml_tree_data)
 #   print("RESUMPTION TOKEN EMPTY: ", resumption_token)

    assert resumption_token == resumption_token_empty

def test_get_osnadata_resumption_token_not_present():
    obj = OSNADATA_ParserProfile()

    # Emule harvester response from file
    with open('./ckanext/tibimport/tests/osnadata_dataset.xml', 'r') as file:
        xml_data = file.read()
    # with empty token
    
    xml_tree_data = ElementTree.fromstring(xml_data)

    resumption_token = obj._get_osnaData_resumption_token(xml_tree_data)
   # print("RESUMPTION TOKEN EMPTY: ", resumption_token)

    assert resumption_token == resumption_token_empty


def test_parse_osnadata_XML_RECORD_to_DICT():
    parser = OSNADATA_ParserProfile()

    # Emule harvester response from file
    with open('./ckanext/tibimport/tests/osnadata_dataset.xml', 'r') as file:
        xml_data = file.read()

    xml_tree_data = ElementTree.fromstring(xml_data)

    # parse just first record
    ns0 = '{http://www.openarchives.org/OAI/2.0/}'
    for record in xml_tree_data.iter(ns0+'record'):
        res_dict = parser.parse_osnaData_XML_RECORD_to_DICT(record)
        break
    import pprint
    res = parser._get_citations_and_license_from_API(res_dict['header']['identifier'])
        
    res_dict['metadata']['osnaDataDataset']['citation'] = res['citation']
    res_dict['metadata']['osnaDataDataset']['license'] = res['license']
    
    # print('\n\nDICT response:\n', pprint.pprint(res_dict, width=100, sort_dicts=False))
    print('\n\nDICT response:\n', res_dict)

    assert res_dict == osnadata_dataset_parsed_to_dict


def test_parse_osnadata_RECORD_DICT_to_LDM_CKAN_DICT():
    osnadata_dict = osnadata_dataset_parsed_to_dict

    parser = OSNADATA_ParserProfile()

    res_dict = parser.parse_osnaData_RECORD_DICT_to_LDM_CKAN_DICT(osnadata_dict)

    print("\n\nPARSED DICT: \n", res_dict)

    assert res_dict == osnadata_dataset_parsed_to_ckan_dict


@patch('ckanext.tibimport.OSNADATA_ParserProfile.requests.get', side_effect=mocked_requests_get)
def test_get_all_datasets_dicts(mock_get):


    obj = OSNADATA_ParserProfile()
    obj.osnaData_ListRecords_url = 'test_get_all_datasets_dicts'
    obj.osnadata_export_to_dataverse_json_url = 'test_osnadata_export_dataset'
    #res_list = obj.get_datasets_list()
    res_list = obj.get_all_datasets_dicts()
    print("\nALL Datasets List:\n", res_list)
    print("\nLEN:", len(res_list))
    assert res_list == osnadata_all_datasets_list_response


def test_all_datasets_are_retrieved():
    obj = OSNADATA_ParserProfile()

    res_list = obj.get_all_datasets_dicts()
    # print("\nALL Datasets List:\n", res_list)
    print("\nTOTAL OSNADATA DS:", len(res_list))
    assert len(res_list) == obj.total_osnaData_datasets

def test_should_be_updated_false():
    obj = OSNADATA_ParserProfile()

    local_dataset = ckan_dict_of_imported_dataset
    remote_dataset = osnadata_dict_of_imported_dataset

    res = obj.should_be_updated(local_dataset, remote_dataset)

    assert res == False

def test_should_be_updated_true():
    obj = OSNADATA_ParserProfile()

    local_dataset = ckan_dict_of_imported_dataset
    remote_dataset = osnadata_dict_of_imported_dataset
    remote_dataset['title'] = 'New Title'
    print("\n\nCKAN DATASET:\n", local_dataset)
    print("\n\nLEO IMPORTED DATASET:\n", remote_dataset)
    res = obj.should_be_updated(local_dataset, remote_dataset)

    assert res == True

# def test_check_current_schema():
#     obj = OSNADATA_ParserProfile()
#     res = obj.check_current_schema()

#     print("\nSCHEMA REPORT: ", res)

#     assert res['status_ok']

# def test_process_all_remote_datasets():

#     obj = OSNADATA_ParserProfile()
#     # process all remote datasets from OSNADATA
#     obj.get_all_datasets_dicts()

#     # Expecting errors in code in case something goes wrong during parsing
#     assert True


