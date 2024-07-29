from ckan.plugins import toolkit
import requests
import json
import logging
import logging.config
from datetime import date
import ckan.model as model
import ckan.logic as logic
from ckan.common import config

from crontab import CronTab

flask_d = toolkit.g
NotFound = logic.NotFound
NotAuthorized = logic.NotAuthorized


class LDM_DatasetImport:

    def __init__(self, ds_parser):
        # Dataset Parser
        self.ds_parser  = ds_parser

        # config updates
        self.ckan_virtual_env_path = '/usr/lib/ckan/default/bin/'
        self.root_path = '/usr/lib/ckan/default/src/ckanext-TIBimport/ckanext/tibimport/'
        self.crontab_user = config.get('tibimport.updatedatasets_crontab_user', "root")
        self.home_ur = config.get('ckan.site_url', "http://localhost:5000")
        self.update_enabled = toolkit.asbool(config.get('tibimport.updatedatasets_enabled', False))
        if ds_parser is None:
            default_log_path = '/usr/lib/ckan/default/src/ckanext-TIBimport/ckanext/tibimport/logs/'
            self.log_file_path = config.get('tibimport.log_file_path', default_log_path)
        else:
            self.log_file_path = ds_parser.log_file_path
        self.config_cronjobs()

        # CKAN's API Actions
        self.context = {'model': model, 'session': model.Session, 'ignore_auth': True, 'user': 'admin'}
        self.action_package_show = toolkit.get_action('package_show')
        self.action_organization_show = toolkit.get_action('organization_show')
        self.action_package_create = toolkit.get_action('package_create')
        self.action_package_update = toolkit.get_action('package_update')
        self.action_package_delete = toolkit.get_action('package_delete')
        self.action_organization_create = toolkit.get_action('organization_create')
        self.action_organization_delete = toolkit.get_action('organization_delete')
        self.action_organization_update = toolkit.get_action('organization_update')

        # Allow unauthorized ejecution
        toolkit.auth_allow_anonymous_access(self.action_package_show)
        toolkit.auth_allow_anonymous_access(self.action_organization_show)
        toolkit.auth_allow_anonymous_access(self.action_package_create)
        toolkit.auth_allow_anonymous_access(self.action_package_update)
        toolkit.auth_allow_anonymous_access(self.action_package_delete)
        toolkit.auth_allow_anonymous_access(self.action_organization_create)
        toolkit.auth_allow_anonymous_access(self.action_organization_update)
        toolkit.auth_allow_anonymous_access(self.action_organization_delete)

        # Set to True to force organization's updates
        self.force_organization_update = False
        # Set to True to force organization update just once (Ex. Some profiles assign all datasets to the same Org)
        self.force_organization_update_only_once = False

    # AUTOUPDATE IMPORTED DATASETS
    # ****************************

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
                   'luh':
                       {'title': 'update_datasets_luh',
                        'method': 'TIB_update_imported_datasets_luh',
                        'comment': "TIB_update_imported_datasets_luh",
                        'crontab_commands': [".setall('0 0 14 * *')"]},
                   'radar':
                       {'title': 'update_datasets_radar',
                        'method': 'TIB_update_imported_datasets_radar',
                        'comment': "TIB_update_imported_datasets_radar",
                        'crontab_commands': [".setall('0 1 14 * *')"]},
                   'pangea':
                       {'title': 'update_datasets_pangea',
                        'method': 'TIB_update_imported_datasets_pangea',
                        'comment': "TIB_update_imported_datasets_pangea",
                        'crontab_commands': [".setall('0 2 14 * *')"]}
                   }

    def get_background_jobs(self):
        return self.background_jobs

    def create_cronjobs(self):

        cron = CronTab(user=self.crontab_user)
        for job in cron.find_comment('tib_update_imported_datasets'):
            cron.remove(job)

        if self.update_enabled:
            command_base = self.ckan_virtual_env_path+'python3 ' + self.root_path + 'run_importation_update.py -t '
            # Define cronjobs
            for key,cronjob in self.background_jobs.items():
                command = command_base + key + " >> " + self.log_file_path + "crontab_log.txt 2>&1"
                job = cron.new(command=command, comment="tib_update_imported_datasets")
                job.env['home_path'] = self.home_ur
                for c in cronjob['crontab_commands']:
                    eval('job'+c)


        cron.write()

    # LOCAL CKAN INTERACTION
    # **********************

    def get_local_dataset(self, name):
        # https://docs.ckan.org/en/2.9/api/#ckan.logic.action.get.package_show
        # Note: Returns data even with dataset deleted => ds['state'] = 'deleted'
        params = {'id': name}
        context = {'model': model, 'session': model.Session, 'ignore_auth': True, 'user': 'admin'}
        #context['return_id_only'] = False
        #context = {}

        try:
            #self.set_log_info("XXXXXXXX " + str(context) + " ZZZZZZZ" + str(params))
            #toolkit.auth_allow_anonymous_access(self.action_package_show)
            result = self.action_package_show(context, params)
        except NotFound as e:
            return {}
        return result

    def get_local_organization(self, name):

        # Just retrieve basic organixation metadata
        # https://docs.ckan.org/en/2.9/api/#ckan.logic.action.get.organization_show
        params = {'id': name,
                   'include_datasets': 'false',
                   'include_dataset_count': 'false',
                   'include_users': 'false',
                   'include_groups': 'false',
                   'include_followers': 'false',
                   'include_extras': 'false'}
        context = {}

        try:
            result = self.action_organization_show(context, params)
        except NotFound as e:
            return {}
        except NotAuthorized as e:
            return {}
        return result

    def insert_dataset(self, ds_dict):
        # https://docs.ckan.org/en/2.9/api/#ckan.logic.action.create.package_create
        context = {'model': model, 'session': model.Session, 'ignore_auth': True, 'user': 'admin'}

        context['return_id_only'] = True
        self.set_log_info("XXXXXXXX " + str(context) + " ZZZZZZZ" + str(ds_dict))
        self.action_package_create(context, ds_dict)

    def update_dataset(self, ds_dict):
        # https://docs.ckan.org/en/2.9/api/#ckan.logic.action.update.package_update
        context = {'model': model, 'session': model.Session, 'ignore_auth': True, 'user': 'admin'}

        context['return_id_only'] = True
        self.action_package_update(context, ds_dict)

    def delete_dataset(self, name):
        # https://docs.ckan.org/en/2.9/api/#ckan.logic.action.delete.package_delete
        ds_dict = {"id": name}
        context = {'model': model, 'session': model.Session, 'ignore_auth': True, 'user': 'admin'}

        self.action_package_delete(context, ds_dict)

    def insert_organization(self, org_dict):
        # https://docs.ckan.org/en/2.9/api/#ckan.logic.action.create.organization_create
        context = {'model': model, 'session': model.Session, 'ignore_auth': True, 'user': 'admin'}
        self.action_organization_create(context, org_dict)

    def update_organization(self, ds_dict):
        # https://docs.ckan.org/en/2.9/api/#ckan.logic.action.update.organization_update
        context = {'model': model, 'session': model.Session, 'ignore_auth': True, 'user': 'admin'}

        context['return_id_only'] = True
        self.action_organization_update(context, ds_dict)

    def delete_organization(self, name):
        # https://docs.ckan.org/en/2.9/api/#ckan.logic.action.delete.organization_delete
        org_dict = {"id": name}
        context = {'model': model, 'session': model.Session, 'ignore_auth': True, 'user': 'admin'}
        self.action_organization_delete(context, org_dict)

    # REMOTE REPOSITORY INTERACTION
    # **********************

    def get_remote_datasets(self):
        '''
            Using the Dataset Parser (DatasetParser) retrieves all remote datasets adjusted
            to the dictionary requirements of CKAN and LDM (virtual Datasets schema).
        '''
        datasets_dict = self.ds_parser.get_all_datasets_dicts()
        return datasets_dict


    def get_remote_organization(self, name):
        '''
            Using the Dataset Parser (DatasetParser) retrieves a remote organization
            to the dictionary requirements of CKAN and LDM.
        '''
        org_dict = self.ds_parser.get_organization(name)
        return org_dict


    # IMPORTATION METHODS
    # ********************

    def import_datasets(self):
        remote_datasets = self.get_remote_datasets()

        # All datasets
        for ds in remote_datasets:
            self._insert_update_skip_dataset(ds)

        # For testing just 10
        #for x in range(50):
        #    self._insert_update_skip_dataset(remote_datasets[x])
        #self._insert_update_skip_dataset(remote_datasets[3])
        self.set_log_info(self.ds_parser.get_summary_log())

    def _insert_update_skip_dataset(self, remote_dataset):
        ds_name = remote_dataset['name']
        org_name = remote_dataset['organization']['name']

        # Search the dataset locally
        self.set_log_info("Processing Dataset: " + ds_name + "...")
        dataset = self.get_local_dataset(ds_name)

        if dataset == {}: # Not Found
            # Insert Organization first
            self._insert_skip_organization(remote_dataset['organization'])
            # discard remmote id
            remote_dataset['id'] = ''
            # Insert Dataset
            self.insert_dataset(remote_dataset)
            self.ds_parser.increment_inserted_log()
            self.set_log_info("Dataset: " + ds_name + " Inserted")

        elif not self.ds_parser.should_be_updated(dataset, remote_dataset):
            # Skip Dataset - No changes
            self.ds_parser.increment_skiped_log()
            self.set_log_info("Dataset: "+ ds_name +" Skiped - No changes")

        else:
            # Update Dataset
            # use local id
            # Organization could change and need to be inserted first
            self._insert_skip_organization(remote_dataset['organization'])

            remote_dataset['id'] = dataset['id']
            self.update_dataset(remote_dataset)
            self.ds_parser.increment_modified_log()
            self.set_log_info("Dataset: " + ds_name + " Updated")


    def _insert_skip_organization(self, org_dict):
        # Search the organization locally
        org = self.get_local_organization(org_dict['name'])
        if org == {}: # Not Found
            # Insert organization
            org_insert_dict = self.ds_parser.get_organization(org_dict['name'])
            self.insert_organization(org_insert_dict)
            self.set_log_info("Organization: " + org_insert_dict['name'] + " Inserted")
        elif self.force_organization_update:
            # Update Organization
            org_insert_dict = self.ds_parser.get_organization(org_dict['name'])
            org_insert_dict['id'] = org_dict['name']
            self.update_organization(org_insert_dict)
            self.set_log_info("Organization: " + org_insert_dict['name'] + " Updated")
            if self.force_organization_update_only_once:
                self.force_organization_update = False
        else:
            self.set_log_info("Organization: " + org_dict['name'] + " Skiped - Already exists")


    # LOGGER METHODS
    # **************

    def set_log_info(self, msg):
        self.ds_parser.logger.message = msg
        self.ds_parser.set_log_msg_info()

    def set_log_error(self, msg):
        self.ds_parser.logger.message = msg
        self.ds_parser.set_log_msg_error()

    def get_summary_log(self):
        return self.ds_parser.get_summary_log()





class DatasetParser():
    '''

    A Class used as reference defining the behavior that subclasses should implement
    for each particular source repository.

    '''

    def __init__(self):
        '''
        Profiles inherited from this class should define the following values
        self.log_file_prefix = "LUH_" # example
        '''
        self._config_logger()


    def get_all_datasets_dicts(self):
        '''
        This method should be implemented inside a Dataset Parser Profile
        Returning an array of dicts with all remote datasets dictionaries
        '''
        pass

    def get_organization(self, name):
        '''
            This method should be implemented inside a Dataset Parser Profile
            Returning a dictionary with an organization metadata
        '''
        pass

    def adjust_dataset_name(self, ds_name):
        '''
        This method should be implemented inside a Dataset Parser Profile
        Returning the dataset name (id) just as will be recorded in CKAN
        '''
        pass

    def should_be_updated(self, local_dataset, remote_dataset):
        '''
            This method should be implemented inside a Dataset Parser Profile
            Returning True or False after datasets comparison
        '''
        pass

    def check_current_schema(self):
        '''
            This method should be implemented inside a Dataset Parser Profile
            Returning a dict with the results of comparing the metadata schema used in the code
            with the metadata schema retrieved by remote servers

            result = {'status_ok': True,
                      'report': 'Text explaining the results'}
                '''
        pass

    # LOGGER METHODS
    # **************

    def _config_logger(self):
        '''
            The order of logging levels is:
            DEBUG < INFO < WARNING < ERROR < CRITICAL
        '''
        logger = logging.getLogger('tibimport_parseprofile')
        logger.setLevel(logging.DEBUG)
        default_log_path = '/usr/lib/ckan/default/src/ckanext-TIBimport/ckanext/tibimport/logs/'
        self.log_file_path = config.get('tibimport.log_file_path', default_log_path)
        self.log_file = self.log_file_prefix+date.today().strftime("%Y_%m_%d")+"_log.log"
        fh = logging.FileHandler(self.log_file_path+self.log_file)
        formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
        fh.setFormatter(formatter)
        fh.setLevel(logging.DEBUG)
        logger.handlers.clear()
        logger.addHandler(fh)
        self.logger = logger
        self.logger.message = ""
        self.reset_summary_logger()

    def set_log_msg_info(self):
        self.logger.info(self.logger.message)

    def set_log_msg_error(self):
        self.logger.error(self.logger.message)

    def reset_summary_logger(self):
        self.logger.datasets_inserted = 0
        self.logger.datasets_modified = 0
        self.logger.datasets_skiped = 0

    def get_summary_log(self):
        summary_log = {'Repository_name': self.repository_name,
                       "Datasets_inserted": self.logger.datasets_inserted,
                       "Datasets_updated": self.logger.datasets_modified,
                       "Datasets_skiped": self.logger.datasets_skiped,
                       "LOG_file": self.log_file_path+self.log_file,
                       "SCHEMA_REPORT": self.check_current_schema()}

        return summary_log

    def increment_inserted_log(self):
        self.logger.datasets_inserted += 1

    def increment_modified_log(self):
        self.logger.datasets_modified += 1

    def increment_skiped_log(self):
        self.logger.datasets_skiped += 1













# class LUH_CKAN_API_ParserProfile(DatasetParser):
#     '''
#
#     A class defined to access CKAN's Datasets in Leibniz University Hannover (LUH)
#     using the API and parsing the retrieved data to dataset_dic as needed by the LDM
#
#     '''
#
#     def __init__(self):
#         self.repository_name = "Leibniz University Hannover"
#         self.dataset_title_prefix = "luh-"
#         self.ckan_api_url_package_list = "https://data.uni-hannover.de/api/3/action/package_list"
#         self.ckan_api_url_package_show = "https://data.uni-hannover.de/api/3/action/package_show"
#         self.ckan_api_url_organization_show = "https://data.uni-hannover.de/api/3/action/organization_show"
#         self.log_file_prefix = "LUH_"
#         super().__init__()
#
#
#     def get_all_datasets_dicts(self):
#         '''
#              Through "get_datasets_list" method and "get_dataset_data" method
#              list of dictionaries with the complete Dataset's metadata inside.
#
#              Returns: an array of  dictionary with the list of datasets or an empty array
#         '''
#         ds_list = self.get_datasets_list()
#         ds_array = [0 for x in range(len(ds_list))]
#         i = 0
#         for ds in ds_list:
#             ds_data = self.get_dataset_data(ds)
#             ds_data = self.adjust_dataset_dict(ds_data)
#             ds_array[i] = ds_data
#             i += 1
#         return ds_array
#
#     def get_datasets_list(self):
#         '''
#             Uses the LUH API to retrieve a list of datasets in a dictionary
#
#             Returns: a dictionary with the list of datasets or an empty dict
#         '''
#         self.set_log("infos_searching_ds")
#
#         try:
#             response = requests.get(self.ckan_api_url_package_list)
#         except requests.exceptions.RequestException as e:  # This is the correct syntax
#             self.set_log("error_API", self.ckan_api_url_package_list + " - " + e.__str__())
#             return {}
#
#         response_data = response.json()
#         return self._process_api_response(response_data, "get_datasets_list")
#
#
#     def get_dataset_data(self, ds_title):
#         '''
#             Uses the LUH API to retrieve a dataset's metadata idenfied by the dataset's
#
#             title formated as URL (this is the way required by the API and the way that
#
#             the datasets are identified in "package_list" response.
#
#
#             Returns: a dictionary with the dataset's metadata
#         '''
#
#         # data to be sent to api
#         data = {'id': ds_title}
#         try:
#             response = requests.post(self.ckan_api_url_package_show, data = data)
#         except requests.exceptions.RequestException as e:  # This is the correct syntax
#             self.set_log("error_API", self.ckan_api_url_package_show + " - " + e.__str__())
#             return {}
#
#         response_data = response.json()
#         return self._process_api_response(response_data, "get_dataset_data")
#
#
#     def get_organization(self, name):
#         '''
#             Uses the LUH API to retrieve an organization's metadata idenfied by the name
#               (title formated as URL - this is the way required by the API)
#
#             Returns: a dictionary with the organization's metadata or an empty dict in failiure
#         '''
#         # https://docs.ckan.org/en/2.9/api/#ckan.logic.action.get.organization_show
#         self.set_log("infos_searching_org", name)
#
#         params = {'id': name}
#         try:
#             response = requests.get(self.ckan_api_url_organization_show, params = params)
#         except requests.exceptions.RequestException as e:  # This is the correct syntax
#             self.set_log("error_API", self.ckan_api_url_organization_show + " - " + e.__str__())
#             return {}
#
#         response_data = response.json()
#         org_dict = self._process_api_response(response_data, "get_organization")
#         if org_dict:
#             return self.adjust_organization_dict(org_dict)
#         else:
#             return org_dict
#
#     def _process_api_response(self, response_data, op):
#
#         msg_error_api_data = {"get_datasets_list": {"url": self.ckan_api_url_package_list,
#                                                     "success_log": "infos_ds_found",
#                                                     "success_msg": "str(len(response_data['result']))"
#                                                     },
#                               "get_dataset_data": {"url": self.ckan_api_url_package_show,
#                                                    "success_log": "infos_ds_metadata_found",
#                                                    "success_msg": "str(response_data['result']['name'])"
#                                                    },
#                               "get_organization": {"url": self.ckan_api_url_package_show,
#                                                    "success_log": "infos_org_found",
#                                                    "success_msg": "str(response_data['result']['name'])"
#                                                    }
#                               }
#         msg_error_api_data = msg_error_api_data[op]
#
#         if not 'success' in response_data:
#             self.set_log("error_api_data", msg_error_api_data['url'])
#             return {}
#         elif response_data['success']:
#             self.set_log(msg_error_api_data['success_log'], eval(msg_error_api_data['success_msg']))
#             return response_data['result']
#         self.set_log("error_api_data", msg_error_api_data['url'])
#         return {}
#
#     def adjust_dataset_name(self, ds_name):
#         name = self.dataset_title_prefix + ds_name
#         # CKAN limits name to 100 chars
#         return (name[:100]).strip()
#
#     def adjust_organization_dict(self, org_dict):
#         org_dict['image_url'] = org_dict['image_display_url']
#         return org_dict
#
#     def adjust_dataset_dict(self, ds_dict):
#         # set source url
#         ds_dict['url'] = ds_dict['domain'] + '/dataset/' + ds_dict['name']
#
#         # adjust dataset and repository names
#         ds_dict['name'] = self.adjust_dataset_name(ds_dict['name'])
#         ds_dict['repository_name'] = self.repository_name
#
#         # Save the dataset as virtual dataset (vdataset)
#         ds_dict['type'] = "vdataset"
#
#         # save source creation and modification dates
#         ds_dict['source_metadata_created'] = ds_dict['metadata_created']
#         ds_dict['source_metadata_modified'] = ds_dict['metadata_modified']
#
#         # clean fields
#         clean_fields = {"metadata_created", "creator_user_id"}
#         for fd in clean_fields:
#             ds_dict[fd] = ""
#
#         # clean relationships
#         ds_dict["groups"] = []
#         ds_dict["relationships_as_subject"] = []
#         ds_dict["revision_id"] = ""
#
#         # set organization owner and image
#         ds_dict['owner_org'] = ds_dict['organization']['name']
#
#         # Save all resources as URl type for making them virtual
#         for resource in ds_dict['resources']:
#             resource['url_type'] = ""
#
#         # Save extra fields (not standard ckan fields added by LUH)
#         # Listed just for reference and control
#         # 'domain'
#         # 'terms_of_usage'
#         # 'have_copyright'
#
#         return ds_dict
#
#     def get_remote_dataset_schema(self):
#         ds_dicts = self.get_all_datasets_dicts()
#
#         dataset_keys = []
#         resource_keys = []
#         resource_types = []
#
#         for dataset in ds_dicts:
#             for key, value in dataset.items():
#                 if not key in dataset_keys:
#                     dataset_keys.append(key)
#                 if key=='resources' and not dataset['resources']==[]:
#                     for resource in dataset['resources']:
#                         for key2, value2 in resource.items():
#                             if not key2 in resource_keys:
#                                 resource_keys.append(key2)
#                             if key2=='format':
#                                 if not value2 in resource_types:
#                                     resource_types.append(value2)
#         return { "dataset_keys": dataset_keys, "resource_keys": resource_keys, "resource_types": resource_types}
#
#
# # LOGGER METHODS
# # **************
#
#
#     def set_log(self, op, data=""):
#
#         self.logger.message = ""
#
#         def infos_searching_ds(data):
#             self.logger.message = "Searching Datasets in LUH API."
#
#         def error_API(data):
#             self.logger.message = "Error Connecting API: " + data
#
#         def error_api_data(data):
#             self.logger.message = "Error retrieving data from API: " + data
#
#         def infos_ds_found(data):
#             self.logger.message = "Number of Datasets found: " + data
#
#         def infos_ds_metadata_found(data):
#             self.logger.message = "Metadata found with name: " + data
#
#         def infos_searching_org(data):
#             self.logger.message = "Searching Organizaion in LUH API. Name: " + data
#
#         def infos_org_found(data):
#             self.logger.message = "Organization found: " + data
#
#         def infos_summary_log(data):
#             self.logger.message = self.get_summary_log()
#
#         result = {
#             'infos_searching_ds': infos_searching_ds,
#             'error_API': error_API,
#             'error_api_data': error_api_data,
#             'infos_ds_found': infos_ds_found,
#             'infos_ds_metadata_found': infos_ds_metadata_found,
#             'infos_searching_org': infos_searching_org,
#             'infos_org_found': infos_org_found,
#             'infos_org_found': infos_summary_log
#         }.get(op)(data)
#
#         if op[0:5]=='infos':
#             self.set_log_msg_info()
#         elif op[0:5]=='error':
#             self.set_log_msg_error()