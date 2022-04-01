# pytest --ckan-ini=test.ini ckanext/scheming/tests/TIB/resource_autoupdate -s
import pytest
from ckanext.scheming.tib_resource_autoupdate import TIB_resource_update_tool
from ckanext.scheming.tests.TIB.resource_autoupdate.mock_resource_autoupdate import no_resource_resp, daily_resource_resp, weekly_resource_resp, monthly_resource_resp, file_request_header

from dateutil.parser import parse as parsedate
from unittest.mock import Mock, patch


# DUMMI TEST
def test_dummy_test():
    assert True

# TEST GET RESOURCES FOR UPDATE
def test_get_resources_to_update_daily():
    TIB_RU_tool = TIB_resource_update_tool()
    resources = TIB_RU_tool.get_resources_to_update('daily')
    print("\nRESOURCES Daily:\n"+str(resources))
    resources = TIB_RU_tool.get_resources_to_update('weekly')
    print("\nRESOURCES Weekly:\n"+str(resources))
    resources = TIB_RU_tool.get_resources_to_update('monthly')
    print("\nRESOURCES Monthly:\n"+str(resources))

    assert True

# TEST BUILD THE FILE PATH
def test__build_resource_file_path_OK():
    res_dict = dict(daily_resource_resp['results'][0])
    TIB_RU_tool = TIB_resource_update_tool()
    file_path = TIB_RU_tool._build_resource_file_path(res_dict)
    expected_path = "/var/lib/ckan/resources/d38/595/e6-1d41-42f7-a814-0317ca79172b"
    print("FILE PATH: ", file_path)

    assert expected_path==file_path

def test__build_resource_file_path_NO_upload():
    res_dict = dict(daily_resource_resp['results'][0])
    res_dict['url_type']=""
    TIB_RU_tool = TIB_resource_update_tool()
    file_path = TIB_RU_tool._build_resource_file_path(res_dict)
    expected_path = ""
    print("FILE PATH: ", file_path)

    assert expected_path==file_path



def test__get_url_resource_last_modified():
    # OK
    TIB_RU_tool = TIB_resource_update_tool()
    url_last = TIB_RU_tool._get_url_resource_last_modified(file_request_header)
    expected_url_last = parsedate("2008-06-02 17:30:33+02:00").astimezone()
    print("URL MODIFIED: ",url_last)
    assert url_last==expected_url_last
    # HEADER VALUE NOT PRESENT
    file_request_header_NO = file_request_header
    file_request_header_NO.pop("Last-Modified")
    expected_url_last = ""
    url_last = TIB_RU_tool._get_url_resource_last_modified(file_request_header)
    assert url_last == expected_url_last

def test__get_resource_file_last_modified():
    # OK
    file = "./ckanext/scheming/tests/TIB/resource_autoupdate/resource_update_daily.txt"
    TIB_RU_tool = TIB_resource_update_tool()
    file_last = TIB_RU_tool._get_resource_file_last_modified(file)
    expected_file_last = parsedate("2022-02-21 10:00:35.391092+01:00").astimezone()
    print("FILE MODIFIED: ", file_last)
    assert file_last == expected_file_last
    # FILE NOT FOUND
    file = "./ckanext/scheming/tests/TIB/resource_autoupdate/resource_update_daily_bad.txt"
    file_last = TIB_RU_tool._get_resource_file_last_modified(file)
    expected_file_last = ""
    assert file_last == expected_file_last

# TEST _open_url
def test__open_url_OK():
    TIB_RU_tool = TIB_resource_update_tool()
#     with patch('ckanext.scheming.tib_resource_autoupdate.requests.get') as mock_get:
#         # Configure the mock to return a response with an OK status code
#         mock_get.return_value.ok = True
# #        mock_get.return_value.json.return_value = json.loads('{"prop": "value"}')
# #        mock_get.return_value.text.return_value = "some response"
#         mock_get.return_value.status_code = 200
    # valid URL
    result = TIB_RU_tool._open_url("http://www.google.com")
    print("REQUEST STATUS: ", result.status_code)
    assert result.status_code==200

def test__open_url_ERROR():
    TIB_RU_tool = TIB_resource_update_tool()
    result = TIB_RU_tool._open_url("bad.url.is.mocked")
    print("REQUEST STATUS2: ", result)
    assert result == False

# NEXT will fail due to user logged issue.
# Could be used to check the logs until update in DB of the resource
import ckan.plugins.toolkit as toolkit
def test__update_resource():
    TIB_RU_tool = TIB_resource_update_tool()
    print("TESTING UPDATE")
    #print(daily_resource_resp['results'][0])
    act = toolkit.get_action('package_search')
    toolkit.auth_allow_anonymous_access(act)
    TIB_RU_tool._update_resource(dict(daily_resource_resp['results'][0]))
    assert True