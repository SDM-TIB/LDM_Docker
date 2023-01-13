# pytest --ckan-ini=test.ini ckanext/tibimport/tests/test_RADAR_profile.py -s

from ckanext.tibimport.RADAR_ParserProfile import RADAR_ParserProfile
from ckanext.tibimport.logic2 import LDM_DatasetImport
import pytest

from RADAR_Profile_Mocks import radar_dataset_parsed_to_dict, radar_dataset_parsed_to_ckan_dict, resumption_token_ok, \
    resumption_token_empty, expected_list_of_dict_from_radar, radar_all_datasets_list_response, \
    ckan_dict_of_imported_dataset, radar_dict_of_imported_dataset, local_organization_data, local_dataset_data

import sqlalchemy as sa


import xmltodict
from xml.etree import ElementTree

import pprint

import requests
from requests.models import Response
import json
from unittest.mock import Mock, patch
from ckan.plugins import toolkit

skip_test1 = True
skip_test_DatasetImport = True
#@pytest.mark.skipif(skip_test1, reason="slows all the work") # put before conditional test to skip

#logged_user = "test.ckan.net"


# TEST LDM_DatasetImport
# **********************

# SEARCH ORGANIZATION - NOT FOUND
@pytest.mark.skipif(skip_test_DatasetImport, reason="slows all the work")
def test_search_local_org_not_found():
    parser = RADAR_ParserProfile()
    obj = LDM_DatasetImport(parser)

    org_name = "TEST-3499-944kdf20"
    res_dict = obj.get_local_organization(org_name)
    assert res_dict == {}

# INSERT ORGANIZATION
@pytest.mark.skipif(skip_test_DatasetImport, reason="slows all the work")
def test_insert_local_org():
    parser = RADAR_ParserProfile()
    obj = LDM_DatasetImport(parser)

    org_dict = local_organization_data
    obj.insert_organization(org_dict)

    res_dict = obj.get_local_organization(org_dict['name'])
    print(res_dict)
    assert res_dict['name'] == org_dict['name']

# SEARCH ORGANIZATION - FOUND
@pytest.mark.skipif(skip_test_DatasetImport, reason="slows all the work")
def test_search_local_org_found():
    parser = RADAR_ParserProfile()
    obj = LDM_DatasetImport(parser)

    org_dict = local_organization_data
    res_dict = obj.get_local_organization(org_dict['name'])
    assert res_dict['name'] == org_dict['name']

# SEARCH DATASET NOT FOUND
@pytest.mark.skipif(skip_test_DatasetImport, reason="slows all the work")
def test_search_local_dataset_not_found():
    parser = RADAR_ParserProfile()
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

    parser = RADAR_ParserProfile()
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
    parser = RADAR_ParserProfile()
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

    parser = RADAR_ParserProfile()
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
    parser = RADAR_ParserProfile()
    obj = LDM_DatasetImport(parser)

    ds_dict = local_dataset_data
    obj.delete_dataset(ds_dict['name'])

    res_dict = obj.get_local_dataset(ds_dict['name'])

    assert res_dict['state'] == 'deleted'

# DELETE ORGANIZATION
@pytest.mark.skipif(skip_test_DatasetImport, reason="slows all the work")
def test_delete_local_org(app):
    parser = RADAR_ParserProfile()
    obj = LDM_DatasetImport(parser)

    org_dict = local_organization_data
    obj.delete_organization(org_dict['name'])

    res_dict = obj.get_local_organization(org_dict['name'])

    assert res_dict == {}


# TEST RADAR API
# **************

# Test remote connections
# ***********************
#https://www.radar-service.eu/oai/
#RADAR Harvesting tool docs: https://www.openarchives.org/OAI/openarchivesprotocol.html
def test_radar_harvesting_remote_ok():
    parser = RADAR_ParserProfile()
    url = parser.radar_ListRecords_url+'&from='+parser.radar_from_date+'&until='+parser.radar_until_date+'&metadataPrefix='+parser.radar_metadataPrefix

    response = requests.get(url)

#    print('XML fist page response:', response.content, url)
    assert response.ok


#
# #self.ckan_api_url_package_show = "https://data.uni-hannover.de/api/3/action/package_show"
# def test_luh_api_package_show_remote():
#     parser = RADAR_ParserProfile()
#
#     response = requests.get(parser.ckan_api_url_package_list)
#     res = json.loads(response.content)
#     print(res['result'][0])
#     ds_title = res['result'][0]
#     data = {'id': ds_title}
#     response = requests.post(parser.ckan_api_url_package_show, data = data)
#
#     assert response.ok
#
# #self.ckan_api_url_organization_show = "https://data.uni-hannover.de/api/3/action/organization_show"
# def test_luh_api_organization_show_remote():
#     parser = RADAR_ParserProfile()
#
#     # get list of dataset
#     response = requests.get(parser.ckan_api_url_package_list)
#     res = json.loads(response.content)
#     # get data from first listed dataset
#     ds_title = res['result'][0]
#     data = {'id': ds_title}
#     response = requests.post(parser.ckan_api_url_package_show, data = data)
#     # get data from organization
#     org_name = json.loads(response.content)['result']['organization']['name']
#     response = requests.get(parser.ckan_api_url_organization_show, params= {'id': org_name})
#
#     assert response.ok
#
#
#
# Test Application logic mocking API responses
# ********************************************

def mocked_requests_get(*args, **kwargs):
    response_content = None
    request_url = args[0]
    request_url = request_url.replace('&from=0001-01-01T00:00:00Z&until=9999-12-31T23:59:59Z&metadataPrefix=radar', '')
    response = Response()
    response.status_code = 200

    if request_url == 'test_radar_get_datasets_list_error':
        with open('./ckanext/tibimport/tests/radar_error.xml', 'r') as file:
            xml_data = file.read()
        response_content = xml_data

    elif request_url == 'test_radar_get_datasets_list_ok' or request_url == 'test_get_all_datasets_dicts':
        # Emule harvester response from file
        with open('./ckanext/tibimport/tests/radar_dataset.xml', 'r') as file:
            xml_data = file.read()
        # empty resumption token to avoid endless loop
        xml_data = xml_data.replace(
            '<resumptionToken completeListSize="179">rows=100@@searchMark=10.22000/72@@from=0001-01-01T00:00:00Z'
            '@@total=179@@until=9999-12-31T23:59:59Z@@metadataPrefix=radar</resumptionToken>', '<resumptionToken />')
        response_content = xml_data

    elif request_url == 'test_radar_get_datasets_list_no_response':
        response_content = 'ERROR'
        response.status_code = 404

    response._content = str.encode(response_content)
    return response

# @mock.patch('requests.get', side_effect=mocked_requests_get)
# def test_fetch(self, mock_get):
#      response = requests.get(url='aurl')
#      assert ...





# TEST RADAR get_dataset_list
@patch('ckanext.tibimport.RADAR_ParserProfile.requests.get', side_effect=mocked_requests_get)
def test_radar_get_datasets_list_error(mock_get):

    obj = RADAR_ParserProfile()
    obj.radar_ListRecords_url = 'test_radar_get_datasets_list_error'
    res_dict = obj.get_datasets_list()

       # print("RES DICT:\n", res_dict)
    assert res_dict == []


@patch('ckanext.tibimport.RADAR_ParserProfile.requests.get', side_effect=mocked_requests_get)
def test_radar_get_datasets_list_ok(mock_get):

    # # Emule harvester response from file
    # with open('./ckanext/tibimport/tests/radar_dataset.xml', 'r') as file:
    #     xml_data = file.read()
    # # empty resumption token to avoid endless loop
    # xml_data = xml_data.replace(
    #     '<resumptionToken completeListSize="179">rows=100@@searchMark=10.22000/72@@from=0001-01-01T00:00:00Z'
    #     '@@total=179@@until=9999-12-31T23:59:59Z@@metadataPrefix=radar</resumptionToken>', '<resumptionToken />')

    obj = RADAR_ParserProfile()
    obj.radar_ListRecords_url = 'test_radar_get_datasets_list_ok'
    res_dict = obj.get_datasets_list()

    #print('LIST LENGHT:', len(res_dict))

    assert 3 == len(res_dict)

#    print('DATASETS LIST: ', res_dict)

    assert res_dict == expected_list_of_dict_from_radar

@patch('ckanext.tibimport.RADAR_ParserProfile.requests.get', side_effect=mocked_requests_get)
def test_radar_get_datasets_list_no_response(mock_get):

    # Emule harvester NO response

# with patch('ckanext.tibimport.RADAR_ParserProfile.requests.get') as mock_get2:
#     mock_get2.return_value.ok = False
#     mock_get2.return_value.content = None
    obj = RADAR_ParserProfile()
    obj.radar_ListRecords_url = 'test_radar_get_datasets_list_no_response'

    res_dict = obj.get_datasets_list()

   # print("RES DICT:\n", res_dict)
    assert res_dict == []



    # get all attributes

    # for x in res_dict:
    #  print(x.tag, x.text)

   # print(res_dict.tag)
   # print("Attributes are:", res_dict.attrib)

   # root = res_dict
    # for ch in root:
    #     print(ch.tag, ch.attrib)


    #tags = [elem.tag for elem in root.iter()]
    #print(tags)

    # for record in root.iter('{http://www.openarchives.org/OAI/2.0/}record'):
    #     header = record.getchildren()
    #     ident = header[0].getchildren()
    #     print("id: ", ident[0].text)



    # ds_list = []
    # ns0 = '{http://www.openarchives.org/OAI/2.0/}'
    # for record in root.iter(ns0+'record'):
    #     header = record.find(ns0+'header')
    #     #print(header)
    #     #ident = header.find(ns0+'identifier')
    #
    #     ident = record.find('./'+ns0+'header/'+ns0+'identifier')
    #     #print(ident)
    #     print("id: ", ident.text)
    #     ds_list.append(xmltodict.parse(ElementTree.tostring(header)))
    #
    # print("DS:", ds_list)

   # for record in root.iter(ns0+'record'):
   #      header = list(record)
   #      ident = list(header[0])
   #      print("id: ", ident[0].text)




# for list in res_dict[0].findall('ListRecords'):
    #     print("AAA")
    #     for header in list.findall('header'):
    #         print("XXX", header.find('identifier').text)
    # #print("XX ", res_dict[0].tag)
 #   for elem in res_dict.iter():
 #     print(elem.tag, elem.text)
    #assert res_dict == {}

def test_get_radar_resumption_token_ok():
    obj = RADAR_ParserProfile()

    # Emule harvester response from file
    with open('./ckanext/tibimport/tests/radar_dataset.xml', 'r') as file:
        xml_data = file.read()
    xml_tree_data = ElementTree.fromstring(xml_data)

    resumption_token = obj._get_radar_resumption_token(xml_tree_data)

#    print("RESUMPTION TOKEN: ", resumption_token)

    #tags = [elem.tag for elem in xml_tree_data.iter()]
    #print(tags)

    assert resumption_token == resumption_token_ok

def test_get_radar_resumption_token_empty():
    obj = RADAR_ParserProfile()

    # Emule harvester response from file
    with open('./ckanext/tibimport/tests/radar_dataset.xml', 'r') as file:
        xml_data = file.read()
    # with empty token
    xml_data = xml_data.replace('<resumptionToken completeListSize="179">rows=100@@searchMark=10.22000/72@@from=0001-01-01T00:00:00Z'
                     '@@total=179@@until=9999-12-31T23:59:59Z@@metadataPrefix=radar</resumptionToken>', '<resumptionToken />')

    xml_tree_data = ElementTree.fromstring(xml_data)

    resumption_token = obj._get_radar_resumption_token(xml_tree_data)
 #   print("RESUMPTION TOKEN EMPTY: ", resumption_token)

    assert resumption_token == resumption_token_empty

def test_get_radar_resumption_token_not_present():
    obj = RADAR_ParserProfile()

    # Emule harvester response from file
    with open('./ckanext/tibimport/tests/radar_dataset.xml', 'r') as file:
        xml_data = file.read()
    # with empty token
    xml_data = xml_data.replace('<resumptionToken completeListSize="179">rows=100@@searchMark=10.22000/72@@from=0001-01-01T00:00:00Z'
                     '@@total=179@@until=9999-12-31T23:59:59Z@@metadataPrefix=radar</resumptionToken>', '')

    xml_tree_data = ElementTree.fromstring(xml_data)

    resumption_token = obj._get_radar_resumption_token(xml_tree_data)
   # print("RESUMPTION TOKEN EMPTY: ", resumption_token)

    assert resumption_token == resumption_token_empty


def test_parse_RADAR_XML_RECORD_to_DICT():
    parser = RADAR_ParserProfile()

    # Emule harvester response from file
    with open('./ckanext/tibimport/tests/radar_dataset.xml', 'r') as file:
        xml_data = file.read()

    xml_tree_data = ElementTree.fromstring(xml_data)

    # parse just first record
    ns0 = '{http://www.openarchives.org/OAI/2.0/}'
    for record in xml_tree_data.iter(ns0+'record'):
        res_dict = parser.parse_RADAR_XML_RECORD_to_DICT(record)
        break

    #print('DICT response:', res_dict)

    assert res_dict == radar_dataset_parsed_to_dict


def test_parse_RADAR_RECORD_DICT_to_LDM_CKAN_DICT():
    radar_dict = radar_dataset_parsed_to_dict

    parser = RADAR_ParserProfile()

    res_dict = parser.parse_RADAR_RECORD_DICT_to_LDM_CKAN_DICT(radar_dict)

    print("PARSED DICT: ", res_dict)

    assert res_dict == radar_dataset_parsed_to_ckan_dict


@patch('ckanext.tibimport.RADAR_ParserProfile.requests.get', side_effect=mocked_requests_get)
def test_get_all_datasets_dicts(mock_get):


    obj = RADAR_ParserProfile()
    obj.radar_ListRecords_url = 'test_get_all_datasets_dicts'
    #res_list = obj.get_datasets_list()
    res_list = obj.get_all_datasets_dicts()
    print("\nALL Datasets List:\n", res_list)
    print("\nLEN:", len(res_list))
    assert res_list == radar_all_datasets_list_response


def test_all_datasets_are_retrieved():
    obj = RADAR_ParserProfile()

    res_list = obj.get_all_datasets_dicts()
   # print("\nALL Datasets List:\n", res_list)
    print("\nTOTAL RADAR DS:", len(res_list))
    assert len(res_list) == obj.total_radar_datasets


def test_should_be_updated_false():
    obj = RADAR_ParserProfile()

    local_dataset = ckan_dict_of_imported_dataset
    remote_dataset = radar_dict_of_imported_dataset

    res = obj.should_be_updated(local_dataset, remote_dataset)

    assert res == False


def test_should_be_updated_true():
    obj = RADAR_ParserProfile()

    local_dataset = ckan_dict_of_imported_dataset
    remote_dataset = radar_dict_of_imported_dataset
    remote_dataset['source_metadata_created'] = '2022-09-09T09:06:49Z'

    res = obj.should_be_updated(local_dataset, remote_dataset)

    assert res == True

def test_check_current_schema():
    obj = RADAR_ParserProfile()
    res = obj.check_current_schema()

    print("\nSCHEMA REPORT: ", res)

    assert res['status_ok']

def test_process_all_remote_datasets():

    obj = RADAR_ParserProfile()
    # process all remote datasets from RADAR
    obj.get_all_datasets_dicts()

    # Expecting errors in code in case something goes wrong during parsing
    assert True

# #self.ckan_api_url_package_list = "https://data.uni-hannover.de/api/3/action/package_list"
# # TEST API package_list - CONNECTION FAILING
# def test_luh_api_package_list_fail():
#
#     with patch('ckanext.tibimport.logic2.requests.get') as mock_get:
#         # Configure the mock to return a response with an OK status code
#         mock_get.return_value.ok = False
#
#         obj = RADAR_ParserProfile()
#         res_dict = obj.get_datasets_list()
#
#     assert res_dict == {}
#

# API package_list - NO DATA
# def test_luh_api_package_list_no_data():
#
#     with patch('ckanext.tibimport.logic2.requests.get') as mock_get:
#         # Configure the mock to return a response with an OK status code and data
#         mock_get.return_value.ok = True
#         mock_get.return_value.json.return_value = luh_api_package_list_no_results
#
#         obj = RADAR_ParserProfile()
#
#         res_dict = obj.get_datasets_list()
#         print("API response package_list fail:\n", luh_api_package_list_no_results)
#
#     assert res_dict == {}
#
# # TEST API package_list - RETRIEVING DATA
# def test_luh_api_package_list_ok():
#
#     with patch('ckanext.tibimport.logic2.requests.get') as mock_get:
#         # Configure the mock to return a response with an OK status code and data
#         mock_get.return_value.ok = True
#         mock_get.return_value.json.return_value = luh_api_package_list_with_results
#
#         obj = RADAR_ParserProfile()
#
#         res_dict = obj.get_datasets_list()
#         print("API response package_list with results:\n", res_dict)
#
#     assert res_dict == luh_api_package_list_with_results['result']
#
# #self.ckan_api_url_package_show = "https://data.uni-hannover.de/api/3/action/package_show"
# # TEST API package_show - CONNECTION FAILING
# def test_luh_api_package_show_fail():
#
#     with patch('ckanext.tibimport.logic2.requests.post') as mock_get:
#         # Configure the mock to return a response with an OK status code
#         mock_get.return_value.ok = False
#
#         obj = RADAR_ParserProfile()
#         ds_name = "the name is not used here"
#         res_dict = obj.get_dataset_data(ds_name)
#     assert res_dict == {}
#
# # TEST API package_show - NO DATA
# def test_luh_api_package_show_no_data():
#
#     with patch('ckanext.tibimport.logic2.requests.post') as mock_get:
#         # Configure the mock to return a response with an OK status code and data
#         mock_get.return_value.ok = True
#         mock_get.return_value.json.return_value = luh_api_package_show_no_results
#
#         obj = RADAR_ParserProfile()
#
#         ds_name = "the name is not used here"
#         res_dict = obj.get_dataset_data(ds_name)
#         print("API response package_show fail:\n", luh_api_package_show_no_results)
#
#     assert res_dict == {}
#
# # TEST API package_show - RETRIEVING DATA
# def test_luh_api_package_show_ok():
#
#     with patch('ckanext.tibimport.logic2.requests.post') as mock_get:
#         # Configure the mock to return a response with an OK status code and data
#         mock_get.return_value.ok = True
#         mock_get.return_value.json.return_value = luh_api_package_show_with_results
#
#         obj = RADAR_ParserProfile()
#         ds_name = "the name is not used here"
#
#         res_dict = obj.get_dataset_data(ds_name)
#         print("API response package_show with results:\n", res_dict)
#
#     assert res_dict == luh_api_package_show_with_results['result']
#
# #self.ckan_api_url_organization_show = "https://data.uni-hannover.de/api/3/action/organization_show"
# # TEST API organization_show - CONNECTION FAILING
# def test_luh_api_organization_show_fail():
#
#     with patch('ckanext.tibimport.logic2.requests.get') as mock_get:
#         # Configure the mock to return a response with an OK status code
#         mock_get.return_value.ok = False
#
#         obj = RADAR_ParserProfile()
#         org_name = "the name is not used here"
#
#         res_dict = obj.get_organization(org_name)
#
#     assert res_dict == {}
#
# # TEST API organization_show - NO DATA
# def test_luh_api_organization_show_no_data():
#
#     with patch('ckanext.tibimport.logic2.requests.get') as mock_get:
#         # Configure the mock to return a response with an OK status code and data
#         mock_get.return_value.ok = True
#         mock_get.return_value.json.return_value = luh_api_organization_show_no_results
#
#         obj = RADAR_ParserProfile()
#         org_name = "the name is not used here"
#
#         res_dict = obj.get_organization(org_name)
#         print("API response organization_show fail:\n", luh_api_organization_show_no_results)
#
#     assert res_dict == {}
#
# # TEST API organization_show - RETRIEVING DATA
# def test_luh_api_organization_show_ok():
#
#     with patch('ckanext.tibimport.logic2.requests.get') as mock_get:
#         # Configure the mock to return a response with an OK status code and data
#         mock_get.return_value.ok = True
#         mock_get.return_value.json.return_value = luh_api_organization_show_with_results
#
#         obj = RADAR_ParserProfile()
#         org_name = "the name is not used here"
#
#         res_dict = obj.get_organization(org_name)
#         print("API response organization_show with results:\n", res_dict)
#
#     assert res_dict == luh_api_organization_show_with_results['result']
#
#
# def test_remote_dataset_schema_updated():
#     obj = RADAR_ParserProfile()
#     schema_keys = obj.get_remote_dataset_schema()
#
#     actual_datasets_keys = schema_keys['dataset_keys']
#     actual_resource_keys = schema_keys['resource_keys']
#
#     previous_datasets_keys = luh_datasets_and_resources_keys['dataset_keys']
#     previous_resource_keys = luh_datasets_and_resources_keys['resource_keys']
#
#     check_ds_keys = all(item in actual_datasets_keys for item in previous_datasets_keys)
#     check_rs_keys = all(item in actual_resource_keys for item in previous_resource_keys)
#
#     print("LUH dataset schema:\n", schema_keys)
#     assert check_ds_keys and check_rs_keys
#
# @pytest.mark.skipif(skip_test1, reason="test against API directly - slows all the work")
# def test_get_datasets_list():
#     obj = RADAR_ParserProfile()
#
#     res_dict = obj.get_datasets_list()
# #    print(res_dict)
#     print(len(res_dict))
#     assert bool(res_dict)
#
# @pytest.mark.skipif(skip_test1, reason="test against API directly - slows all the work")
# def test_get_dataset_data():
#     ds_title = "a-generic-gust-definition-and-detection-method-based-on-wavelet-analysis"
#     obj = RADAR_ParserProfile()
#
#     res_dict = obj.get_dataset_data(ds_title)
#     print(res_dict)
#
#     assert ds_title==res_dict['name']
#
# @pytest.mark.skipif(skip_test1, reason="test against API directly - slows all the work")
# def test_get_all_datasets_dicts():
#     obj = RADAR_ParserProfile()
#
#     res_dict = obj.get_all_datasets_dicts()
#     print("Datasets found in LUH:\n", len(res_dict))
#     print("Datasets dictionaries:\n", res_dict[0])
#     assert 'name' in res_dict[0]
#
# @pytest.mark.skipif(skip_test1, reason="test against API directly - slows all the work")
# def test_get_remote_datasets():
#     parser = RADAR_ParserProfile()
#     obj = LDM_DatasetImport(parser, logged_user)
#
#     datasets_dict = obj.get_remote_datasets()
#     print(len(datasets_dict))
#     assert len(datasets_dict)>0

