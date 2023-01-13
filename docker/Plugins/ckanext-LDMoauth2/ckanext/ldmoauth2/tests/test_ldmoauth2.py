# pytest --ckan-ini=test.ini ckanext/ldmoauth2/tests/test_ldmoauth2.py -s

from ckanext.ldmoauth2.ldmoauth2 import LDMoauth2Controller
import ckan.plugins.toolkit as toolkit

import pytest
from ckanext.ldmoauth2.tests.Mock_user_data import gitlab_user_dict, ckan_extracted_user_dict


import sqlalchemy as sa


# TEST USER Manipulation
# **********************

def test_delete_user():
    LDMoauth2 = LDMoauth2Controller(toolkit.g)
    #user_dict = ckan_extracted_user_dict
    #user_dict.pop('password')

    user_dict = {'id': 'test1234_gitlab'}
    print("USER DICT:", user_dict)
    LDMoauth2.delete_user(user_dict)

    res_dict = LDMoauth2.get_local_user('test1234_gitlab')

    assert res_dict['state'] == 'deleted'

def test_search_local_user_not_found():

    # Delete test user from DB
    db_url = toolkit.config['sqlalchemy.url']
    engine = sa.create_engine(db_url)
    result = engine.execute(u"DELETE FROM public.user WHERE name='test1234_gitlab'")

    LDMoauth2 = LDMoauth2Controller(toolkit.g)
    res_dict = LDMoauth2.get_local_user('test1234_gitlab')

    assert res_dict == {}

def test_create_new_user():

    LDMoauth2 = LDMoauth2Controller(toolkit.g)
    res_dict = LDMoauth2.create_user(ckan_extracted_user_dict)

    assert res_dict['success'] == True

def test_create_new_user_fail():

    LDMoauth2 = LDMoauth2Controller(toolkit.g)
    res_dict = LDMoauth2.create_user(ckan_extracted_user_dict)
    print("Creation error", res_dict['error'])

    assert res_dict['success'] == False

def test_search_local_user_found():

    LDMoauth2 = LDMoauth2Controller(toolkit.g)
    res_dict = LDMoauth2.get_local_user('test1234_gitlab')
    print("\nUSER DICT:\n", res_dict)
    assert res_dict['name'] == 'test1234_gitlab'


def test_convert_user_data_to_ckan_user_dict():

    LDMoauth2 = LDMoauth2Controller(toolkit.g)
    res_dict = LDMoauth2.convert_user_data_to_ckan_user_dict('gitlab', gitlab_user_dict)
    res_dict['password'] = ckan_extracted_user_dict['password']
    print("\nCKAN USER DICT:\n", res_dict)
    assert res_dict == ckan_extracted_user_dict

def test_get_local_user_by_email():

    LDMoauth2 = LDMoauth2Controller(toolkit.g)
    res_dict = LDMoauth2.get_local_user_obj_by_email('mauriciobrunet.de@gmail.com')

    print("\nBY EMAIL:\n", res_dict)
    print("\nBY EMAIL:\n", res_dict[0].name)
    assert res_dict

def test_get_local_user_by_name():

    LDMoauth2 = LDMoauth2Controller(toolkit.g)
    res_dict = LDMoauth2.get_local_user_obj_by_name('test1234_gitlab')

    print("\nBY NAME:\n", res_dict)
    assert res_dict

def test_check_oauth2_logged_in():
    ckan_extracted_user_dict = {'name': 'rmbruno_gitlab', 'fullname': 'Mauricio Brunet', 'email': 'test1234@mail.com',
                                'password': '12345678'}