# pytest --ckan-ini=test.ini ckanext/ldm_sparql/tests/test_LDM_API_to_DCAT_Harvester.py -s

from ckanext.ldm_sparql.LDM_API_to_DCAT_Harvester import LDM_API_to_DCAT_Harvester
from ckanext.ldm_sparql.RDFizer_Util import RDFizer_Util
# from ckanext.tibimport.logic2 import LDM_DatasetImport
# import pytest
# from LUH_Profile_Mocks import local_organization_data, local_dataset_data, luh_api_package_list_no_results,\
#     luh_api_package_list_with_results, luh_api_package_show_no_results, luh_api_package_show_with_results, \
#     luh_api_organization_show_no_results, luh_api_organization_show_with_results, luh_datasets_and_resources_keys
#
# import sqlalchemy as sa
#
import requests
import json
import os
# from unittest.mock import Mock, patch
# from ckan.plugins import toolkit
#
# skip_test1 = True
# #@pytest.mark.skipif(skip_test1, reason="slows all the work") # put before conditional test to skip
#
#


# TEST LDM API
# ************

# Test remote connections
# ***********************
#self.LDM_api_url_package_list = "https://service.tib.eu/ldmservice/api/3/action/package_list"

def test_ldm_api_package_list_remote():
    harvester = LDM_API_to_DCAT_Harvester()
    response = requests.get(harvester.LDM_api_url_package_list)

    assert response.ok

#self.LDM_api_url_package_show = "https://service.tib.eu/ldmservice/api/3/action/package_show"
def test_ldm_api_package_show_remote():
    harvester = LDM_API_to_DCAT_Harvester()

    response = requests.get(harvester.LDM_api_url_package_list)
    res = json.loads(response.content)
    print(res['result'][0])
    ds_title = res['result'][0]
    data = {'id': ds_title}
    response = requests.post(harvester.LDM_api_url_package_show, data = data)

    print("LDM PACKAGE SHOW:\n", response.content)
    assert response.ok

#self.LDM_api_url_organization_show = "https://service.tib.eu/ldmservice/api/3/action/organization_show"
def test_luh_api_organization_show_remote():
    harvester = LDM_API_to_DCAT_Harvester()

    # get list of dataset
    response = requests.get(harvester.LDM_api_url_package_list)
    res = json.loads(response.content)
    # get data from first listed dataset
    ds_title = res['result'][0]
    data = {'id': ds_title}
    response = requests.post(harvester.LDM_api_url_package_show, data = data)
    # get data from organization
    org_name = json.loads(response.content)['result']['organization']['name']
    response = requests.get(harvester.LDM_api_url_organization_show, params= {'id': org_name})
    print("LDM ORGANIZATION SHOW:\n", response.content)

    assert response.ok


def test_get_datasets_list():
    harvester = LDM_API_to_DCAT_Harvester()

    # get list of dataset
    dataset_list = harvester.get_datasets_list()

    print("LDM DATASETS LIST N:", len(dataset_list), "\n")
    print("LDM DATASETS LIST:\n", dataset_list[0:10])

    assert len(dataset_list)

def test_get_datasets_data():
    harvester = LDM_API_to_DCAT_Harvester()

    # get fist dataset
    dataset_list = harvester.get_datasets_list()
    dataset_one = dataset_list[0]

    print("LDM DATASET ONE NAME:", dataset_one, "\n")

    dataset_data = harvester.get_dataset_data(dataset_one)
    print("LDM DATASETS ONE DATA:\n", dataset_data)

    assert dataset_data['name'] == dataset_one

def test_get_organization():
    harvester = LDM_API_to_DCAT_Harvester()

    # get organization from fist dataset
    dataset_list = harvester.get_datasets_list()
    dataset_one = dataset_list[0]
    dataset_data = harvester.get_dataset_data(dataset_one)
    organization_one = dataset_data['organization']['name']
    organization_data = harvester.get_organization(organization_one)

    print("LDM ORGANIZATION ONE NAME:", organization_one, "\n")
    print("LDM ORGANIZATION ONE DATA:\n", organization_data)

    assert organization_data['name'] == organization_one


def test_preprocess_dataset_dict():
    harvester = LDM_API_to_DCAT_Harvester()
    rdfizer_util = RDFizer_Util()

    dataset_name = "service-example"
    # dataset_name = "dataset-for-service-example"
    dataset_name = "falcon-demo"
    dataset_doi = 'https://doi.org/10.57702/onhcz265'
    dataset_data = harvester.get_dataset_data(dataset_name)
    dataset_data = harvester.preprocess_dataset_dict(dataset_data)

    print("LDM PREPROCESSED DATASET:\n", dataset_data)

    assert dataset_data['resources'][0]['doi'] == dataset_doi



def test_convert_one_dataset_to_DCAT_N3():

    harvester = LDM_API_to_DCAT_Harvester()

    output_folder = "/usr/lib/ckan/default/src/ckanext-LDM_SPARQL/ckanext/ldm_sparql/tests/RDFizer_example/output/LDM_DCAT_N3"
    dataset_name = "service-example"
    output_file = output_folder + '/' + dataset_name + '.nt'

    # delete output file if exists
    if os.path.exists(output_file):
        os.remove(output_file)

    dataset_config = {
        "remove_duplicate": "no",
        "all_in_one_file": "no",
        "name": dataset_name,
        "enrichment": "yes",
        "ordered": "yes",
        "output_format": "n-triples"
    }
    rdfizer_util = RDFizer_Util("test_harvester_mapping_dataset_json.ttl", output_folder, dataset_config)

    # get Dataset Data
    dataset_data = harvester.get_dataset_data(dataset_name)
    dataset_data = harvester.preprocess_dataset_dict(dataset_data)

    # save dataset as file
    rdfizer_util.write_dataset_dict_to_json_file(output_folder+"/temp.json", dataset_data)

    # print('\n', "test_RDFizer_example_dataset_json:")
    # print(" *********************", '\n')
    # print("Config: ", obj.RDFizer_dataset_config, '\n')
    # print("Output: ", obj.RDFizer_output_folder, '\n')
    # print("Mapping: ", obj.RDFizer_mapping_file, '\n')

    rdfizer_util.run_RDFizer()

    # assert true if file was generated by rdfizer
    assert os.path.exists(output_file)

def test_convert_one_dataset_to_DCAT_N3_using_Harvester():

    harvester = LDM_API_to_DCAT_Harvester()

    output_folder = "/usr/lib/ckan/default/src/ckanext-LDM_SPARQL/ckanext/ldm_sparql/tests/RDFizer_example/output/LDM_DCAT_N3"
    dataset_name = "service-example"
    output_file = output_folder + '/' + dataset_name + '.nt'

    # delete output file if exists
    if os.path.exists(output_file):
        os.remove(output_file)

    # get Dataset Data
    dataset_data = harvester.get_dataset_data(dataset_name)

    harvester.convert_dataset_dict_to_DCAT(dataset_data)

    assert os.path.exists(output_file)

# def test_convert_all_datasets_dicts_to_DCAT():
#
#     harvester = LDM_API_to_DCAT_Harvester()
#     harvester.convert_all_datasets_dicts_to_DCAT()













#
# # Test Application logic mocking API responses
# # ********************************************
#
# #self.ckan_api_url_package_list = "https://data.uni-hannover.de/api/3/action/package_list"
# # TEST API package_list - CONNECTION FAILING
# def test_luh_api_package_list_fail():
#
#     with patch('ckanext.tibimport.logic2.requests.get') as mock_get:
#         # Configure the mock to return a response with an OK status code
#         mock_get.return_value.ok = False
#
#         obj = LUH_CKAN_API_ParserProfile()
#         res_dict = obj.get_datasets_list()
#
#     assert res_dict == {}
#
# # TEST API package_list - NO DATA
# def test_luh_api_package_list_no_data():
#
#     with patch('ckanext.tibimport.logic2.requests.get') as mock_get:
#         # Configure the mock to return a response with an OK status code and data
#         mock_get.return_value.ok = True
#         mock_get.return_value.json.return_value = luh_api_package_list_no_results
#
#         obj = LUH_CKAN_API_ParserProfile()
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
#         obj = LUH_CKAN_API_ParserProfile()
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
#         obj = LUH_CKAN_API_ParserProfile()
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
#         obj = LUH_CKAN_API_ParserProfile()
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
#         obj = LUH_CKAN_API_ParserProfile()
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
#         obj = LUH_CKAN_API_ParserProfile()
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
#         obj = LUH_CKAN_API_ParserProfile()
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
#         obj = LUH_CKAN_API_ParserProfile()
#         org_name = "the name is not used here"
#
#         res_dict = obj.get_organization(org_name)
#         print("API response organization_show with results:\n", res_dict)
#
#     assert res_dict == luh_api_organization_show_with_results['result']
#
#
# def test_remote_dataset_schema_updated():
#     obj = LUH_CKAN_API_ParserProfile()
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
#     print("\nLUH actual resource keys:\n", actual_resource_keys)
#
#     assert check_ds_keys and check_rs_keys
#
# def test_check_current_schema():
#     obj = LUH_CKAN_API_ParserProfile()
#     res = obj.check_current_schema()
#
#     print("\nCurrent schema report: ", res)
#
#     assert res['status_ok']
#
# @pytest.mark.skipif(skip_test1, reason="test against API directly - slows all the work")
# def test_get_datasets_list():
#     obj = LUH_CKAN_API_ParserProfile()
#
#     res_dict = obj.get_datasets_list()
# #    print(res_dict)
#     print(len(res_dict))
#     assert bool(res_dict)
#
# @pytest.mark.skipif(skip_test1, reason="test against API directly - slows all the work")
# def test_get_dataset_data():
#     ds_title = "a-generic-gust-definition-and-detection-method-based-on-wavelet-analysis"
#     obj = LUH_CKAN_API_ParserProfile()
#
#     res_dict = obj.get_dataset_data(ds_title)
#     print(res_dict)
#
#     assert ds_title==res_dict['name']
#
# @pytest.mark.skipif(skip_test1, reason="test against API directly - slows all the work")
# def test_get_all_datasets_dicts():
#     obj = LUH_CKAN_API_ParserProfile()
#
#     res_dict = obj.get_all_datasets_dicts()
#     print("Datasets found in LUH:\n", len(res_dict))
#     print("Datasets dictionaries:\n", res_dict[0])
#     assert 'name' in res_dict[0]
#
# @pytest.mark.skipif(skip_test1, reason="test against API directly - slows all the work")
# def test_get_remote_datasets():
#     parser = LUH_CKAN_API_ParserProfile()
#     obj = LDM_DatasetImport(parser)
#
#     datasets_dict = obj.get_remote_datasets()
#     print(len(datasets_dict))
#     assert len(datasets_dict)>0
