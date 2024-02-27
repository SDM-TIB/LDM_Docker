# pytest --ckan-ini=test.ini ckanext/scheming/tests/TIB/services -s
import pytest
from ckanext.scheming.tib_services import *
from ckanext.scheming.tests.TIB.services.mock_services import no_resource_resp, datasets_for_services_data, expected_interface_data_with_no_datasets_result, expected_interface_data_with_no_services_result, \
services_for_datasets_data, expected_interface_data_with_datasets_result, expected_interface_data_with_services_result

from dateutil.parser import parse as parsedate
from unittest.mock import Mock, patch


# DUMMI TEST
def test_dummy_test():
    assert True

# TEST GET DATASETS FOR SERVICES DATA
# def test_get_local_datasets_for_services_data():
#     res = get_local_datasets_for_services_data(False, 'service_id', ds_list='')
#     print("RESULT DATASETS FOR SERVICES\n",res)
#     assert res == datasets_for_services_data

# TEST GET DATASETS FOR SERVICES INFO FOR INTERFACE
def test_get_local_datasets_for_services():
    # Test with NO data
    with patch("ckanext.scheming.tib_services.get_local_datasets_for_services_data") as get_data_fn:
        get_data_fn.return_value = {}
        res = get_local_datasets_for_services(False, 'service_id', ds_list='')
        #print("RESULT DATASETS FOR SERVICE INFO FOR INTERFACE NO DATA\n", res)
        assert res == expected_interface_data_with_no_datasets_result
        get_data_fn.return_value = datasets_for_services_data
        res = get_local_datasets_for_services(False, 'service_id', ds_list='')
        #print("RESULT DATASETS FOR SERVICE INFO FOR INTERFACE\n", res)
        assert res == expected_interface_data_with_datasets_result

# TEST GET SERVICES FOR DATASETS DATA
# def test_get_local_services_for_datasets_data():
#     res = get_local_services_for_datasets_data(False, 'service_id', serv_list='')
#     print("RESULT SERVICES FOR DATASETS\n",res)
#     assert res == datasets_for_services_data

# TEST GET SERVICES FOR DATASETS INFO FOR INTERFACE
def test_get_local_services_for_datasets():
    # Test with NO data
    with patch("ckanext.scheming.tib_services.get_local_services_for_datasets_data") as get_data_fn:
        get_data_fn.return_value = {}
        res = get_local_services_for_datasets(False, 'dataset_id', serv_list='')
        #print("RESULT SERVICES FOR DATASETS INFO FOR INTERFACE NO DATA\n", res)
        assert res == expected_interface_data_with_no_services_result
        get_data_fn.return_value = services_for_datasets_data
        res = get_local_services_for_datasets(False, 'dataset_id', serv_list='')
        #print("RESULT SERVICES FOR DATASETS INFO FOR INTERFACE\n", res)
        assert res == expected_interface_data_with_services_result
