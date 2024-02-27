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
        self.logged_user = None
        self.logged_user_name = ''

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


    # CKAN USERS MANIPULATION
    # ***********************

    def get_local_user(self, user_name):
        # https://docs.ckan.org/en/2.9/api/#ckan.logic.action.get.user_show

        params = {'id': user_name}
        context = {'model': model, 'session': model.Session, 'ignore_auth': True}
        #context['return_id_only'] = False
        #context = {}

        try:
            #self.set_log_info("XXXXXXXX " + str(context) + " ZZZZZZZ" + str(params))
            #toolkit.auth_allow_anonymous_access(self.action_package_show)
            result = self.action_user_show(context, params)
        except NotFound as e:
            return {}
        return result

    def get_local_user_obj_by_email(self, email):
        return User.by_email(email)

    def get_local_user_obj_by_name(self, name):
        return User.get(name)


    def create_user(self, usr_dict):
        # https://docs.ckan.org/en/2.9/api/#ckan.logic.action.create.user_create
        context = {'model': model, 'session': model.Session, 'ignore_auth': True, 'user': 'admin'}

        try:
            self.action_user_create(context, usr_dict)
        except ValidationError as e:
            return {'success': False, 'error': str(e.error_summary)}

        return {'success': True}

    def _gitlab_convert_user_data_to_ckan_dict(self, gitlab_user_data):

        ckan_user_dict = {"name": gitlab_user_data["username"]+'_gitlab',
                          "fullname": gitlab_user_data["name"],
                          "email": gitlab_user_data["email"],
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

    def check_oauth2_logged_in(self, session):

        for profile_name in self.profiles:
            if profile_name == 'gitlab':
                if profile_name + '_token' in session:  # logged in on oauth

                    remote_app = self.get_remote_app(profile_name)
                    user_data_profile = remote_app.get('user').data
                    user_data_ckan = self.convert_user_data_to_ckan_user_dict(profile_name, user_data_profile)

                    user_name = user_data_ckan.get("name", '')
                    user_email = user_data_ckan.get("email", '')

                    # check if user XXX_gitlab exists in LDM
                    user = self.get_local_user(user_name)
                    if user:
                        self.logged_user = user # login with this user
                        self.logged_user_name = user_name
                        return True

                    # else check if user exist with email
                    user = self.get_local_user_obj_by_email(user_email)
                    if user:
                        user_name = user[0].name
                        self.logged_user = self.get_local_user(user_name) # login with this user
                        self.logged_user_name = user_name
                        return True

                    #  else create new user
                    resp = self.create_user(user_data_ckan)
                    if resp['success']:
                        user = self.get_local_user(user_name)
                        self.logged_user = user
                        self.logged_user_name = user_name
                        return True
                    else:
                        self.logged_user = None
                        self.logged_user_name = ''
                        return False

            return False