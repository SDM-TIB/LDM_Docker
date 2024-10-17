import logging
from ckan.plugins import toolkit
from ckan.common import config
from flask_oauthlib.client import OAuth
from flask import session
import secrets
import string
import re
import ckan.lib.helpers as h
import hashlib
import os



log = logging.getLogger(__name__)

class LDMoauth2Controller:
    def __init__(self):
        self.site_url = config.get("ckan.site_url", 'http://localhost:5000')+config.get("ckan.post_url", 'http://localhost:5000')
        self.oauth = OAuth()
        self.profiles = self._get_oauth2_profiles()

    def _get_oauth2_profiles(self):
        profiles = {}

        # GITLAB
        gitlab_profile = {
            "base_url": config.get("LDMoauth2.gitlab.base_url", 'https://gitlab.com/api/v4/'),
            "request_token_url": None,
            "access_token_url": config.get("LDMoauth2.gitlab.access_token_url", 'https://gitlab.com/oauth/token'),
            "authorize_url": config.get("LDMoauth2.gitlab.authorize_url", 'https://gitlab.com/oauth/authorize'),
            "consumer_key": config.get("LDMoauth2.gitlab.consumer_key", ''),
            "consumer_secret": config.get("LDMoauth2.gitlab.consumer_secret", ''),
            "request_token_params": {'scope': config.get("LDMoauth2.gitlab.scope", 'read_user')}
        }
        profiles['gitlab'] = gitlab_profile

        gitlab_remote_app = self.oauth.remote_app('gitlab', **gitlab_profile)

        @gitlab_remote_app.tokengetter
        def get_gitlab_oauth_token():
            return session.get('gitlab_token')

        profiles['gitlab']['remote_app'] = gitlab_remote_app
        profiles['gitlab']['callback_url'] = self.site_url + 'oauth2/callback/gitlab'

        return profiles

    def get_remote_app(self, profile_name):
        return self.profiles.get(profile_name, {}).get('remote_app')

    def get_callback_url(self, profile_name):
        return self.profiles.get(profile_name, {}).get('callback_url', '')

    def convert_user_data_to_ckan_user_dict(self, profile_name, user_data):
        if profile_name == 'gitlab':
            return self._gitlab_convert_user_data_to_ckan_dict(user_data)
        # Add other profile conversions here if needed
        return {}

    

    import hashlib

    def _gitlab_convert_user_data_to_ckan_dict(self, gitlab_user_data):
        # Generate a valid CKAN username
        username = self._generate_valid_username(gitlab_user_data["username"])
        
        user_dict = {
            "name": username,
            "fullname": gitlab_user_data["name"],
            "email": gitlab_user_data["email"],
            "password": self._generate_password(),
            "image_url": None,  # Default to None if no valid image URL is provided
        }

        # Process the avatar URL
        avatar_url = gitlab_user_data.get("avatar_url")
        if avatar_url and self._is_valid_url(avatar_url):
            # Only use the GitLab avatar URL if it's not from Gravatar
            if 'gravatar.com' not in avatar_url:
                user_dict["image_url"] = avatar_url

        return user_dict






    def _generate_valid_username(self, original_username):
        # Convert to lowercase and replace invalid characters with underscores
        valid_username = re.sub(r'[^a-z0-9_-]', '_', original_username.lower())
        
        # Ensure the username starts with a letter
        if not valid_username[0].isalpha():
            valid_username = 'user_' + valid_username

        # Truncate if longer than 100 characters (CKAN's limit)
        if len(valid_username) > 100:
            valid_username = valid_username[:100]

        return valid_username

    def _is_valid_url(self, url):
        # Basic URL validation
        url_pattern = re.compile(
            r'^https?://'  # http:// or https://
            r'(?:(?:[A-Z0-9](?:[A-Z0-9-]{0,61}[A-Z0-9])?\.)+[A-Z]{2,6}\.?|'  # domain...
            r'localhost|'  # localhost...
            r'\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})'  # ...or ip
            r'(?::\d+)?'  # optional port
            r'(?:/?|[/?]\S+)$', re.IGNORECASE)
        return url_pattern.match(url) is not None

    def _generate_password(self, length=16):
        alphabet = string.ascii_letters + string.digits + string.punctuation
        password = ''.join(secrets.choice(alphabet) for i in range(length))
        return password