import ckan.plugins as plugins
import ckan.plugins.toolkit as toolkit
from flask import Blueprint
from ckan.common import config

from datetime import datetime

from ckanext.tibnotify.TIBnotify import LDM_Notify

# ROUTES
# ******
def test_notification_email():

    #objnotify = LDM_Notify()

    #objnotify.send_importation_update_notification('LDM', '')

    summary = {'Repository_name': 'Leibniz University Hannover', 'Datasets_inserted': 0, 'Datasets_updated': 0, 'Datasets_skiped': 140, 'LOG_file': '/usr/lib/ckan/default/src/ckanext-TIBimport/ckanext/tibimport/logs/LUH_2022_09_28_log.log', 'SCHEMA_REPORT': {'status_ok': True, 'report': {'current_metadata': {'dataset_keys': ['author', 'author_email', 'creator_user_id', 'have_copyright', 'id', 'isopen', 'license_id', 'license_title', 'license_url', 'maintainer', 'maintainer_email', 'metadata_created', 'metadata_modified', 'name', 'notes', 'num_resources', 'num_tags', 'organization', 'owner_org', 'private', 'state', 'terms_of_usage', 'title', 'type', 'url', 'version', 'resources', 'tags', 'groups', 'relationships_as_subject', 'relationships_as_object', 'doi', 'doi_status', 'domain', 'doi_date_published', 'doi_publisher', 'repository_name', 'source_metadata_created', 'source_metadata_modified', 'revision_id', 'extras'], 'resource_keys': ['cache_last_updated', 'cache_url', 'created', 'description', 'format', 'hash', 'id', 'last_modified', 'metadata_modified', 'mimetype', 'mimetype_inner', 'name', 'package_id', 'position', 'resource_type', 'size', 'state', 'url', 'url_type', 'downloadall_datapackage_hash', 'downloadall_metadata_modified'], 'resource_types': ['.zip', 'ZIP', '.csv', 'MP4', 'PDF', 'XLSX', 'matlab', 'shape', 'ASCII', 'CSV', 'TXT', 'JSON', 'XML', '', 'python', 'PNG', 'TAR', 'SHP', '.tiff', 'TIFF', 'tar.gz', 'TSV', 'jsonl', 'IAM', 'CLS', 'FRM', 'FRX', 'BAS', 'JPEG', '7z', 'application/x-7z-compressed', 'obj', 'RAR', 'json, pdf, txt', 'CSV, TXT', 'text', 'python code', 'GFC', 'chemical/x-gamess-input', 'py', 'XLS', 'text/markdown', 'video/quicktime', 'avi', '.md', 'Ansys-APDL', 'Turtle']}, 'errors': {'dataset_keys': {'Error': 'None'}, 'resource_keys': {'Error': 'None'}, 'resource_types': {'Warning': 'IAM, CLS, FRM, FRX, BAS, '}}}}}
    summary = {'Repository_name': 'RADAR (Research Data Repository)', 'Datasets_inserted': 0, 'Datasets_updated': 2, 'Datasets_skiped': 226, 'LOG_file': '/usr/lib/ckan/default/src/ckanext-TIBimport/ckanext/tibimport/logs/RDR_2022_09_28_log.log', 'SCHEMA_REPORT': {'status_ok': True, 'report': {'current_metadata': {'current_radar_schema': '{http://www.openarchives.org/OAI/2.0/}', 'current_dataset_schema': '{http://radar-service.eu/schemas/descriptive/radar/v09/radar-dataset}', 'current_dataset_element_schema': '{http://radar-service.eu/schemas/descriptive/radar/v09/radar-elements}'}, 'errors': {}}}}
    return toolkit.render(
        'emails/email_base.html',
        extra_vars={
           u'summary': summary
        }
    )

# HELPERS
# *******

def get_site_url():
    '''Return the value of the ckan.site_url value from CKAN configuration.
    '''
    return config.get('ckan.site_url')

def get_date_and_time_now():
    # dd/mm/YY H:M:S
    return datetime.now().strftime("%d/%m/%Y %H:%M:%S")

def schema_status_to_txt(status_value):
    if status_value:
        return "OK"
    return "ERROR"

def send_importation_update_notification(summary):

    objnotify = LDM_Notify()
    objnotify.send_importation_update_notification(summary)

class TibnotifyPlugin(plugins.SingletonPlugin):
    plugins.implements(plugins.IBlueprint)
    plugins.implements(plugins.IConfigurer)
    plugins.implements(plugins.ITemplateHelpers)

    # IConfigurer

    def update_config(self, config_):
        toolkit.add_template_directory(config_, 'templates')
        toolkit.add_public_directory(config_, 'public')
        toolkit.add_resource('fanstatic',
            'tibnotify')
        objnotify = LDM_Notify()
        objnotify.enable_ckan_notification_system()



    # IBlueprint

    def get_blueprint(self):
        u'''Return a Flask Blueprint object to be registered by the app.'''

        # Create Blueprint for plugin
        blueprint = Blueprint(self.name, self.__module__)
        blueprint.template_folder = u'templates'
        # Add plugin url rules to Blueprint object
        rules = [
            (u'/test_notification_email', u'test_notification_email', test_notification_email)
        ]
        for rule in rules:
            blueprint.add_url_rule(*rule)

        return blueprint

    def get_helpers(self):
        '''Register the show_object_icon_in_package_item() function above as a template
        helper function.

        '''
        # Template helper function names should begin with the name of the
        # extension they belong to, to avoid clashing with functions from
        # other extensions.
        return {'tibnotify_get_site_url': get_site_url,
                'tibnotify_get_date_and_time_now': get_date_and_time_now,
                'tibnotify_schema_status_to_txt': schema_status_to_txt,
                'tibnotify_send_importation_update_notification': send_importation_update_notification
                }