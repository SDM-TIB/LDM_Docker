# pytest --ckan-ini=test.ini ckanext/ldm_sparql/tests/test_Falcon_Util.py -s

from ckanext.ldm_sparql.Falcon_Util import Falcon_Util
from ckanext.ldm_sparql.tests.Mocks import falcon1_expected_res, falcon2_expected_res

def test_call_falcon1_API():

    falcon_util = Falcon_Util()
    text = "Who painted The Storm on the Sea of Galilee?"

    res = falcon_util.call_to_Falcon1_API(text)

    print("\n\nFalcon 1 RES: ", res)
    assert res == falcon1_expected_res

def test_call_falcon2_API():

    falcon_util = Falcon_Util()
    text = "Who painted The Storm on the Sea of Galilee?"

    res = falcon_util.call_to_Falcon2_API(text)

    print("\n\nFalcon 2 RES: ", res)
    assert res == falcon2_expected_res


def test_get_entity_link_from_result():

    falcon_util = Falcon_Util()
    text = "Who painted The Storm on the Sea of Galilee?"
    res = falcon_util.call_to_Falcon1_API(text)
    e_link = falcon_util.get_entity_link_from_result(res)
    e_link_expected = 'http://dbpedia.org/resource/The_Storm_on_the_Sea_of_Galilee'
    print("\n\nFalcon 1 E_LINK: ", e_link)
    assert e_link == e_link_expected

    text = "Who painted The Storm on the Sea of Galilee?"
    res = falcon_util.call_to_Falcon2_API(text)
    e_link = falcon_util.get_entity_link_from_result(res)
    e_link_expected = 'http://www.wikidata.org/entity/Q2246489'
    print("\n\nFalcon 2 E_LINK: ", e_link)
    assert e_link == e_link_expected

def test_get_wikidata_link_from_keyword():
    falcon_util = Falcon_Util()
    text = "Who painted The Storm on the Sea of Galilee?"
    wd_link = falcon_util.get_wikidata_link_from_keyword(text)
    e_link_expected = 'http://www.wikidata.org/entity/Q2246489'
    assert wd_link == e_link_expected

def test_get_dbpedia_link_from_keyword():
    falcon_util = Falcon_Util()
    text = "Who painted The Storm on the Sea of Galilee?"
    dbp_link = falcon_util.get_dbpedia_link_from_keyword(text)
    e_link_expected = 'http://dbpedia.org/resource/The_Storm_on_the_Sea_of_Galilee'
    assert dbp_link == e_link_expected

def test_get_wikidata_link_from_keyword_NO_RESULT():
    falcon_util = Falcon_Util()
    text = "aa22345"
    wd_link = falcon_util.get_wikidata_link_from_keyword(text)
    e_link_expected = ''
    assert wd_link == e_link_expected

def test_get_dbpedia_link_from_keyword_NO_RESULT():
    falcon_util = Falcon_Util()
    text = "a"
    dbp_link = falcon_util.get_dbpedia_link_from_keyword(text)
    e_link_expected = ''
    assert dbp_link == e_link_expected

