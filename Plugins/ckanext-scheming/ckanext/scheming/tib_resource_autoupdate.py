import logging
from datetime import date

from pathlib import Path
import os
import datetime
import requests
from dateutil.parser import parse as parsedate

from crontab import CronTab
#pip install python-crontab

from flask import Blueprint
import ckan.plugins as plugins
import ckan.plugins.toolkit as toolkit

from ckan.common import config
import ckan.logic as logic
import ckan.model as model

NotFound = logic.NotFound



"""
Helper servind data for the creation of the selectbox in resources 
add/edit formulars.
"""
def get_resource_update_options():
    update_enabled = toolkit.asbool(config.get('scheming_tibupdateresources_enabled', False))
    if update_enabled:
        options = [{'value':'No', 'text': 'No'},
                   {'value': 'Daily', 'text': 'Daily'},
                   {'value': 'Weekly', 'text': 'Weekly'},
                   {'value': 'Monthly', 'text': 'Monthly'}]
    else:
        options = []
    return options


# Functions serving background jobs
def TIB_update_resources_daily():
    TIB_RU_tool = TIB_resource_update_tool()
    TIB_RU_tool.update_daily()

def TIB_update_resources_weekly():
    TIB_RU_tool = TIB_resource_update_tool()
    TIB_RU_tool.update_weekly()

def TIB_update_resources_monthly():
    TIB_RU_tool = TIB_resource_update_tool()
    TIB_RU_tool.update_monthly()

# Function adding background jobs
def add_resource_update(type):

    msg = type
    # Create CKAN's background jobs
    TIB_RU_tool = TIB_resource_update_tool()
    bk_jobs = TIB_RU_tool.get_background_jobs()

    if type in bk_jobs:
        toolkit.enqueue_job(bk_jobs[type]['method'], title=bk_jobs[type]['title'], queue='tib_ur')
        msg = type + " update enqueued"


    return toolkit.render(
        'tibupdate_resource.html',
        extra_vars={
            u'data': {'type': msg},
        }
    )


"""
    Plugin implementing automatic resource updates
"""
class TIBupdateResourcesPlugin(plugins.SingletonPlugin):
    plugins.implements(plugins.IBlueprint)
    # Declare that this plugin will implement ITemplateHelpers.
    plugins.implements(plugins.ITemplateHelpers)

    # IBlueprint

    def get_blueprint(self):
        u'''Return a Flask Blueprint object to be registered by the app.'''

        # Create Blueprint for plugin
        blueprint = Blueprint(self.name, self.__module__)
        blueprint.template_folder = u'templates'
        # Add plugin url rules to Blueprint object
        rules = [
            (u'/tib_resource_update/<type>', u'tib_resource_update', add_resource_update),

        ]
        for rule in rules:
            blueprint.add_url_rule(*rule)

        return blueprint

    # ITemplateHelpers
    def get_helpers(self):
        '''Register the most_popular_groups() function above as a template
        helper function.

        '''
        # Template helper function names should begin with the name of the
        # extension they belong to, to avoid clashing with functions from
        # other extensions.
        return {'tibresourceupdate_get_resource_update_options': get_resource_update_options
                }





"""
    Class implementing automatic resource updates
"""
class TIB_resource_update_tool:

    def __init__(self):
        # paths
        self.root_path = '/usr/lib/ckan/default/src/ckanext-scheming/ckanext/scheming/'
        self.ckan_virtual_env_path = '/usr/lib/ckan/default/bin/'
        self.home_ur = config.get('ckan.site_url', "http://localhost:5000")
        self.logs_folder = 'logs/tib_resource_update/'
        # config
        self.update_enabled = toolkit.asbool(config.get('scheming_tibupdateresources_enabled', False))
        self.local_resource_files_path = config.get('ckan.storage_path', "/var/lib/ckan") + "/resources/"
        self.crontab_user = config.get('scheming_tibupdateresources_crontab_user', "root")
        #self.logged_user = "ckan.admin"
        #self.logged_user = toolkit.g.user
        # Create Scheduled jobs using crontab
        self.config_cronjobs()

        # Create and config logger
        self._config_logger()


    def config_cronjobs(self):
        # ┌───────────── minute(0 - 59)
        # │ ┌───────────── hour(0 - 23)
        # │ │ ┌───────────── day of month(1 - 31)
        # │ │ │ ┌───────────── month(1 - 12)
        # │ │ │ │ ┌───────────── day of week(0 - 6)(Sunday to Saturday;
        # │ │ │ │ │                                       7 is also Sunday on some systems)
        # │ │ │ │ │
        # │ │ │ │ │
        # * * * * *command to execute
        # * any value
        # , value list separator
        # -    range of values
        # / step values Ex: */10 each 10
        # job.setall('2 10 * * *')  10:02 every day
        # list in console: crontab -l

        self.background_jobs = {
                   'daily':
                       {'title': 'update_resource_daily',
                        'method': TIB_update_resources_daily,
                        'comment': "TIB_update_resource_daily",
                        'crontab_commands': [".setall('0 0 * * *')"]},
                   'weekly':
                       {'title': 'update_resource_weekly',
                        'method': TIB_update_resources_weekly,
                        'comment': "TIB_update_resource_weekly",
                        'crontab_commands': [".setall('0 2 * * 1')"]},
                   'monthly':
                       {'title': 'update_resource_monthly',
                        'method': TIB_update_resources_monthly,
                        'comment': "TIB_update_resource_monthly",
                        'crontab_commands': [".setall('0 3 1 * *')"]},
                   }

    def get_background_jobs(self):
        return self.background_jobs


    # def log_something(self):
    #     self.num += 1
    #     time.sleep(5)
    #     self.logger.info("log something"+str(self.num))
    #     time.sleep(5)
    #     self.log_something()


    def create_cronjobs(self):

        cron = CronTab(user=self.crontab_user)
        for job in cron.find_comment('tib_update_resource'):
            cron.remove(job)

        if self.update_enabled:
            command_base = self.ckan_virtual_env_path+'python3 ' + self.root_path + 'run_resource_update.py -t '
            # Define cronjobs
            for key,cronjob in self.background_jobs.items():
                command = command_base + key + " >> " + self.root_path + self.logs_folder + "crontab_log.txt 2>&1"
                job = cron.new(command=command, comment="tib_update_resource")
                job.env['home_path'] = self.home_ur
                for c in cronjob['crontab_commands']:
                    eval('job'+c)


        cron.write()



# METHODS RUNNING THE UPDATES
# ***************************
    def update_daily(self):
        self._update_logger()
        self.logger.info("Making daily resources update ")
        self._make_update_by_type('daily')
        self.add_separator_to_log()

    def update_weekly(self):
        self._update_logger()
        self.logger.info("Making Weekly resources update")
        self._make_update_by_type('weekly')
        self.add_separator_to_log()

    def update_monthly(self):
        self._update_logger()
        self.logger.info("Making monthly resources update")
        self._make_update_by_type('monthly')
        self.add_separator_to_log()

    def _make_update_by_type(self, type):
        resources = self.get_resources_to_update(type)
        if "count" in resources and resources['count'] > 0:
            self.logger.info("Resources (" + type + ") found: " + str(resources['count']))
            for r in resources['results']:
                self._update_resource(r)
        else:
            self.logger.info("Skip update, No "+type+" resources in Database.")

    def get_resources_to_update(self, update_type):
        # http://docs.ckan.org/en/2.9/api/index.html#ckan.logic.action.get.resource_search
        # Response: {'count': 0, 'results': []}
        action = toolkit.get_action('resource_search')
        toolkit.auth_allow_anonymous_access(action)
        params = {'query': "auto_update:"+update_type }
        context = {'model': model,
                   'session': model.Session}
                   #'user': self.logged_user}

        try:
            result = action(context, params)
        except NotFound as e:
            self.logger.error("ERROR Searching for resources in DataBase.")
            return {}
        return result

    def _update_resource(self, res_dict):

        url = res_dict['auto_update_url']
        file_path = self._build_resource_file_path(res_dict)
        temp_file_path = file_path+"_temp"
        self._remove_file(temp_file_path)
        r = self._open_url(url)

        # If remote file was located, local file was located and local file should be updated
        # Download file to temporal file
        self.logger.info("R:"+str(r)+"-URL:"+url+"-file_path:"+file_path)
        if r and file_path:
            must_update = self._check_resource_update(r.headers, file_path)
            if must_update:
                self.logger.info("Start copying file from: "+url)
                with open(temp_file_path, "wb") as temp_file:
                    for chunk in r.iter_content(chunk_size=1024):
                        if chunk:
                            temp_file.write(chunk)
                            temp_file.flush()
                            os.fsync(temp_file.fileno())
                temp_file.close()
                # Replace original with downloaded file
                if os.path.isfile(temp_file_path):
                    self._remove_file(file_path)
                    os.rename(temp_file_path, file_path)
                    self.logger.info("Replaced file: "+file_path)
                    self.set_last_update_date(res_dict)
            else:
                # In case update was skiped by date change 'last update time' metadata
                self.set_last_update_date(res_dict)


    def _remove_file(self, file_path):
        if os.path.isfile(file_path):
            os.remove(file_path)

    def _open_url(self, url):
        #r = False
        try:
            r = requests.get(url, stream=True)
            r.raise_for_status()
        except requests.exceptions.RequestException as e:  # This is the correct syntax
            self.logger.error("ERROR connecting to URL: "+url+". "+str(e))
            return False
        return r


    def _build_resource_file_path(self, resource_dict):
        if resource_dict['url_type'] == "upload":
            aux = resource_dict['id']
            resource_path = str(self.local_resource_files_path + aux[0:3] + "/" + aux[3:6] + "/" + aux[6:])
            self.logger.info("Locating file "+resource_path+" .")
            return resource_path
        else:
            self.logger.error("The resource "+resource_dict['name']+" ("+resource_dict['id']+") is not upload type to be updated.")
            return ""

    def _check_resource_update(self, request_header, file_path):
        url_date = self._get_url_resource_last_modified(request_header)
        file_time = self._get_resource_file_last_modified(file_path)

        # IF at least one of times is not present should be updated
        if not url_date or not file_time:
            self.logger.info("Resource should be updated. No modification time data.")
            return True
        else:
            # TRUE if the remote file is newer than local
            if url_date and file_time and (url_date > file_time):
                self.logger.info("Resource should be updated. (local modification:"+file_time.strftime("%m/%d/%Y, %H:%M:%S")+" source modification:"+url_date.strftime("%m/%d/%Y, %H:%M:%S"))
                return True
            else:
                self.logger.info("Skip update. (local modification:"+file_time.strftime("%m/%d/%Y, %H:%M:%S")+" source modification:"+url_date.strftime("%m/%d/%Y, %H:%M:%S"))
                return False


    def _get_url_resource_last_modified(self, request_header):
        url_datetime = ""
        if 'Last-Modified' in request_header:
            url_datetime = parsedate(request_header['Last-Modified']).astimezone()
        return url_datetime


    def _get_resource_file_last_modified(self, file_path):
        file_time = ""
        if os.path.isfile(file_path):
            file_time = datetime.datetime.fromtimestamp(os.path.getmtime(file_path)).astimezone()
        return file_time

    def set_last_update_date(self, res_dict):
        up_res_dict = {'id': res_dict['id']}
        up_res_dict['auto_update_last_update'] = datetime.datetime.now().isoformat()
        self.update_resource_last_update_in_database(up_res_dict)

    def update_resource_last_update_in_database(self, up_res_dict):
        # https://docs.ckan.org/en/2.9/api/#ckan.logic.action.patch.resource_patch
        action_patch = toolkit.get_action('resource_patch')
        toolkit.auth_allow_anonymous_access(action_patch)

        context = {'model': model,
                   'session': model.Session,
                   'ignore_auth': True,
                   'user': None}
        action_patch(context, up_res_dict)
        self.logger.info("Resource id:"+up_res_dict['id']+" metadata updated.")

    # LOGGER METHODS
    # **************
    def _config_logger(self):
        '''
            The order of logging levels is:
            DEBUG < INFO < WARNING < ERROR < CRITICAL
        '''
        logger = logging.getLogger('scheming_resupdateprofile')
        logger.setLevel(logging.DEBUG)

        # logs directory settings
        self.log_file_path = self.root_path + self.logs_folder
        Path(self.log_file_path).mkdir(parents=True, exist_ok=True)
        os.chmod(self.root_path+'logs', 0o777)
        os.chmod(self.log_file_path, 0o777)
        self.log_file = ""
        self.logger = logger
        if self.update_enabled:
            self._update_logger()

    def _update_logger(self):
        new_log_file = date.today().strftime("%Y_%m_%d") + "_log.log"
        if new_log_file != self.log_file:
            self.log_file = date.today().strftime("%Y_%m_%d") + "_log.log"
            fh = logging.FileHandler(self.log_file_path + self.log_file)
            formatter = logging.Formatter('%(asctime)s - %(threadName)s - %(name)s - %(levelname)s - %(message)s')
            fh.setFormatter(formatter)
            fh.setLevel(logging.DEBUG)
            self.logger.handlers.clear()
            self.logger.addHandler(fh)
          #  os.chmod(self.log_file_path+self.log_file, 0o755)
            #self.logger.propagate = False

    def add_separator_to_log(self):
        # Just for making the log more readable
        with open(self.log_file_path+self.log_file, "a") as file_object:
            file_object.write("*************************************\n\n")