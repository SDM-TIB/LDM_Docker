# pytest --ckan-ini=test.ini ckanext/ldm_sparql/tests/test_Virtuoso_Util.py -s

from ckanext.ldm_sparql.Virtuoso_Util import Virtuoso_Util
from ckanext.ldm_sparql.tests.Mocks import mocked_package_show_dict

from unittest.mock import Mock, patch

import filecmp
import os

def test__create_load_data_tempfile_one_folder():

    obj = Virtuoso_Util()

    # delete temporal file
    if os.path.exists(obj.load_data_tempfile):
        os.remove(obj.load_data_tempfile)

    sql = obj._get_load_one_folder_sql_command()
    obj._create_load_data_tempfile(sql)

    with open(obj.load_data_tempfile, 'r') as f:
        data_file = f.read()

    print("\nSQL COMMAND OneF: ", sql)
    # delete temporal file
    if os.path.exists(obj.load_data_tempfile):
        os.remove(obj.load_data_tempfile)

    assert data_file == sql

def test__create_load_data_tempfile_all_folders():

    obj = Virtuoso_Util()

    # delete temporal file
    if os.path.exists(obj.load_data_tempfile):
        os.remove(obj.load_data_tempfile)

    sql = obj._get_load_all_folders_sql_command()
    obj._create_load_data_tempfile(sql)

    with open(obj.load_data_tempfile, 'r') as f:
        data_file = f.read()

    print("\nSQL COMMAND AllF: ", sql)
    # delete temporal file
    if os.path.exists(obj.load_data_tempfile):
        os.remove(obj.load_data_tempfile)

    assert data_file == sql


def test__get_isql_load_to_virtuoso_command():

    obj = Virtuoso_Util()
    isql_command = obj._get_isql_load_to_virtuoso_command()

    expected = f"docker exec -i {obj.dockerContainerName} isql -U {obj.virtuosoUser} -P {obj.virtuosoPass} < {obj.load_data_tempfile}"
    print("\nisql command: ", isql_command)

    assert isql_command == expected

def test_execute_sparql_sentence_by_GET_OK():

    # THIS TEST IS FAILING IF THE GRAPH IS EMPTY

    obj = Virtuoso_Util()
    sql = "SELECT * WHERE {?s ?p ?o.}"

    res = obj.execute_sparql_sentence(sql)

    print("\nRESPONSE SQL DATA: ", res)

    assert res

def test_execute_sparql_sentence_by_GET_Conex_ERROR():

    obj = Virtuoso_Util()
    obj.virtuosoGraph = 'xxx'
    sql = "SELECT * WHERE {?s ?p ?o.}"

    res = obj.execute_sparql_sentence(sql)

    #print("\nRESPONSE SQL DATA: ", res)

    assert res == {}

def test_execute_sparql_sentence_by_GET_ERROR_in_SQL():

    obj = Virtuoso_Util()
    sql = "SELECT WHERE {}"

    res = obj.execute_sparql_sentence(sql)

    #print("\nRESPONSE SQL DATA: ", res)

    assert res == {}

def test_execute_sparql_sentence_by_GET_Empty_Result():

    obj = Virtuoso_Util()
    sql = "SELECT * WHERE {?s ?p ?o. FILTER (False)}"

    res = obj.execute_sparql_sentence(sql)

    print("\nRESPONSE SQL DATA: ", res)

    assert res == {}

def test_execute_sparql_sentence_by_POST_OK():

    obj = Virtuoso_Util()
    triples = "<http://demo.openlinksw.com/DAV/home/demo_about.rdf> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://rdfs.org/sioc/ns#User>"

    sql = f"INSERT IN GRAPH <{obj.virtuosoGraph}>"+"{"+triples+"}"
    #sql = "SELECT * FROM <http://localhost:8890/> WHERE {?s ?p ?o.}"
    print("\nINSERT: ", sql)
    res = obj.execute_sparql_sentence(sql, True)

    print("\nRESPONSE POST SQL DATA: ", res)

    assert res

def test_insert_dataset_into_graph():

    obj = Virtuoso_Util()
    ds_name = "example-cad-2"
    # dataset_dict = mocked_package_show_dict
    # dataset_dict = obj.get_LDM_local_dataset(ds_name)
    res = obj.insert_dataset_into_graph(ds_name)

    assert res

# def test_delete_dataset_from_graph():
#     obj = Virtuoso_Util()
#     ds_name = "example-cad-2"
#     res = obj.delete_dataset_from_graph(ds_name)
#
#     print("\nRESORUCE DATA: ", res)
#     assert res['OK']

# def test_update_organization_from_graph():
#     organization = {
#         "id": "54c88c71-bd87-4e73-8440-b909e4c3877b",
#         "name": "newname",
#         "title": "New title",
#         "description": "New Description",
#     }
#     obj = Virtuoso_Util()
#     res = obj.update_organization_in_graph(organization)
#
#     assert res['OK']