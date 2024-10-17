import ckan.plugins as plugins
import ckan.plugins.toolkit as toolkit
from flask import Blueprint, redirect, request, session, make_response
from ckan.common import g, config
from ckanext.ldmoauth2.ldmoauth2 import LDMoauth2Controller
import ckan.model as model
import ckan.logic as logic
from ckan.lib import base
import ckan.lib.helpers as h
from flask import current_app

from logging import getLogger
log = getLogger(__name__)

oauth2_helper = LDMoauth2Controller()

def set_repoze_user(user_id):
    '''Set the repoze.who cookie to match a given user_id'''
    if 'repoze.who.plugins' in request.environ:
        rememberer = request.environ['repoze.who.plugins']['friendlyform']
        identity = {'repoze.who.userid': user_id}
        headers = rememberer.remember(request.environ, identity)
        return headers
    return None

def ldmoauth2_login(profile_name):
    remote_app = oauth2_helper.get_remote_app(profile_name)
    log.debug("PF: "+profile_name)
    log.debug("remote_app:"+str(remote_app))
    
    if remote_app is None:
        return base.render('error_page.html', extra_vars={'error_summary': "Error accessing remote app:"+profile_name})

    # Check if already logged in
    dashboard_url = config.get("ckan.site_url", 'http://localhost:5000')+config.get("ckan.post_url", 'http://localhost:5000')+'/dashboard/'
    if g.user:
        return toolkit.redirect_to(dashboard_url)

    return remote_app.authorize(callback=oauth2_helper.get_callback_url(profile_name))

def ldmoauth2_callback(profile_name):
    remote_app = oauth2_helper.get_remote_app(profile_name)
    if remote_app is None:
        return base.render('error_page.html', extra_vars={'error_summary': "Error accessing remote app:"+profile_name})

    resp = remote_app.authorized_response()
    if resp is None or resp.get('access_token') is None:
        error_summary = 'Access denied: reason=%s error=%s' % (
            request.args.get('error', 'Unknown'),
            request.args.get('error_description', 'Unknown')
        )
        return base.render('error_page.html', extra_vars={'error_summary': error_summary})

    # Store token in session
    session[profile_name+'_token'] = (resp['access_token'], '')
    
    try:
        # Get user info from OAuth provider
        user_data = remote_app.get('user').data
        log.debug("User data from OAuth provider: %s", user_data)
        
        # Convert user data to CKAN user dict
        user_dict = oauth2_helper.convert_user_data_to_ckan_user_dict(profile_name, user_data)
        log.debug("Converted user dict: %s", user_dict)
        
        # Check if user exists
        context = {'ignore_auth': True, 'model': model, 'session': model.Session}
        try:
            user = toolkit.get_action('user_show')(context, {'id': user_dict['name']})
            log.info("Existing user found: %s", user['name'])
        except toolkit.ObjectNotFound:
            # Create the user
            log.info("Creating new user: %s", user_dict['name'])
            user = toolkit.get_action('user_create')(context, user_dict)
        
        # Set the repoze.who cookie
        headers = set_repoze_user(user['name'])
        
        # Set user in Flask's global object
        g.user = user['name']
        g.userobj = model.User.by_name(user['name'])
        
        dashboard_url = config.get("ckan.site_url", 'http://localhost:5000')+config.get("ckan.post_url", 'http://localhost:5000')+'/dashboard/'

        # Redirect to user dashboard
        response = make_response(redirect(dashboard_url))
        if headers:
            for header, value in headers:
                response.headers.add(header, value)
        return response

    except Exception as e:
        log.error('Error in OAuth callback: %s', str(e), exc_info=True)
        return base.render('error_page.html', extra_vars={'error_summary': "Error processing OAuth callback: " + str(e)})

def ldmoauth2_logout(profile_name):
    if profile_name+'_token' in session:
        del session[profile_name+'_token']
    return toolkit.redirect_to('user.logout')

class Ldmoauth2Plugin(plugins.SingletonPlugin):
    plugins.implements(plugins.IConfigurer)
    plugins.implements(plugins.IBlueprint)
    plugins.implements(plugins.IAuthenticator, inherit=True)

    # IConfigurer
    def update_config(self, config_):
        toolkit.add_template_directory(config_, 'templates')
        toolkit.add_public_directory(config_, 'public')
        toolkit.add_resource('fanstatic', 'ldmoauth2')

    # IBlueprint
    def get_blueprint(self):
        blueprint = Blueprint(self.name, self.__module__)
        blueprint.template_folder = u'templates'
        
        rules = [
            (u'/oauth2/login/<profile_name>', u'ldmoauth2_login', ldmoauth2_login),
            (u'/oauth2/callback/<profile_name>', u'ldmoauth2_callback', ldmoauth2_callback),
            (u'/oauth2/logout/<profile_name>', u'ldmoauth2_logout', ldmoauth2_logout)
        ]
        for rule in rules:
            blueprint.add_url_rule(*rule)

        return blueprint

    # IAuthenticator
    def identify(self):
        user = getattr(g, 'user', None)
        if user:
            if not isinstance(user, model.User):
                user = model.User.by_name(user)
            g.user = user
            g.userobj = user

    def login(self):
        # This method is called when the login button is clicked
        pass

    def logout(self):
        for profile_name in oauth2_helper.profiles:
            if profile_name+'_token' in session:
                del session[profile_name+'_token']
        g.user = None
        g.userobj = None

    def authenticate(self, environ, identity):
        if not ('repoze.who.identity' in environ or identity):
            return None
        
        user = environ.get('repoze.who.identity', {}).get('repoze.who.userid')
        if user:
            g.user = user
            g.userobj = model.User.by_name(user)

        return user