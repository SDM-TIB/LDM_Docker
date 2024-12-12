# pytest --ckan-ini=test.ini ckanext/ldm_sparql/tests/test_ORCID_Util.py -s

from ckanext.ldm_sparql.ORCID_Util import ORCID_Util
from ckanext.ldm_sparql.tests.Mocks import orcid_search_strings, orcid_search_options

def test__get_search_options():

    obj = ORCID_Util()
    search_options = obj.search_options
    names = ["", "Juan", "Juan Perez", "Juan Jose Perez", "Juan Jose Perez Moreno", "Juan Jose Leo Perez Moreno"]

    res = []
    for x in range(0,6):
        res.append(obj._get_search_options(names[x]))

    print("\nSEARCH_S:", res)

    assert res == orcid_search_options

def test__get_search_strings():

    obj = ORCID_Util()
    search_options = obj.search_options
    names = ["", "Juan", "Juan Perez", "Juan Jose Perez", "Juan Jose Perez Moreno", "Juan Jose Leo Perez Moreno"]

    res = []
    for x in range(0,6):
        res.append(obj._get_search_strings(names[x]))

    print("\nSEARCH_S:", res)

    assert res == orcid_search_strings

def test_search_orcid_one_result():
    obj = ORCID_Util()
    name = "Brunet Mauricio"
    expected_res = "https://orcid.org/0000-0001-9576-8845"
    res = obj.search_orcid(name)

    #print("\nN:", res)

    assert res == expected_res

def test_search_orcid_many_result():
    obj = ORCID_Util()
    name = "Juan Perez"
    expected_res = "https://orcid.org/0000-0001-9576-8845"
    res = obj.search_orcid(name)

    #print("\nN:", res)

    assert res == ""
def test_search_all_options():
    obj = ORCID_Util()
    names = ["", "Juan", "Mauricio Brunet", "Juan Jose Perez", "Juan Jose Perez Moreno", "Juan Jose Leo Perez Moreno"]

    res = []
    for x in range(0,6):
        res.append(obj.search_orcid(names[x]))

    expected_res = ['', '', 'https://orcid.org/0000-0001-9576-8845', '', '', '']
    print("\nRESULTS:", res)

    assert res == expected_res



