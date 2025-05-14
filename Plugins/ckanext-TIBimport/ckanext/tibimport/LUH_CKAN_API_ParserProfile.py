from ckanext.tibimport.logic2 import DatasetParser
import requests
import json
from ckanext.tibimport.LLM_search_authors_from_text import LLMSearchAuthorsFromText

class LUH_CKAN_API_ParserProfile(DatasetParser):
    '''

    A class defined to access CKAN's Datasets in Leibniz University Hannover (LUH)
    using the API and parsing the retrieved data to dataset_dic as needed by the LDM

    '''

    def __init__(self):
        self.repository_name = "Leibniz University Hannover"
        self.dataset_title_prefix = "luh-"
        self.ckan_api_url_package_list = "https://data.uni-hannover.de/api/3/action/package_list"
        self.ckan_api_url_package_show = "https://data.uni-hannover.de/api/3/action/package_show"
        self.ckan_api_url_organization_show = "https://data.uni-hannover.de/api/3/action/organization_show"
        self.log_file_prefix = "LUH_"

        # Set to True to force update of all datasets
        self.force_update = False

        # schema validation report
        self.current_schema_report = {}

        super().__init__()


    def get_all_datasets_dicts(self):
        '''
             Through "get_datasets_list" method and "get_dataset_data" method
             list of dictionaries with the complete Dataset's metadata inside.

             Returns: an array of  dictionary with the list of datasets or an empty array
        '''
        ds_list = self.get_datasets_list()
        ds_array = [0 for x in range(len(ds_list))]
        i = 0
        for ds in ds_list:
            ds_data = self.get_dataset_data(ds)
            ds_data = self.adjust_dataset_dict(ds_data)
            ds_array[i] = ds_data
            i += 1
        return ds_array

    def get_datasets_list(self):
        '''
            Uses the LUH API to retrieve a list of datasets in a dictionary

            Returns: a dictionary with the list of datasets or an empty dict
        '''
        self.set_log("infos_searching_ds")

        try:
            response = requests.get(self.ckan_api_url_package_list)
        except requests.exceptions.RequestException as e:  # This is the correct syntax
            self.set_log("error_API", self.ckan_api_url_package_list + " - " + e.__str__())
            return {}

        response_data = response.json()
        return self._process_api_response(response_data, "get_datasets_list")


    def get_dataset_data(self, ds_title):
        '''
            Uses the LUH API to retrieve a dataset's metadata idenfied by the dataset's

            title formated as URL (this is the way required by the API and the way that

            the datasets are identified in "package_list" response.


            Returns: a dictionary with the dataset's metadata
        '''

        # data to be sent to api
        data = {'id': ds_title}
        try:
            response = requests.post(self.ckan_api_url_package_show, data = data)
        except requests.exceptions.RequestException as e:  # This is the correct syntax
            self.set_log("error_API", self.ckan_api_url_package_show + " - " + e.__str__())
            return {}

        response_data = response.json()
        return self._process_api_response(response_data, "get_dataset_data")


    def get_organization(self, name):
        '''
            Uses the LUH API to retrieve an organization's metadata idenfied by the name
              (title formated as URL - this is the way required by the API)

            Returns: a dictionary with the organization's metadata or an empty dict in failiure
        '''
        # https://docs.ckan.org/en/2.9/api/#ckan.logic.action.get.organization_show
        self.set_log("infos_searching_org", name)

        params = {'id': name}
        try:
            response = requests.get(self.ckan_api_url_organization_show, params = params)
        except requests.exceptions.RequestException as e:  # This is the correct syntax
            self.set_log("error_API", self.ckan_api_url_organization_show + " - " + e.__str__())
            return {}

        response_data = response.json()
        org_dict = self._process_api_response(response_data, "get_organization")
        if org_dict:
            return self.adjust_organization_dict(org_dict)
        else:
            return org_dict

    def _process_api_response(self, response_data, op):

        msg_error_api_data = {"get_datasets_list": {"url": self.ckan_api_url_package_list,
                                                    "success_log": "infos_ds_found",
                                                    "success_msg": "str(len(response_data['result']))"
                                                    },
                              "get_dataset_data": {"url": self.ckan_api_url_package_show,
                                                   "success_log": "infos_ds_metadata_found",
                                                   "success_msg": "str(response_data['result']['name'])"
                                                   },
                              "get_organization": {"url": self.ckan_api_url_package_show,
                                                   "success_log": "infos_org_found",
                                                   "success_msg": "str(response_data['result']['name'])"
                                                   }
                              }
        msg_error_api_data = msg_error_api_data[op]

        if not 'success' in response_data:
            self.set_log("error_api_data", msg_error_api_data['url'])
            return {}
        elif response_data['success']:
            self.set_log(msg_error_api_data['success_log'], eval(msg_error_api_data['success_msg']))
            return response_data['result']
        self.set_log("error_api_data", msg_error_api_data['url'])
        return {}

    def adjust_dataset_name(self, ds_name):
        name = self.dataset_title_prefix + ds_name
        # CKAN limits name to 100 chars
        return (name[:100]).strip()

    def adjust_organization_dict(self, org_dict):
        org_dict['image_url'] = org_dict['image_display_url']
        return org_dict

    def adjust_dataset_dict(self, ds_dict):
        # set source url
        ds_dict['url'] = ds_dict['domain'] + '/dataset/' + ds_dict['name']

        # adjust dataset and repository names
        ds_dict['name'] = self.adjust_dataset_name(ds_dict['name'])
        ds_dict['repository_name'] = self.repository_name

        # Save the dataset as virtual dataset (vdataset)
        ds_dict['type'] = "vdataset"

        # save source creation and modification dates
        ds_dict['source_metadata_created'] = ds_dict['metadata_created']
        ds_dict['source_metadata_modified'] = ds_dict['metadata_modified']

        # clean fields
        clean_fields = {"metadata_created", "creator_user_id"}
        for fd in clean_fields:
            ds_dict[fd] = ""

        # clean relationships
        ds_dict["groups"] = []
        ds_dict["relationships_as_subject"] = []
        ds_dict["revision_id"] = ""

        # set organization owner and image
        ds_dict['owner_org'] = ds_dict['organization']['name']

        # Save all resources as URl type for making them virtual
        for resource in ds_dict['resources']:
            resource['url_type'] = ""

        ds_dict['citation'] = []
        # Save extra fields (not standard ckan fields added by LUH)
        # Listed just for reference and control
        # 'domain'
        # 'terms_of_usage'
        # 'have_copyright'

        # process author field
        #  for best performance authors only should be processed if insert or update should be done
        # ds_dict = self._process_authors(ds_dict)

        return ds_dict

    def _process_authors(self, ds_dict):

        ''' Solve LUH repository using multiple (colon or semicolon separated) authors in field.
        Using a LLM call searching for firstName and lastName for the given text.
            Response is: [{"firstName": "name", "lastName": "familyName"}] '''

        authors_txt = ds_dict['author']

        LLM_obj = LLMSearchAuthorsFromText()
        authors = LLM_obj.search_for_author_in_text(authors_txt)

        extra_authors = []
        pos = 1
        for author in authors:
            # orcid = ""

            # first is author
            if pos == 1:
                ds_dict['author'] = author["lastName"] + ', ' + author["firstName"]
                ds_dict['familyName'] = author["lastName"]
                ds_dict['givenName'] = author["firstName"]
                # ds_dict['orcid'] = orcid
                pos += 1
            else:
                # following are extra_authors
                extra_author = {"extra_author": author["lastName"] + ', ' + author["firstName"],
                                "familyName": author["lastName"],
                                "givenName": author["firstName"]}
                                # ,"orcid": orcid}
                extra_authors.append(extra_author)
        if extra_authors:
            ds_dict['extra_authors'] = extra_authors

        return ds_dict

    def get_remote_dataset_schema(self):
        ds_dicts = self.get_all_datasets_dicts()

        dataset_keys = []
        resource_keys = []
        resource_types = []

        for dataset in ds_dicts:
            for key, value in dataset.items():
                if not key in dataset_keys:
                    dataset_keys.append(key)
                if key=='resources' and not dataset['resources']==[]:
                    for resource in dataset['resources']:
                        for key2, value2 in resource.items():
                            if not key2 in resource_keys:
                                resource_keys.append(key2)
                            if key2=='format':
                                if not value2 in resource_types:
                                    resource_types.append(value2)
        return {"dataset_keys": dataset_keys, "resource_keys": resource_keys, "resource_types": resource_types}

    def should_be_updated(self, local_dataset, remote_dataset):
        if self.force_update:
            return True
        else:
            return local_dataset['source_metadata_modified'] != remote_dataset['metadata_modified']

    def execute_before_insert_dataset(self, remote_dataset):
        '''
            This method should be implemented inside a Dataset Parser Profile
            if needed. Allows to run specific modifications over the dataset to be inserted
        '''
        remote_dataset = self._process_authors(remote_dataset)
        return remote_dataset

    def execute_before_update_dataset(self, remote_dataset):
        '''
            This method should be implemented inside a Dataset Parser Profile
            if needed. Allows to run specific modifications over the dataset to be inserted
        '''
        remote_dataset = self._process_authors(remote_dataset)
        return remote_dataset

    def check_current_schema(self):
        '''
            This method retrieves the status of the metadata schema implemented vs the current schema in LUH
            Returning a dict with the results of comparing the metadata schema used in the code
            with the metadata schema retrieved by remote servers

            result = {'status_ok': True,
                      'report': 'Text explaining the results'}
                '''
        if not self.current_schema_report:
            self.current_schema_report = self._get_schema_report()

        return self.current_schema_report

    def _get_schema_report(self, obj_tree=None):

        luh_schema_data = self.get_remote_dataset_schema()

        report = {'status_ok': True,
                  'report': {'current_metadata': luh_schema_data,
                             'errors': {}},
                  }


        # Check Dataset metadata schema
        for s_type in ('dataset_keys', 'resource_keys', 'resource_types'):
            chk_schema = self._check_schema(luh_schema_data, s_type)
            report['report']['errors'][s_type] = chk_schema[s_type]
            if report['status_ok'] != chk_schema['status_ok']:
                report['status_ok'] = chk_schema['status_ok']

        return report

    def _check_schema(self, luh_schema_data, s_type):
        schema_ok = True
        report_dict = {s_type: {}}

        error_txt = ''
        for field in luh_schema_data[s_type]:
            if field not in luh_datasets_and_resources_keys[s_type]:
                error_txt += field + ", "
                if s_type != 'resource_types': # resources types only show a Warning
                    schema_ok = False

        #report_dict[s_type] =  '' + " ,".join(str(x) for x in luh_schema_data[s_type])
        if error_txt:
            if s_type == 'resource_types':  # resources types only show a Warning
                report_dict[s_type]['Warning'] = error_txt
            else:
                report_dict[s_type]['Error'] = error_txt
        else:
            report_dict[s_type]['Error'] = 'None'

        report_dict['status_ok'] = schema_ok
        return report_dict

# LOGGER METHODS
# **************


    def set_log(self, op, data=""):

        self.logger.message = ""

        def infos_searching_ds(data):
            self.logger.message = "Searching Datasets in LUH API."

        def error_API(data):
            self.logger.message = "Error Connecting API: " + data

        def error_api_data(data):
            self.logger.message = "Error retrieving data from API: " + data

        def infos_ds_found(data):
            self.logger.message = "Number of Datasets found: " + data

        def infos_ds_metadata_found(data):
            self.logger.message = "Metadata found with name: " + data

        def infos_searching_org(data):
            self.logger.message = "Searching Organizaion in LUH API. Name: " + data

        def infos_org_found(data):
            self.logger.message = "Organization found: " + data

        def infos_summary_log(data):
            self.logger.message = self.get_summary_log()

        result = {
            'infos_searching_ds': infos_searching_ds,
            'error_API': error_API,
            'error_api_data': error_api_data,
            'infos_ds_found': infos_ds_found,
            'infos_ds_metadata_found': infos_ds_metadata_found,
            'infos_searching_org': infos_searching_org,
            'infos_org_found': infos_org_found,
            'infos_summary_log': infos_summary_log
        }.get(op)(data)

        if op[0:5]=='infos':
            self.set_log_msg_info()
        elif op[0:5]=='error':
            self.set_log_msg_error()


luh_datasets_and_resources_keys =  {'dataset_keys':
                                        ['domain', 'license_title', 'maintainer', 'relationships_as_object',
                                         'doi_status', 'private', 'maintainer_email', 'num_tags',
                                         'id', 'metadata_created', 'metadata_modified', 'author',
                                         'author_email', 'terms_of_usage', 'state', 'version',
                                         'creator_user_id', 'type', 'have_copyright', 'num_resources',
                                         'tags', 'doi', 'groups', 'license_id', 'relationships_as_subject',
                                         'doi_publisher', 'organization', 'name', 'isopen', 'url', 'notes',
                                         'owner_org', 'license_url', 'resources', 'title', 'revision_id',
                                         'doi_date_published', 'repository_name', 'source_metadata_created',
                                         'source_metadata_modified', 'extras'],
                                    'resource_keys': ['mimetype', 'cache_url', 'hash', 'description',
                                                      'name', 'format', 'url', 'cache_last_updated',
                                                      'package_id', 'created', 'state', 'mimetype_inner',
                                                      'last_modified', 'position',
                                                      'url_type', 'id', 'resource_type', 'size',
                                                      'downloadall_datapackage_hash',
                                                      'downloadall_metadata_modified','metadata_modified'],
                                    'resource_types': ['ZIP', 'ASCII', 'CSV', 'TXT', 'JSON', 'XML',
                                                       '', 'PNG', '.csv', 'TAR', 'SHP', '.tiff', 'TIFF',
                                                       'tar.gz', 'PDF', 'matlab', 'video/mp4', 'JPEG', '7z',
                                                       'application/x-7z-compressed', 'obj', 'RAR', 'json, pdf, txt',
                                                       'XLSX', 'CSV, TXT', '.zip', 'GFC', 'chemical/x-gamess-input',
                                                       'XLS', 'video/quicktime', '.md', 'Turtle', 'MP4', 'shape', 'python',
                                                       'TSV', 'jsonl', 'text', 'python code', 'py', 'text/markdown',
                                                       'avi', 'Ansys-APDL']}
