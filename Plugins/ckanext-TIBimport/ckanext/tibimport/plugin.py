from flask import Blueprint
from flask import render_template_string
from flask import render_template

from ckanext.tibimport.LUH_CKAN_API_ParserProfile import LUH_CKAN_API_ParserProfile
from ckanext.tibimport.RADAR_ParserProfile import RADAR_ParserProfile
from ckanext.tibimport.PANGEA_ParserProfile import PANGEA_ParserProfile
from ckanext.tibimport.LEOPARD_ParserProfile import leoPARD_ParserProfile
from ckanext.tibimport.OSNADATA_ParserProfile import OSNADATA_ParserProfile
from ckanext.tibimport.GOETTINGEN_ParserProfile import GOETTINGEN_ParserProfile
from ckanext.tibimport.LEUPHANA_ParserProfile import LEUPHANA_ParserProfile

from ckanext.tibimport.logic2 import LDM_DatasetImport

import ckan.plugins as plugins
import ckan.plugins.toolkit as toolkit
from ckan.common import config
d = toolkit.g

from logging import getLogger
log = getLogger(__name__)

import ckan.model as model

pangaea_allowed_types = {"chemistry": "topicChemistry",
                         "lithosphere": "topicLithosphere",
                         "atmosphere": "topicAtmosphere",
                         "biologicalclassification": "topicBiologicalClassification",
                         "paleontology": "topicPaleontology",
                         "oceans": "topicOceans",
                         "ecology": "topicEcology",
                         "landsurface": "topicLandSurface",
                         "biosphere": "topicBiosphere",
                         "geophysics": "topicGeophysics",
                         "cryosphere": "topicCryosphere",
                         "lakesrivers": "topicLakesRivers",
                         "humandimensions": "topicHumanDimensions",
                         "fisheries": "topicFisheries",
                         "agriculture": "topicAgriculture"}
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

def import_vdatasets_png(_type):
    summary = _type

    if _type and _type.lower() in pangaea_allowed_types:
        objparser = PANGEA_ParserProfile(pangaea_allowed_types[_type.lower()])
        objimporter = LDM_DatasetImport(objparser)

        objimporter.import_datasets_paged()

        summary = objimporter.get_summary_log()

        send_importation_update_notification(summary)

    # return toolkit.render(
    #     'importer_result.html',
    #     extra_vars={
    #        u'summary_log': summary
    #     }
    # )
    html = u'''<!DOCTYPE html>
        <html>
            <head>
                <title>Adding importation to worker</title>
            </head>
            <body><h1>Adding importation from '''+_type+'''</h1>
            <p>'''+str(summary)+'''
            </p>
            </body>
        </html>'''

    return render_template_string(html)

def import_vdatasets_rdr():

    objparser = RADAR_ParserProfile()
    objimporter = LDM_DatasetImport(objparser)

    objimporter.import_datasets_paged()

    summary = objimporter.get_summary_log()

    send_importation_update_notification(summary)

    return toolkit.render(
        'importer_result.html',
        extra_vars={
           u'summary_log': summary
        }
    )

def import_vdatasets_leo():

    objparser = leoPARD_ParserProfile()
    objimporter = LDM_DatasetImport(objparser)

    objimporter.import_datasets_paged()

    summary = objimporter.get_summary_log()

    send_importation_update_notification(summary)

    return toolkit.render(
        'importer_result.html',
        extra_vars={
           u'summary_log': summary
        }
    )

def import_vdatasets_osn():

    objparser = OSNADATA_ParserProfile()
    objimporter = LDM_DatasetImport(objparser)

    objimporter.import_datasets_paged()

    summary = objimporter.get_summary_log()

    send_importation_update_notification(summary)

    return toolkit.render(
        'importer_result.html',
        extra_vars={
           u'summary_log': summary
        }
    )

def import_vdatasets_goe():

    objparser = GOETTINGEN_ParserProfile()
    objimporter = LDM_DatasetImport(objparser)

    objimporter.import_datasets_paged()

    summary = objimporter.get_summary_log()

    send_importation_update_notification(summary)

    return toolkit.render(
        'importer_result.html',
        extra_vars={
           u'summary_log': summary
        }
    )

def import_vdatasets_leu():

    objparser = LEUPHANA_ParserProfile()
    objimporter = LDM_DatasetImport(objparser)

    objimporter.import_datasets_paged()

    summary = objimporter.get_summary_log()

    send_importation_update_notification(summary)

    return toolkit.render(
        'importer_result.html',
        extra_vars={
           u'summary_log': summary
        }
    )

import functools
def import_vdatasets_luh():

    # user_dict = get_logged_user_data()
    # # user_dict = {"display_name": d.userobj.name,
    # #              "num_followers": 0,
    # #              "number_created_packages": 0,
    # #              "name": "admin"}
    # if not user_dict['sysadmin']:
    #     toolkit.abort(404)
    #
    # res = ""
    # for key in d:
    #     res = res + key + "=" + str(d.get(key)) + "\n"

    objparser = LUH_CKAN_API_ParserProfile()
    objimporter = LDM_DatasetImport(objparser)

    objimporter.import_datasets()

    summary = objimporter.get_summary_log()

    send_importation_update_notification(summary)

    return toolkit.render(
        'importer_result.html',
        extra_vars={
           u'summary_log': summary
        }
    )
#    return render_template('home/index.html', name='hello_plugin')

def TIB_update_imported_datasets_luh():
    objparser = LUH_CKAN_API_ParserProfile()
    objimporter = LDM_DatasetImport(objparser)
    objimporter.import_datasets()
    summary = objimporter.get_summary_log()
    send_importation_update_notification(summary)

def TIB_update_imported_datasets_radar():
    objparser = RADAR_ParserProfile()
    objimporter = LDM_DatasetImport(objparser)
    objimporter.import_datasets()
    summary = objimporter.get_summary_log()
    send_importation_update_notification(summary)

def TIB_update_imported_datasets_pangea_agriculture():
    objparser = PANGEA_ParserProfile()
    objimporter = LDM_DatasetImport(objparser)
    objimporter.import_datasets_paged()
    summary = objimporter.get_summary_log()
    send_importation_update_notification(summary)

def TIB_update_imported_datasets_pangea_chemistry():
    objparser = PANGEA_ParserProfile("topicChemistry")
    objimporter = LDM_DatasetImport(objparser)
    objimporter.import_datasets_paged()
    summary = objimporter.get_summary_log()
    send_importation_update_notification(summary)

def TIB_update_imported_datasets_pangea_lithosphere():
    objparser = PANGEA_ParserProfile("topicLithosphere")
    objimporter = LDM_DatasetImport(objparser)
    objimporter.import_datasets_paged()
    summary = objimporter.get_summary_log()
    send_importation_update_notification(summary)

def TIB_update_imported_datasets_pangea_atmosphere():
    objparser = PANGEA_ParserProfile("topicAtmosphere")
    objimporter = LDM_DatasetImport(objparser)
    objimporter.import_datasets_paged()
    summary = objimporter.get_summary_log()
    send_importation_update_notification(summary)

def TIB_update_imported_datasets_pangea_biologicalclassification():
    objparser = PANGEA_ParserProfile("topicBiologicalClassification")
    objimporter = LDM_DatasetImport(objparser)
    objimporter.import_datasets_paged()
    summary = objimporter.get_summary_log()
    send_importation_update_notification(summary)

def TIB_update_imported_datasets_pangea_paleontology():
    objparser = PANGEA_ParserProfile("topicPaleontology")
    objimporter = LDM_DatasetImport(objparser)
    objimporter.import_datasets_paged()
    summary = objimporter.get_summary_log()
    send_importation_update_notification(summary)

def TIB_update_imported_datasets_pangea_oceans():
    objparser = PANGEA_ParserProfile("topicOceans")
    objimporter = LDM_DatasetImport(objparser)
    objimporter.import_datasets_paged()
    summary = objimporter.get_summary_log()
    send_importation_update_notification(summary)

def TIB_update_imported_datasets_pangea_ecology():
    objparser = PANGEA_ParserProfile("topicEcology")
    objimporter = LDM_DatasetImport(objparser)
    objimporter.import_datasets_paged()
    summary = objimporter.get_summary_log()
    send_importation_update_notification(summary)

def TIB_update_imported_datasets_pangea_landsurface():
    objparser = PANGEA_ParserProfile("topicLandSurface")
    objimporter = LDM_DatasetImport(objparser)
    objimporter.import_datasets_paged()
    summary = objimporter.get_summary_log()
    send_importation_update_notification(summary)

def TIB_update_imported_datasets_pangea_biosphere():
    objparser = PANGEA_ParserProfile("topicBiosphere")
    objimporter = LDM_DatasetImport(objparser)
    objimporter.import_datasets_paged()
    summary = objimporter.get_summary_log()
    send_importation_update_notification(summary)

def TIB_update_imported_datasets_pangea_geophysics():
    objparser = PANGEA_ParserProfile("topicGeophysics")
    objimporter = LDM_DatasetImport(objparser)
    objimporter.import_datasets_paged()
    summary = objimporter.get_summary_log()
    send_importation_update_notification(summary)

def TIB_update_imported_datasets_pangea_cryosphere():
    objparser = PANGEA_ParserProfile("topicCryosphere")
    objimporter = LDM_DatasetImport(objparser)
    objimporter.import_datasets_paged()
    summary = objimporter.get_summary_log()
    send_importation_update_notification(summary)

def TIB_update_imported_datasets_pangea_lakesandrivers():
    objparser = PANGEA_ParserProfile("topicLakesRivers")
    objimporter = LDM_DatasetImport(objparser)
    objimporter.import_datasets_paged()
    summary = objimporter.get_summary_log()
    send_importation_update_notification(summary)

def TIB_update_imported_datasets_pangea_humandimensions():
    objparser = PANGEA_ParserProfile("topicHumanDimensions")
    objimporter = LDM_DatasetImport(objparser)
    objimporter.import_datasets_paged()
    summary = objimporter.get_summary_log()
    send_importation_update_notification(summary)

def TIB_update_imported_datasets_pangea_fisheries():
    objparser = PANGEA_ParserProfile("topicFisheries")
    objimporter = LDM_DatasetImport(objparser)
    objimporter.import_datasets_paged()
    summary = objimporter.get_summary_log()
    send_importation_update_notification(summary)

def TIB_update_imported_datasets_leopard():
    objparser = leoPARD_ParserProfile()
    objimporter = LDM_DatasetImport(objparser)
    objimporter.import_datasets_paged()
    summary = objimporter.get_summary_log()
    send_importation_update_notification(summary)

def TIB_update_imported_datasets_osnadata():
    objparser = OSNADATA_ParserProfile()
    objimporter = LDM_DatasetImport(objparser)
    objimporter.import_datasets_paged()
    summary = objimporter.get_summary_log()
    send_importation_update_notification(summary)

def TIB_update_imported_datasets_goettingen():
    objparser = GOETTINGEN_ParserProfile()
    objimporter = LDM_DatasetImport(objparser)
    objimporter.import_datasets_paged()
    summary = objimporter.get_summary_log()
    send_importation_update_notification(summary)

def TIB_update_imported_datasets_leuphana():
    objparser = LEUPHANA_ParserProfile()
    objimporter = LDM_DatasetImport(objparser)
    objimporter.import_datasets_paged()
    summary = objimporter.get_summary_log()
    send_importation_update_notification(summary)

# Function adding background jobs
def add_imported_datasets_update(_type):

    msg = _type
    # Create CKAN's background jobs
    objparser = LUH_CKAN_API_ParserProfile()
    objimporter = LDM_DatasetImport(objparser)

    bk_jobs = objimporter.get_background_jobs()

    if _type in bk_jobs: # luh, radar, pangea_agriculture, etc
        toolkit.enqueue_job(eval(bk_jobs[_type]['method']), title=bk_jobs[_type]['title'], queue='tib_ur')
        msg = _type + " update enqueued"

    html = u'''<!DOCTYPE html>
        <html>
            <head>
                <title>Adding importation to worker</title>
            </head>
            <body>Adding importation from '''+msg+'''</body>
        </html>'''

    return render_template_string(html)


def send_importation_update_notification(summary):
    # send_notify_func = toolkit.config.get('pylons.h').get('tibnotify_send_importation_update_notification', None)
    if is_TIBNotify_plugin_enabled():
        try:
            from ckanext.tibnotify.TIBnotify import LDM_Notify
            objnotify = LDM_Notify()
            objnotify.send_importation_update_notification(summary)
            # h.tibnotify_send_importation_update_notification(summary)
        except ImportError as e:
            log.error("Error sending notification Email. TIBnotify plugin not installed."+str(e))


def is_TIBNotify_plugin_enabled():
    plugins = config.get('ckan.plugins', [])
    return 'tibnotify' in plugins

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

# HELPERS
# *******
def tibimport_create_cronjobs():
    # Define importation updates
    #objparser = LUH_CKAN_API_ParserProfile()
    objimporter = LDM_DatasetImport(None)
    objimporter.create_cronjobs()

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

        # Define importation updates
        tibimport_create_cronjobs()



    # IBlueprint

    def get_blueprint(self):
        u'''Return a Flask Blueprint object to be registered by the app.'''

        # Create Blueprint for plugin
        blueprint = Blueprint(self.name, self.__module__)
        blueprint.template_folder = u'templates'
        # Add plugin url rules to Blueprint object
        rules = [
            (u'/import_vdatasets_luh', u'import_vdatasets_luh', import_vdatasets_luh),
            (u'/import_vdatasets_rdr', u'import_vdatasets_rdr', import_vdatasets_rdr),
            (u'/import_vdatasets_leo', u'import_vdatasets_leo', import_vdatasets_leo),
            (u'/import_vdatasets_osn', u'import_vdatasets_osn', import_vdatasets_osn),
            (u'/import_vdatasets_goe', u'import_vdatasets_goe', import_vdatasets_goe),
            (u'/import_vdatasets_leu', u'import_vdatasets_leu', import_vdatasets_leu),
            ('/import_vdatasets_png/<_type>', u'import_vdatasets_png_topic', import_vdatasets_png),
            ('/tib_add_imported_datasets_update/<_type>', u'tib_importation_update', add_imported_datasets_update),
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
                'tibimport_show_vdatasets_virtual_source_ribbon': show_vdatasets_virtual_source_ribbon,
                'tibimport_create_cronjobs': tibimport_create_cronjobs
                }




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