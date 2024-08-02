import requests, os
from ckanext.ldm_sparql.RDFizer_Util import RDFizer_Util

from logging import getLogger
log = getLogger(__name__)

class LDM_API_to_DCAT_Harvester():
    '''

    A class defined to access CKAN's Datasets in LDM public version (https://service.tib.eu/ldmservice)
    using the API and parsing the retrieved data and converting the data to DCAT-RDF descriptions.

    '''

    def __init__(self):
        self.LDM_api_url_package_list = "https://service.tib.eu/ldmservice/api/3/action/package_list"
        self.LDM_api_url_package_show = "https://service.tib.eu/ldmservice/api/3/action/package_show"
        self.LDM_api_url_organization_show = "https://service.tib.eu/ldmservice/api/3/action/organization_show"

        # LFM HOME URL
        self.home_url = "https://service.tib.eu/ldmservice"

        # DCAT files output folder
        self.output_folder = "/usr/lib/ckan/default/src/ckanext-LDM_SPARQL/ckanext/ldm_sparql/tests/RDFizer_example/output/LDM_DCAT_N3"

    def get_datasets_list(self):
        '''
            Uses the LDM API to retrieve a list of datasets in a dictionary

            Returns: a dictionary with the list of datasets or an empty dict
        '''

        try:
            response = requests.get(self.LDM_api_url_package_list)
        except requests.exceptions.RequestException as e:  # This is the correct syntax
            log.error(self.LDM_api_url_package_list + " - " + e.__str__())
            return {}

        response_data = response.json()
        if not 'success' in response_data:
            log.error("Error accessing the API: " + self.LDM_api_url_package_list)
            return {}
        elif response_data['success']:
            log.info("Accessing API: " + self.LDM_api_url_package_list)
            return response_data['result']
        log.error("Error accessing the API. No valid result in request: " + self.LDM_api_url_package_list)
        return {}


    def get_dataset_data(self, ds_title):
        '''
            Uses the LDM API to retrieve a dataset's metadata identified by the dataset's

            title formatted as URL (this is the way required by the API and the way that

            the datasets are identified in "package_list" response.


            Returns: a dictionary with the dataset's metadata
        '''

        # data to be sent to api
        data = {'id': ds_title}
        try:
            response = requests.post(self.LDM_api_url_package_show, data = data)
        except requests.exceptions.RequestException as e:  # This is the correct syntax
            log.error(self.LDM_api_url_package_show + " - " + e.__str__())
            return {}

        response_data = response.json()
        if not 'success' in response_data:
            log.error("Error accessing the API: " + self.LDM_api_url_package_show)
            return {}
        elif response_data['success']:
            log.info("Accessing API: " + self.LDM_api_url_package_show)
            return response_data['result']
        log.error("Error accessing the API. No valid result in request: " + self.LDM_api_url_package_show)
        return {}


    def get_organization(self, name):
        '''
            Uses the LDM API to retrieve an organization's metadata idenfied by the name
              (title formated as URL - this is the way required by the API)

            Returns: a dictionary with the organization's metadata or an empty dict in failiure
        '''
        # https://docs.ckan.org/en/2.9/api/#ckan.logic.action.get.organization_show

        params = {'id': name}
        try:
            response = requests.get(self.LDM_api_url_organization_show, params = params)
        except requests.exceptions.RequestException as e:  # This is the correct syntax
            log.error(self.LDM_api_url_organization_show + " - " + e.__str__())
            return {}

        response_data = response.json()
        if not 'success' in response_data:
            log.error("Error accessing the API: " + self.LDM_api_url_organization_show)
            return {}
        elif response_data['success']:
            log.info("Accessing API: " + self.LDM_api_url_organization_show)
            return response_data['result']
        log.error("Error accessing the API. No valid result in request: " + self.LDM_api_url_organization_show)
        return {}


    def convert_dataset_dict_to_DCAT(self, ds_dict):

        dataset_name = ds_dict['name']
        output_file = self.output_folder + '/' + dataset_name + '.nt'
        temp_json_file = self.output_folder + "/temp.json"

        # RDFizer_Util configuration
        dataset_config = {
            "remove_duplicate": "no",
            "all_in_one_file": "no",
            "name": dataset_name,
            "enrichment": "yes",
            "ordered": "yes",
            "output_format": "n-triples"
        }

        mapping_file = "test_harvester_mapping_dataset_json.ttl"
        if ds_dict.get('type', '') == 'service':
            mapping_file = "test_harvester_mapping_dataservice_json.ttl"

        rdfizer_util = RDFizer_Util(mapping_file, self.output_folder, dataset_config)

        # get Dataset Data
        dataset_data = self.get_dataset_data(dataset_name)
        dataset_data = self.preprocess_dataset_dict(dataset_data)

        # save dataset as temporal file
        rdfizer_util.write_dataset_dict_to_json_file(temp_json_file, dataset_data)
        rdfizer_util.run_RDFizer()

        #delete temporal file
        if os.path.exists(temp_json_file):
            os.remove(temp_json_file)


    def convert_all_datasets_dicts_to_DCAT(self):

        dataset_list = self.get_datasets_list()

        for dataset_name in dataset_list:
            dataset = self.get_dataset_data(dataset_name)
            self.convert_dataset_dict_to_DCAT(dataset)

    def preprocess_dataset_dict(self, dataset_dict):

        identififier = self._get_dataset_identifier_from(dataset_dict)
        # Adding DOI to dict
        dataset_dict['doi'] = identififier

        # Adding DOI to other fields
        fields = ["extra_authors", "resources", "tags"]

        for field in fields:
            if field in dataset_dict:
                for data_instance in dataset_dict[field]:
                    data_instance['doi'] = identififier

                    # size in resources of type URL causing errors
                    if field == "resources":
                        if not data_instance['size']:
                            data_instance['size'] = ''
                        # descriptions causing errors
                        data_instance['description'] = data_instance['description'].replace('\n', '')
                        data_instance['description'] = data_instance['description'].replace('\r', '')

        # returns in description causes error
        dataset_dict['notes'] = dataset_dict['notes'].replace('\n', '')
        dataset_dict['notes'] = dataset_dict['notes'].replace('\r', '')

        # Dataset-Dataservice relationships
        # "datasets_served_list": "d1beaa8b-bba9-4f5f-b85e-644e339faac2,1abefb2e-6a83-4004-b7db-74c34b545d2e",
        # "services_used_list": "1d67f22f-9f51-4301-9a9c-3682f39ffafe",
        # "extra_authors": [
        #     {   "doi": "10.57702/y89qq7yc",
        #         "extra_author": "Autor2",
        #         "orcid": "38947593457"
        #     }
        # ],
        services_used_list = dataset_dict.get('services_used_list', '')
        datasets_served_list = dataset_dict.get('datasets_served_list', '')

        if services_used_list != '':
            service_list = services_used_list.split(',')
            result_list = []
            for service in service_list:
                related_service = self.get_dataset_data(service)
                rel_identifier = self._get_dataset_identifier_from(related_service)
                result_list.append({'doi': identififier, 'rel_doi': rel_identifier})
            dataset_dict["services_used_list"] = result_list

        if datasets_served_list != '':
            dataset_list = datasets_served_list.split(',')
            result_list = []
            for dataset in dataset_list:
                served_dataset = self.get_dataset_data(dataset)
                rel_identifier = self._get_dataset_identifier_from(served_dataset)
                result_list.append({'doi': identififier, 'rel_doi': rel_identifier})
            dataset_dict["datasets_served_list"] = result_list
        else:
            if "datasets_served_list" in dataset_dict:
                del dataset_dict["datasets_served_list"]

        return dataset_dict


    def _get_dataset_identifier_from(self, dataset_dict):
        if "doi" in dataset_dict and dataset_dict['doi']:
            return 'https://doi.org/' + dataset_dict['doi']
        else:
            idf = self.home_url + "/" + dataset_dict['type'] + "/" + dataset_dict['name']
            return idf
