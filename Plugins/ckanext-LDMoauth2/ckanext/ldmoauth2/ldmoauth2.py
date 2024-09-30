import logging

from ckan.common import config


from flask_oauthlib.client import OAuth
from flask import session
from ckan.plugins import toolkit
import ckan.model as model
import ckan.logic as logic
import random
import string
from ckan.model import User

NotFound = logic.NotFound
ValidationError = logic.ValidationError

from logging import getLogger
log = getLogger(__name__)

class LDMoauth2Controller:

    def __init__(self, flask_app):
        self.site_url = config.get("ckan.site_url", 'http://localhost:5000')
        self.oauth = OAuth(flask_app)
        self.profiles = self._get_oauth2_profiles()

        # CKAN actions over users
        self.action_user_show = toolkit.get_action('user_show')
        self.action_user_create = toolkit.get_action('user_create')
        self.action_user_delete = toolkit.get_action('user_delete')
        # Allow unauthorized ejecution
        toolkit.auth_allow_anonymous_access(self.action_user_show)
        toolkit.auth_allow_anonymous_access(self.action_user_create)
        toolkit.auth_allow_anonymous_access(self.action_user_delete)

    def _get_oauth2_profiles(self):

        # profile_base = { "name": 'profilename',
        #                  "base_url": '',
        #                  "request_token_url": None,
        #                  "access_token_url": '',
        #                  "authorize_url": '',
        #                  "access_token_method": 'POST',
        #                  "consumer_key": '',
        #                  "consumer_secret": '',
        #                  "scope": ''}

        profiles = {}

        # GITLAB
        gitlab_profile = {
                           "base_url": config.get("LDMoauth2.gitlab.base_url", 'https://gitlab.com/api/v3/'),
                            "request_token_url": None,
                            "access_token_url": config.get("LDMoauth2.gitlab.access_token_url", 'https://gitlab.com/oauth/token'),
                            "authorize_url": config.get("LDMoauth2.gitlab.authorize_url", 'https://gitlab.com/oauth/authorize'),
                            "access_token_method": 'POST',
                            "consumer_key": config.get("LDMoauth2.gitlab.consumer_key", ''),
                            "consumer_secret": config.get("LDMoauth2.gitlab.consumer_secret", ''),
                            "request_token_params": {'scope': config.get("LDMoauth2.gitlab.scope", 'read_user profile email')}
                         }
        profiles['gitlab'] = gitlab_profile

        gitlab_remote_app = self.oauth.remote_app('gitlab', **gitlab_profile)

        @gitlab_remote_app.tokengetter
        def get_gitlab_oauth_token():
            return session.get('gitlab_token')

        profiles['gitlab']['remote_app'] = gitlab_remote_app
        profiles['gitlab']['callback_url'] = self.site_url + '/oauth2/callback/gitlab'
        return profiles

    def get_remote_app(self, profile_name):
        return self.profiles.get(profile_name, '').get('remote_app', None)

    def get_callback_url(self, profile_name):
        return self.profiles.get(profile_name, '').get('callback_url', '')

    def convert_user_data_to_ckan_user_dict(self, profile_name, user_data):
        if profile_name == 'gitlab':
            return self._gitlab_convert_user_data_to_ckan_dict(user_data)

    def create_ckan_user_dict_from_session_data(self, profile_name, session):
        if profile_name == 'gitlab':
            return self._gitlab_create_ckan_user_dict_from_session_data(session)


    # CKAN USERS MANIPULATION
    # ***********************

    def get_local_user(self, user_name):
        # https://docs.ckan.org/en/2.9/api/#ckan.logic.action.get.user_show
        # Logging added to check user retrieval process
        log.debug(f"Attempting to retrieve local user: {user_name}")
        params = {'id': user_name}
        context = {'model': model, 'session': model.Session, 'ignore_auth': True}
        #context['return_id_only'] = False
        #context = {}

        try:
            #self.set_log_info("XXXXXXXX " + str(context) + " ZZZZZZZ" + str(params))
            #toolkit.auth_allow_anonymous_access(self.action_package_show)
            result = self.action_user_show(context, params)
            log.debug(f"Attempting to retrieve local user: {user_name} worked")
        except NotFound as e:
            log.debug(f"Attempting to retrieve local user: {user_name} failed")
            return {}
        return result

    def get_local_user_obj_by_email(self, email):
        log.debug(f"Attempting to retrieve local user by email: {email}")
        return User.by_email(email)

    def get_local_user_obj_by_name(self, name):
        return User.get(name)


    def create_user(self, usr_dict):
        # https://docs.ckan.org/en/2.9/api/#ckan.logic.action.create.user_create
        context = {'model': model, 'session': model.Session, 'ignore_auth': True, 'user': 'admin'}
        log.debug(f"Attempting to create user: {usr_dict}")

        try:
            self.action_user_create(context, usr_dict)
            log.debug("User creation successful")
        except ValidationError as e:
            log.error(f"User creation failed: {e.error_summary}")
            raise
            return {'success': False, 'error': str(e.error_summary)}
        return {'success': True}

    def _gitlab_convert_user_data_to_ckan_dict(self, gitlab_user_data):
        username = gitlab_user_data["username"]+'_gitlab'
        username = username.lower()
        ckan_user_dict = {"name": username,
                          "fullname": gitlab_user_data["name"],
                          "email": gitlab_user_data["email"],
                          "password": self._generate_random_string(12)
                          }
        return ckan_user_dict

    def _gitlab_create_ckan_user_dict_from_session_data(self, gitlab_session):

        ckan_user_dict = {"name": gitlab_session['LDMoa2_user_name'],
                          "fullname": gitlab_session['LDMoa2_user_fullname'],
                          "email": gitlab_session['LDMoa2_user_email'],
                          "password": self._generate_random_string(12)
                              }
        return ckan_user_dict

    def delete_user(self, usr_dict):
        # https://docs.ckan.org/en/2.9/api/#ckan.logic.action.delete.user_delete
        context = {'model': model, 'session': model.Session, 'ignore_auth': True, 'user': 'admin'}
        self.action_user_delete(context, usr_dict)

    def _generate_random_string(self, length):
        # choose from all lowercase letter
        letters = string.ascii_letters
        result_str = ''.join(random.choice(letters) for i in range(length))
        return result_str

    def check_oauth2_logged_in(self, session_data):
        # Logging added to check the login status and user creation process
        log.debug("Checking OAuth2 login status")

        for profile_name in self.profiles:
            if profile_name == 'gitlab':

                user_name = session_data.get('LDMoa2_user_name', '')
                user_email = session_data.get('LDMoa2_user_email', '')
                user_fullname = session_data.get('LDMoa2_user_fullname', '')

                result = {"logged_in": False,
                          "user_name": user_name,
                          "user_email": user_email,
                          "user_fullname": user_fullname
                }

                if profile_name + '_token' in session_data:  # logged in on oauth

                  #  log.debug("ENTRA" + str(session_data['gitlab_token']))
                    # check if user XXX_gitlab exists in LDM
                    user = self.get_local_user(user_name)
                    if user:
                        result['logged_in'] = True
                        return result

                    # else check if user exist with email
                    user = self.get_local_user_obj_by_email(user_email)
                    if user:
                        result['logged_in'] = True
                        result['user_name'] = user[0].name
                        result['user_fullname'] = user[0].fullname
                        return result

                    #  else create new user
                    if user_name and user_email:
                        user_data_ckan = self.create_ckan_user_dict_from_session_data(profile_name, session_data)
                       # log.debug("USER DATA ON CREATION: " + str(user_data_ckan))
                        resp = self.create_user(user_data_ckan)
                       # log.debug("RESP USER CREATION: " + str(resp))

                        if resp['success']:
                            result['logged_in'] = True

                        return result

            return {"logged_in": False}

    def update_session_from_ckan_user_data(self, profile_name, access_token, user_data_ckan, session_data):

        session_data[profile_name + '_token'] = access_token
        session_data['LDMoa2_user_name'] = user_data_ckan['name']
        session_data['LDMoa2_user_fullname'] = user_data_ckan['fullname']
        session_data['LDMoa2_user_email'] = user_data_ckan['email']

        return session_data

    def clean_session_on_logout(self, session_data):
        # delete tokens
        for profile_name in self.profiles:
            p_name = profile_name + '_token'
            if p_name in session_data:
                del session_data[p_name]

        # delete users
        if 'LDMoa2_user_name' in session_data:
            del session_data['LDMoa2_user_name']
        if 'LDMoa2_user_fullname' in session_data:
            del session_data['LDMoa2_user_fullname']
        if 'LDMoa2_user_email' in session_data:
            del session_data['LDMoa2_user_email']

        return session_data
