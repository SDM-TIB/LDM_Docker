import ckan.plugins as plugins
import ckan.plugins.toolkit as toolkit

from flask import Blueprint, redirect, jsonify, request
from ckan.common import session
from ckan.common import c
from ckanext.ldmoauth2.ldmoauth2 import LDMoauth2Controller
import ckan.lib.helpers as h

from logging import getLogger
log = getLogger(__name__)

oauth2_helper = LDMoauth2Controller(toolkit.g)


# ROUTES
# ******



def ldmoauth2_login(profile_name):

    remote_app = oauth2_helper.get_remote_app(profile_name)
    log.debug("PF: "+profile_name)
    log.debug("remote_app:"+str(remote_app))
    # check remote app
    if remote_app is None:
        return render_error_page("Error accessing remote app:"+profile_name)

    # check if already logged in
    if oauth2_helper.check_oauth2_logged_in(session):
        # redirect to normal login
        return redirect(toolkit.url_for('user.login'))

    # Not logged in oauth -> go to login page
    return remote_app.authorize(callback=oauth2_helper.get_callback_url(profile_name))

def ldmoauth2_callback(profile_name):

    remote_app = oauth2_helper.get_remote_app(profile_name)
    if remote_app is None:
        render_error_page("Error accessing remote app:"+profile_name)

    resp = remote_app.authorized_response()
    if resp is None:
        summary = 'Access denied: reason=%s error=%s' % (
            request.args['error'],
            request.args['error_description']
        )
        return render_error_page(summary)

    # Access allowed
    session[profile_name+'_token'] = (resp['access_token'], '')
    return redirect(toolkit.url_for('user.login'))

def ldmoauth2_logout(profile_name):
    del session[profile_name+'_token']
    return redirect(toolkit.url_for('home.index'))


# end ROUTES

def render_error_page(summary):
    return toolkit.render('oauth2_result.html',
                          extra_vars={u'summary_log': summary})




class Ldmoauth2Plugin(plugins.SingletonPlugin):
    plugins.implements(plugins.IConfigurer)
    plugins.implements(plugins.IBlueprint)
    plugins.implements(plugins.IAuthenticator, inherit=True)

    # IConfigurer

    def update_config(self, config_):
        toolkit.add_template_directory(config_, 'templates')
        toolkit.add_public_directory(config_, 'public')
        toolkit.add_resource('fanstatic',
            'ldmoauth2')

    # IBlueprint

    def get_blueprint(self):
        u'''Return a Flask Blueprint object to be registered by the app.'''

        # Create Blueprint for plugin
        blueprint = Blueprint(self.name, self.__module__)
        blueprint.template_folder = u'templates'
        # Add plugin url rules to Blueprint object

        rules = [(u'/oauth2/login/<profile_name>', u'ldmoauth2_login', ldmoauth2_login),
                 (u'/oauth2/callback/<profile_name>', u'ldmoauth2_callback', ldmoauth2_callback),
                 (u'/oauth2/logout/<profile_name>', u'ldmoauth2_logout', ldmoauth2_logout)

        ]
        for rule in rules:
            blueprint.add_url_rule(*rule)

        return blueprint

    # IAuthenticator
    def login(self):
        # check if is already logged in using oauth2
        if oauth2_helper.check_oauth2_logged_in(session):
            c.user = oauth2_helper.logged_user_name
            c.userobj =  oauth2_helper.logged_user

            return h.redirect_to(controller='dashboard', action='index')
        log.debug("LOGGED USER:"+str(oauth2_helper.logged_user))

    def identify(self):
        if oauth2_helper.logged_user_name:
            c.user = oauth2_helper.logged_user_name


    def logout(self):
        for profile_name in oauth2_helper.profiles:
            token_name = profile_name+'_token'
            if token_name in session:
                del session[token_name]
            log.debug("LOGGING OUT - "+profile_name)
        oauth2_helper.logged_user = None
        oauth2_helper.logged_user_name = ''
