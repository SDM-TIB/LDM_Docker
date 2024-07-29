import ckan.plugins as plugins
import ckan.plugins.toolkit as toolkit
from flask import Blueprint
from ckan.common import config

from ckanext.tibnotify.TIBnotify import LDM_Notify

objnotify = LDM_Notify()

# ROUTES
# ******
def test_render_notification_email():

    summary = {'Repository_name': 'Leibniz University Hannover', 'Datasets_inserted': 0, 'Datasets_updated': 0, 'Datasets_skiped': 140, 'LOG_file': '/usr/lib/ckan/default/src/ckanext-TIBimport/ckanext/tibimport/logs/LUH_2022_09_28_log.log', 'SCHEMA_REPORT': {'status_ok': True, 'report': {'current_metadata': {'dataset_keys': ['author', 'author_email', 'creator_user_id', 'have_copyright', 'id', 'isopen', 'license_id', 'license_title', 'license_url', 'maintainer', 'maintainer_email', 'metadata_created', 'metadata_modified', 'name', 'notes', 'num_resources', 'num_tags', 'organization', 'owner_org', 'private', 'state', 'terms_of_usage', 'title', 'type', 'url', 'version', 'resources', 'tags', 'groups', 'relationships_as_subject', 'relationships_as_object', 'doi', 'doi_status', 'domain', 'doi_date_published', 'doi_publisher', 'repository_name', 'source_metadata_created', 'source_metadata_modified', 'revision_id', 'extras'], 'resource_keys': ['cache_last_updated', 'cache_url', 'created', 'description', 'format', 'hash', 'id', 'last_modified', 'metadata_modified', 'mimetype', 'mimetype_inner', 'name', 'package_id', 'position', 'resource_type', 'size', 'state', 'url', 'url_type', 'downloadall_datapackage_hash', 'downloadall_metadata_modified'], 'resource_types': ['.zip', 'ZIP', '.csv', 'MP4', 'PDF', 'XLSX', 'matlab', 'shape', 'ASCII', 'CSV', 'TXT', 'JSON', 'XML', '', 'python', 'PNG', 'TAR', 'SHP', '.tiff', 'TIFF', 'tar.gz', 'TSV', 'jsonl', 'IAM', 'CLS', 'FRM', 'FRX', 'BAS', 'JPEG', '7z', 'application/x-7z-compressed', 'obj', 'RAR', 'json, pdf, txt', 'CSV, TXT', 'text', 'python code', 'GFC', 'chemical/x-gamess-input', 'py', 'XLS', 'text/markdown', 'video/quicktime', 'avi', '.md', 'Ansys-APDL', 'Turtle']}, 'errors': {'dataset_keys': {'Error': 'None'}, 'resource_keys': {'Error': 'None'}, 'resource_types': {'Warning': 'IAM, CLS, FRM, FRX, BAS, '}}}}}
    summary = {'Repository_name': 'RADAR (Research Data Repository)', 'Datasets_inserted': 0, 'Datasets_updated': 2, 'Datasets_skiped': 226, 'LOG_file': '/usr/lib/ckan/default/src/ckanext-TIBimport/ckanext/tibimport/logs/RDR_2022_09_28_log.log', 'SCHEMA_REPORT': {'status_ok': True, 'report': {'current_metadata': {'current_radar_schema': '{http://www.openarchives.org/OAI/2.0/}', 'current_dataset_schema': '{http://radar-service.eu/schemas/descriptive/radar/v09/radar-dataset}', 'current_dataset_element_schema': '{http://radar-service.eu/schemas/descriptive/radar/v09/radar-elements}'}, 'errors': {}}}}

    extras={'site_url': objnotify.get_site_url(),
            'site_logo_filename': objnotify.get_site_logo_filename(),
            'date_and_time_now': objnotify.get_date_and_time_now(),
            'schema_status_to_txt': objnotify.schema_status_to_txt(summary['SCHEMA_REPORT']['status_ok'])}
    return objnotify.render_template_using_jinja('emails/importation_update_notification_worker.html', summary, extras)



def test_send_email_using_object():
    summary = {'Repository_name': 'RADAR (Research Data Repository)', 'Datasets_inserted': 0, 'Datasets_updated': 2,
               'Datasets_skiped': 226,
               'LOG_file': '/usr/lib/ckan/default/src/ckanext-TIBimport/ckanext/tibimport/logs/RDR_2022_09_28_log99.log',
               'SCHEMA_REPORT': {'status_ok': True, 'report': {
                   'current_metadata': {'current_radar_schema': '{http://www.openarchives.org/OAI/2.0/}',
                                        'current_dataset_schema': '{http://radar-service.eu/schemas/descriptive/radar/v09/radar-dataset}',
                                        'current_dataset_element_schema': '{http://radar-service.eu/schemas/descriptive/radar/v09/radar-elements}'},
                   'errors': {}}}}

    objnotify = LDM_Notify()

    objnotify.send_importation_update_notification(summary)
    sender_email = config.get('TIBnotify.sysadmin_email', 'noreply.ldm@tib.eu')
    receiver_email = config.get('TIBnotify.mail_to', 'notifications@LDM')

    smtp_server = config.get('smtp.server', 'localhost')
    smtp_port = config.get('smtp.port', 25)

    smtp_starttls = ckan.common.asbool(config.get('smtp.starttls'))
    smtp_ssl = ckan.common.asbool(config.get('smtp.ssl', False))
    smtp_user = config.get('smtp.user', '')
    smtp_password = config.get('smtp.password', '')

    info = "<p>Sender Email: " + sender_email + "</p>"
    info += "<p>Reciever Email: " + receiver_email + '</p>'
    info += "<p>SMTP Server: " + smtp_server + '</p>'
    info += "<p>SMTP Port: " + str(smtp_port) + '</p>'
    info += "<p>SSL: " + str(smtp_ssl) + '</p>'
    info += "<p>START TLS: " + str(smtp_ssl) + '</p>'
    info += "<p>USER: " + smtp_user + '</p>'
    info += "<p>PASSWORD: " + smtp_password + '</p>'

    html = '<!DOCTYPE html><html><body><h3>Result:</h3>' + info + '</body></html>'

    return render_template_string(html)

import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.image import MIMEImage
from flask import render_template_string
from logging import getLogger
log = getLogger(__name__)
import ckan.common
from ckan.common import config
def test_send_email():

    sender_email = config.get('TIBnotify.sysadmin_email', 'noreply.ldm@tib.eu')
    receiver_email = config.get('TIBnotify.mail_to', 'notifications@LDM')

    smtp_server = config.get('smtp.server', 'localhost')
    smtp_port = config.get('smtp.port', 25)

    smtp_starttls = ckan.common.asbool(config.get('smtp.starttls'))
    smtp_ssl = ckan.common.asbool(config.get('smtp.ssl', False))
    smtp_user = config.get('smtp.user', '')
    smtp_password = config.get('smtp.password', '')

    msg = MIMEMultipart()
    msg['Subject'] = '[Email Test]'
    msg['From'] = sender_email
    msg['To'] = receiver_email
    msgText = MIMEText('<b>%s</b>' % ('Test email'), 'html')
    msg.attach(msgText)
    error = "None"
    smtpObj = False

    info = "<p>Sender Email: " + sender_email + "</p>"
    info += "<p>Reciever Email: " + receiver_email + '</p>'
    info += "<p>SMTP Server: " + smtp_server + '</p>'
    info += "<p>SMTP Port: " + str(smtp_port) + '</p>'
    info += "<p>SSL: " + str(smtp_ssl) + '</p>'
    info += "<p>START TLS: " + str(smtp_starttls) + '</p>'
    info += "<p>USER: " + smtp_user + '</p>'
    info += "<p>PASSWORD: " + smtp_password + '</p>'

    # CONNECT SMTP SERVER
    try:
        if smtp_ssl:
            smtpObj = smtplib.SMTP_SSL(smtp_server, smtp_port)
        else:
            smtpObj = smtplib.SMTP(smtp_server, smtp_port)
    except Exception as e:
        error = str(e)

    # START TLS
    if smtpObj and smtp_starttls:
        try:
            smtpObj.starttls()
        except Exception as e:
            error = str(e)

    # SEND EMAIL
    try:
        smtpObj.ehlo()

        if smtp_user:
            smtpObj.login(sender_email, smtp_password)

        smtpObj.sendmail(sender_email, receiver_email, msg.as_string())
    except Exception as e:
        error = str(e)

    html = '<!DOCTYPE html><html><body><h3>Result:</h3><p>ERROR:' + error +'</p>'
    html += '<h3>Info:</h3>:' + info +'</body></html>'

    return render_template_string(html)

# HELPERS
# *******

def get_site_url():
    '''Return the value of the ckan.site_url value from CKAN configuration.
    '''
    return objnotify.site_url

def get_site_logo_filename():
    return objnotify.site_logo_filename

def get_date_and_time_now():
    # dd/mm/YY H:M:S
    return objnotify.get_date_and_time_now()

def schema_status_to_txt(status_value):
    return objnotify.schema_status_to_txt(status_value)

def send_importation_update_notification(summary):

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
            (u'/test_render_notification_email', u'test_render_notification_email', test_render_notification_email),
            (u'/test_send_email', u'test_send_email', test_send_email),
            (u'/test_send_email_using_object', u'test_send_email_using_object', test_send_email_using_object),
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