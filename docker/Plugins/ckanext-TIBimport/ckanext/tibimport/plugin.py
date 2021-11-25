from flask import Blueprint
from flask import render_template_string
from flask import render_template
import json

from ckanext.tibimport.logic2 import LUH_CKAN_API_ParserProfile
from ckanext.tibimport.logic2 import LDM_DatasetImport

import ckan.plugins as plugins
import ckan.plugins.toolkit as toolkit
from ckan.common import config
d = toolkit.g


import ckan.model as model

#user_var = d.get("userobj")

# If the user is identified then:
# g.user = user name(unicode)
# g.userobj = user object
# g.author = user name
# otherwise:
# g.user = None
# g.userobj = None
# g.author = user
# <User id=17755db4-395a-4b3b-ac09-e8e3484ca700 name=admin
# password=$pbkdf2-sha512$25000$UurdW.v9H8O4957z3nuPEQ$lT/GEKzo24HZonqFZOlh9vHYPcsJpEEyRmr2Ichys1YU2j7yWbEdso/msnSaLN3bdW7HPBjEjogHiKXKL7qbDg
# fullname=None email=admin@email.com apikey=65d55933-84a8-4739-b5a8-f3d718fd8cca
# created=2017-08-08 16:45:41.109676 reset_key=None about=None activity_streams_email_notifications=False
# sysadmin=True state=active image_url=None plugin_extras=None>


def import_vdatasets():

    user_dict = get_logged_user_data()
    # user_dict = {"display_name": d.userobj.name,
    #              "num_followers": 0,
    #              "number_created_packages": 0,
    #              "name": "admin"}
    if not user_dict['sysadmin']:
        toolkit.abort(404)

    res = ""
    for key in d:
        res = res + key + "=" + str(d.get(key)) + "\n"

    objparser = LUH_CKAN_API_ParserProfile()
    objimporter = LDM_DatasetImport(objparser)

    objimporter.import_datasets()

    summary = objimporter.get_summary_log()

    return toolkit.render(
        'user/read.html',
        extra_vars={
            u'user_data': res,
            u'user_dict': user_dict,
            u'summary_log': summary
        }
    )
#    return render_template('home/index.html', name='hello_plugin')










def helper_not_here():
    u'''A simple template with a helper that doesn't exist. Rendering with a
    helper that doesn't exist causes server error.'''

    html = u'''<!DOCTYPE html>
    <html>
        <head>
            <title>Hello from Flask</title>
        </head>
        <body>Hello World, {{ h.nohere() }} no helper here</body>
    </html>'''

    return render_template_string(html)


def helper_here():
    u'''A simple template with a helper that exists. Rendering with a helper
    shouldn't raise an exception.'''

    html = u'''<!DOCTYPE html>
    <html>
        <head>
            <title>Hello from Flask</title>
        </head>
        <body>Hello World, helper here: {{ h.render_markdown('*hi*') }}</body>
    </html>'''

    return render_template_string(html)


def flask_request():
    u'''A simple template with a helper that exists. Rendering with a helper
    shouldn't raise an exception.'''

    html = u'''<!DOCTYPE html>
    <html>
        <head>
            <title>Hello from Flask</title>
        </head>
        <body> {{ request.params }} </body>
    </html>'''

    return render_template_string(html)


class TibimportPlugin(plugins.SingletonPlugin):
    plugins.implements(plugins.IBlueprint)
    plugins.implements(plugins.IConfigurer)
    # Declare that this plugin will implement ITemplateHelpers.
    plugins.implements(plugins.ITemplateHelpers)

    # IConfigurer

    def update_config(self, config_):
        toolkit.add_template_directory(config_, 'templates')
        toolkit.add_public_directory(config_, 'public')
        toolkit.add_resource('fanstatic', 'tibimport')
        #toolkit.add_ckan_admin_tab(config_, 'tibimport.hello_plugin', 'Import Datasets')



    # IBlueprint

    def get_blueprint(self):
        u'''Return a Flask Blueprint object to be registered by the app.'''

        # Create Blueprint for plugin
        blueprint = Blueprint(self.name, self.__module__)
        blueprint.template_folder = u'templates'
        # Add plugin url rules to Blueprint object
        rules = [
            (u'/user/import_vdatasets', u'import_vdatasets', import_vdatasets),
            (u'/helper_not_here', u'helper_not_here', helper_not_here),
            (u'/helper', u'helper_here', helper_here),
            (u'/flask_request', u'flask_request', flask_request),
        ]
        for rule in rules:
            blueprint.add_url_rule(*rule)

        return blueprint



    def get_helpers(self):
        '''Register the most_popular_groups() function above as a template
        helper function.

        '''
        # Template helper function names should begin with the name of the
        # extension they belong to, to avoid clashing with functions from
        # other extensions.
        return {'tibimport_show_vdatasets_virtual_ribbon': show_vdatasets_virtual_ribbon,
                'tibimport_show_vdatasets_virtual_source_ribbon': show_vdatasets_virtual_source_ribbon
                }

def show_vdatasets_virtual_source_ribbon():
    '''Return the value of the show_vdatasets_virtual_ribbon.
        To enable showing the most popular groups, add this line to the
        [app:main] section of your CKAN config file::

          ckan.show_vdatasets_virtual_ribbon = True
     Returns ``False`` by default, if the setting is not in the config file.
    :rtype: bool
    '''
    value = config.get('tibimport.show_vdatasets_virtual_source_ribbon', False)
    value = toolkit.asbool(value)
    return value

def show_vdatasets_virtual_ribbon():
    '''Return the value of the show_vdatasets_virtual_ribbon.
        To enable showing the most popular groups, add this line to the
        [app:main] section of your CKAN config file::

          ckan.show_vdatasets_virtual_ribbon = True
     Returns ``False`` by default, if the setting is not in the config file.
    :rtype: bool
    '''
    value = config.get('tibimport.show_vdatasets_virtual_ribbon', False)
    value = toolkit.asbool(value)
    return value



def get_logged_user_data():
    try:
        d.userobj.id
    except AttributeError:
        return {"sysadmin":False}

    context = {'model': model,
               'session': model.Session,
               'user': d.user,
               'auth_user_obj': d.userobj}
    data_dict = {'id': d.userobj.id, 'include_num_followers': True}
    user_dict = toolkit.get_action('user_show')(context, data_dict)
    return user_dict