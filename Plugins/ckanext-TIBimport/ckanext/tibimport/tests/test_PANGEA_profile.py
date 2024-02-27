# pytest --ckan-ini=test.ini ckanext/tibimport/tests/test_PANGEA_profile.py -s

from ckanext.tibimport.PANGEA_ParserProfile import PANGEA_ParserProfile
from ckanext.tibimport.logic2 import LDM_DatasetImport
import pytest

from PANGEA_Profile_Mocks import pangea_dataset_parsed_to_dict, pangea_dataset_parsed_to_ckan_dict, resumption_token_ok, \
    resumption_token_empty, expected_list_of_dict_from_pangea, pangea_all_datasets_list_response, \
    ckan_dict_of_imported_dataset, pangea_dict_of_imported_dataset, local_organization_data, local_dataset_data

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
    parser = PANGEA_ParserProfile()
    obj = LDM_DatasetImport(parser)

    org_name = "TEST-3499-944kdf20"
    res_dict = obj.get_local_organization(org_name)
    assert res_dict == {}

# INSERT ORGANIZATION
@pytest.mark.skipif(skip_test_DatasetImport, reason="slows all the work")
def test_insert_local_org():
    parser = PANGEA_ParserProfile()
    obj = LDM_DatasetImport(parser)

    org_dict = local_organization_data
    obj.insert_organization(org_dict)

    res_dict = obj.get_local_organization(org_dict['name'])
    print(res_dict)
    assert res_dict['name'] == org_dict['name']

# SEARCH ORGANIZATION - FOUND
@pytest.mark.skipif(skip_test_DatasetImport, reason="slows all the work")
def test_search_local_org_found():
    parser = PANGEA_ParserProfile()
    obj = LDM_DatasetImport(parser)

    org_dict = local_organization_data
    res_dict = obj.get_local_organization(org_dict['name'])
    assert res_dict['name'] == org_dict['name']

# SEARCH DATASET NOT FOUND
@pytest.mark.skipif(skip_test_DatasetImport, reason="slows all the work")
def test_search_local_dataset_not_found():
    parser = PANGEA_ParserProfile()
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

    parser = PANGEA_ParserProfile()
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
    parser = PANGEA_ParserProfile()
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

    parser = PANGEA_ParserProfile()
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
    parser = PANGEA_ParserProfile()
    obj = LDM_DatasetImport(parser)

    ds_dict = local_dataset_data
    obj.delete_dataset(ds_dict['name'])

    res_dict = obj.get_local_dataset(ds_dict['name'])

    assert res_dict['state'] == 'deleted'

# DELETE ORGANIZATION
@pytest.mark.skipif(skip_test_DatasetImport, reason="slows all the work")
def test_delete_local_org(app):
    parser = PANGEA_ParserProfile()
    obj = LDM_DatasetImport(parser)

    org_dict = local_organization_data
    obj.delete_organization(org_dict['name'])

    res_dict = obj.get_local_organization(org_dict['name'])

    assert res_dict == {}


# TEST PANGEA API
# ***************

# Test remote connections
# ***********************
#https://ws.pangaea.de/oai/
#PANGEA Harvesting tool docs: https://www.openarchives.org/OAI/openarchivesprotocol.html
def test_radar_harvesting_remote_ok():
    parser = PANGEA_ParserProfile()
    url = parser.pangea_ListRecords_url

    response = requests.get(url)

    # PRINT ALL TAGS
    # xml_tree_data = ElementTree.fromstring(response.content)
    # for x in xml_tree_data:
    #     print(x.tag, x.text)
    # tags = [elem.tag for elem in xml_tree_data.iter()]
    # print(tags)

  #  print('XML fist page response:', response.content, url)
    assert response.ok

#
# # Test Application logic mocking API responses
# # ********************************************

def mocked_requests_get(*args, **kwargs):
    response_content = None
    request_url = args[0]
    print("REQUEST URL", request_url)
#    request_url = request_url.replace('&from=0001-01-01T00:00:00Z&until=9999-12-31T23:59:59Z&metadataPrefix=radar', '')
    response = Response()
    response.status_code = 200

    if request_url == 'test_pangea_get_datasets_list_error':
        with open('./ckanext/tibimport/tests/pangea_error.xml', 'r') as file:
            xml_data = file.read()
        response_content = xml_data

    elif request_url == 'test_pangea_get_datasets_list_ok' or request_url == 'test_get_all_datasets_dicts':
        # Emule harvester response from file
        with open('./ckanext/tibimport/tests/pangea_dataset.xml', 'r') as file:
            xml_data = file.read()
        # empty resumption token to avoid endless loop
        xml_data = xml_data.replace(
            '<resumptionToken expirationDate="2022-11-22T08:08:22Z" cursor="0">7d35f2f1-768a-4ccd-9e85-9ec46f871800</resumptionToken>', '')
        response_content = xml_data

    elif request_url == 'test_pangea_get_datasets_list_no_response':
        response_content = 'ERROR'
        response.status_code = 404
    print("RESPONSE CONTENT", response_content)
    response._content = str.encode(response_content)
    return response


# TEST PANGEA get_dataset_list
@patch('ckanext.tibimport.PANGEA_ParserProfile.requests.get', side_effect=mocked_requests_get)
def test_pangea_get_datasets_list_error(mock_get):

    obj = PANGEA_ParserProfile()
    obj.pangea_ListRecords_url = 'test_pangea_get_datasets_list_error'
    res_dict = obj.get_datasets_list()

       # print("RES DICT:\n", res_dict)
    assert res_dict == []


@patch('ckanext.tibimport.PANGEA_ParserProfile.requests.get', side_effect=mocked_requests_get)
def test_pangea_get_datasets_list_ok(mock_get):

    obj = PANGEA_ParserProfile()
    obj.pangea_ListRecords_url = 'test_pangea_get_datasets_list_ok'
    res_dict = obj.get_datasets_list()

    print('LIST LENGHT:', len(res_dict))

    assert 3 == len(res_dict)

    print('DATASETS LIST: ', res_dict)

    assert res_dict == expected_list_of_dict_from_pangea

@patch('ckanext.tibimport.RADAR_ParserProfile.requests.get', side_effect=mocked_requests_get)
def test_pangea_get_datasets_list_no_response(mock_get):

    # Emule harvester NO response

    obj = PANGEA_ParserProfile()
    obj.pangea_ListRecords_url = 'test_pangea_get_datasets_list_no_response'

    res_dict = obj.get_datasets_list()

   # print("RES DICT:\n", res_dict)
    assert res_dict == []

    # get all attributes

    # for x in res_dict:
    #  print(x.tag, x.text)


def test_get_pangea_resumption_token_ok():
    obj = PANGEA_ParserProfile()

    # Emule harvester response from file
    with open('./ckanext/tibimport/tests/pangea_dataset.xml', 'r') as file:
        xml_data = file.read()
    xml_tree_data = ElementTree.fromstring(xml_data)

    resumption_token = obj._get_pangea_resumption_token(xml_tree_data)

#    print("RESUMPTION TOKEN: ", resumption_token)

    assert resumption_token == resumption_token_ok

def test_get_pangea_resumption_token_empty():
    obj = PANGEA_ParserProfile()

    # Emule harvester response from file
    with open('./ckanext/tibimport/tests/pangea_dataset.xml', 'r') as file:
        xml_data = file.read()
    # with empty token
    xml_data = xml_data.replace('<resumptionToken expirationDate="2022-11-22T08:08:22Z" cursor="0">7d35f2f1-'
                                '768a-4ccd-9e85-9ec46f871800</resumptionToken>', '<resumptionToken />')

    xml_tree_data = ElementTree.fromstring(xml_data)

    resumption_token = obj._get_pangea_resumption_token(xml_tree_data)
 #   print("RESUMPTION TOKEN EMPTY: ", resumption_token)

    assert resumption_token == resumption_token_empty

def test_get_pangea_resumption_token_not_present():
    obj = PANGEA_ParserProfile()

    # Emule harvester response from file
    with open('./ckanext/tibimport/tests/pangea_dataset.xml', 'r') as file:
        xml_data = file.read()
    # with empty token
    xml_data = xml_data.replace('<resumptionToken expirationDate="2022-11-22T08:08:22Z" cursor="0">7d35f2f1-'
                                '768a-4ccd-9e85-9ec46f871800</resumptionToken>', '')

    xml_tree_data = ElementTree.fromstring(xml_data)

    resumption_token = obj._get_pangea_resumption_token(xml_tree_data)
   # print("RESUMPTION TOKEN EMPTY: ", resumption_token)

    assert resumption_token == resumption_token_empty


def test_parse_PANGEA_XML_RECORD_to_DICT():
    parser = PANGEA_ParserProfile()

    # Emule harvester response from file
    with open('./ckanext/tibimport/tests/pangea_dataset.xml', 'r') as file:
        xml_data = file.read()

    xml_tree_data = ElementTree.fromstring(xml_data)

    # parse just first record
    ns0 = '{http://www.openarchives.org/OAI/2.0/}'
    for record in xml_tree_data.iter(ns0+'record'):
        res_dict = parser.parse_PANGEA_XML_RECORD_to_DICT(record)
        break

    print('DICT response:', res_dict)

    assert res_dict == pangea_dataset_parsed_to_dict


def test_parse_PANGEA_RECORD_DICT_to_LDM_CKAN_DICT():
    pangea_dict = pangea_dataset_parsed_to_dict

    parser = PANGEA_ParserProfile()

    res_dict = parser.parse_PANGEA_RECORD_DICT_to_LDM_CKAN_DICT(pangea_dict)

    print("PARSED DICT: ", res_dict)

    assert res_dict == pangea_dataset_parsed_to_ckan_dict


@patch('ckanext.tibimport.PANGEA_ParserProfile.requests.get', side_effect=mocked_requests_get)
def test_get_all_datasets_dicts(mock_get):


    obj = PANGEA_ParserProfile()
    obj.pangea_ListRecords_url = 'test_get_all_datasets_dicts'
    #res_list = obj.get_datasets_list()
    res_list = obj.get_all_datasets_dicts()
    print("\nALL Datasets List:\n", res_list)
    print("\nLEN:", len(res_list))
    assert res_list == pangea_all_datasets_list_response


def test_all_datasets_are_retrieved():
    obj = PANGEA_ParserProfile()

    res_list = obj.get_all_datasets_dicts()
   # print("\nALL Datasets List:\n", res_list)
    print("\nTOTAL PANGEA DS:", len(res_list))
    assert len(res_list) == obj.total_pangea_datasets

def test_is_dataset_deleted_true():
    parser = PANGEA_ParserProfile()

    # Emule harvester response from file
    with open('./ckanext/tibimport/tests/pangea_deleted_dataset.xml', 'r') as file:
        xml_data = file.read()

    xml_tree_data = ElementTree.fromstring(xml_data)
    for record in xml_tree_data.iter(parser.ns0 + 'record'):
        result = parser.is_dataset_deleted(record)
    assert result

def test_is_dataset_deleted_false():
    parser = PANGEA_ParserProfile()

    # Emule harvester response from file
    with open('./ckanext/tibimport/tests/pangea_dataset.xml', 'r') as file:
        xml_data = file.read()

    xml_tree_data = ElementTree.fromstring(xml_data)
    for record in xml_tree_data.iter(parser.ns0 + 'record'):
        result = parser.is_dataset_deleted(record)
        # just consider firts record
        break
    assert not result

def test_should_be_updated_false():
    obj = PANGEA_ParserProfile()

    local_dataset = ckan_dict_of_imported_dataset
    remote_dataset = pangea_dict_of_imported_dataset

    res = obj.should_be_updated(local_dataset, remote_dataset)

    assert res == False


def test_should_be_updated_true():
    obj = PANGEA_ParserProfile()

    local_dataset = ckan_dict_of_imported_dataset
    remote_dataset = pangea_dict_of_imported_dataset
    remote_dataset['title'] = 'New Title'

    res = obj.should_be_updated(local_dataset, remote_dataset)

    assert res == True

def test_check_current_schema():
    obj = PANGEA_ParserProfile()
    res = obj.check_current_schema()

    print("\nSCHEMA REPORT: ", res)

    assert res['status_ok']

def test_process_all_remote_datasets():

    obj = PANGEA_ParserProfile()
    # process all remote datasets from PANGEA
    obj.get_all_datasets_dicts()

    # Expecting errors in code in case something goes wrong during parsing
    assert True