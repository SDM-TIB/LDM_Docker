
from ckan.common import config
#from ckanext.ldm_sparql.RDFizer.semantify import semantify
from rdfizer import semantify
import ckan.logic as logic
import ckan.model as model
from ckan.plugins import toolkit
from ckan.common import config
from ckanext.ldm_sparql.ORCID_Util import ORCID_Util
from ckanext.ldm_sparql.Falcon_Util import Falcon_Util

NotFound = logic.NotFound
NotAuthorized = logic.NotAuthorized

import json, os, shutil
import logging
log = logging.getLogger(__name__)

from rdflib import Graph

class RDFizer_Util:

    def __init__(self, mapping_file = "", output_folder="", dataset_config = {}):
        # HOME URL
        self.home_url = config.get('ckan.site_url', "http://localhost:5000")

        # CKAN's API Actions
        self.action_package_show = toolkit.get_action('package_show')
        self.action_package_list = toolkit.get_action('package_list')
        self.action_organization_show = toolkit.get_action('organization_show')

        # RDFizer config
        self.RDFizer_default_dataset_mapping = "DCAT_mapping_datasets.ttl"
        self.RDFizer_default_dataservice_mapping = "DCAT_mapping_dataservices.ttl"

        if not mapping_file:
            mapping_file = self.RDFizer_default_dataset_mapping

        if not output_folder:
            output_folder = config.get('ckan.storage_path', "/var/lib/ckan") + '/rdf'

        self.plugin_path = '/usr/lib/ckan/default/src/ckanext-LDM_SPARQL/ckanext/ldm_sparql'
        self.RDFizer_temp_folder = self.plugin_path + '/temp'
        self.RDFizer_config_file = self.RDFizer_temp_folder + '/RDFizer_config.ini'
        self.RDFizer_mapping_path = self.plugin_path + '/RDFizer_mappings'
        self.RDFizer_output_folder = output_folder

        self.RDFizer_mapping_file = self.RDFizer_mapping_path + '/' + mapping_file
        self.RDFizer_dataset_config = self.RDFizer_set_config(dataset_config)

        # allowed formats for convertions
        self.RDF_allowed_formats = {'turtle': 'ttl', 'xml': 'xml', 'pretty-xml': 'xml', 'json-ld': 'json',
                           'nt': 'nt', 'n3': 'n3', 'trig': 'trig'}

        # Virtuoso Endpoint Config
        self.ViruosoEndpointEnabled = toolkit.asbool(config.get('LDMSPARQL_ENDPOINT_ENABLED', False))
        self.VirtuosoGraph = config.get("LDMSPARQL_ENDPOINT_GRAPH", 'http://localhost:8890/')
        self.pubbyURL = config.get("LDMSPARQL_PUBBY_URL", 'http://localhost:8081/pubby/')

    def RDFizer_set_config(self, dataset_config):

        dataset_config_default = {
            "output_folder": self.RDFizer_output_folder,
            "remove_duplicate": "yes",
            "all_in_one_file": "no",
            "name": "XXX",
            "enrichment": "yes",
            "ordered": "yes",
            "output_format": "n-triples"
        }

        # The config in parameter can just include the values to be changed from default
        for key, value in dataset_config.items():
            if key in dataset_config_default:
                dataset_config_default[key] = value

        self._write_config_file(dataset_config_default)
        return dataset_config_default

    def _write_config_file(self, config_values):

        with open(self.RDFizer_config_file, 'w') as f:
            f.write("[datasets]"+'\n')
            f.write("number_of_datasets: 1"+'\n')
            for key,value in config_values.items():
                f.write(key + ": " + value + '\n')
            f.write('\n'+"[dataset1]"+'\n')
            f.write('name: '+ config_values["name"]+'\n')
            f.write('mapping: '+ self.RDFizer_mapping_file)

    def run_RDFizer(self):

        semantify(self.RDFizer_config_file)

    def get_LDM_local_datasets_list(self):
        '''
            Returns: a dictionary with the list of datasets or an empty dict
        '''
        context = {'model': model, 'session': model.Session, 'ignore_auth': True, 'user': 'admin'}
        try:
            result = self.action_package_list(context, {})
        except NotFound as e:
            return {}
        return result


    def get_LDM_local_dataset(self, id):
        # https://docs.ckan.org/en/2.9/api/#ckan.logic.action.get.package_show
        # Note: Returns data even with dataset deleted => ds['state'] = 'deleted'
        params = {'id': id}
        context = {'model': model, 'session': model.Session, 'ignore_auth': True, 'user': 'admin'}
        #context['return_id_only'] = False
        #context = {}

        try:
             result = self.action_package_show(context, params)
        except NotFound as e:
            return {}
        return result

    def get_LDM_local_organization(self, id):

        # Just retrieve basic organixation metadata
        # https://docs.ckan.org/en/2.9/api/#ckan.logic.action.get.organization_show
        params = {'id': id,
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


    def write_dataset_dict_to_json_file(self, file_path, ds_dict):
        with open(file_path, 'w') as fp:
            json.dump(ds_dict, fp, indent=4)

    def preprocess_organization_dict(self, org_dict):

        org_dict['description'] = org_dict['description'].replace('\n', '')
        org_dict['description'] = org_dict['description'].replace('\r', '')

        return org_dict

    def preprocess_dataset_dict(self, dataset_dict):

        url = self._get_dataset_url_from(dataset_dict)
        # Adding URL to dict
        dataset_dict['url'] = url
        # Addiong URL_base_authors
        dataset_dict['url_base_authors'] = self._get_authors_base_url_from(dataset_dict)

        #Adding DOI to other fields
        fields = ["extra_authors", "resources", "tags"]

        # ORCID
        if 'orcid' in dataset_dict and dataset_dict['orcid']:
            dataset_dict['orcid'] = "https://orcid.org/" + self._clean_whitespaces(dataset_dict['orcid'])
        else:
            dataset_dict['orcid'] = self._search_orcid(dataset_dict['author'])
            # if not dataset_dict['orcid']:
            #     dataset_dict.pop('orcid')

        for field in fields:
            if field in dataset_dict:
                for data_instance in dataset_dict[field]:

                    # size in resources of type URL causing errors
                    if field == "resources":
                        # url is overlapping dataset url
                        data_instance['resource_url'] = self._get_resource_url_from(data_instance)
                        data_instance['download_url'] = data_instance['url']
                        if 'size' in data_instance and not data_instance['size']:
                            data_instance['size'] = ''
                        # descriptions causing errors
                        if 'description' in data_instance:
                            data_instance['description'] = data_instance['description'].replace('\n', '')
                            data_instance['description'] = data_instance['description'].replace('\r', '')
                    elif field == 'tags':
                        data_instance['tag_url'] = self._get_tag_url_from(data_instance)
                        wikidata_link = self._search_wikidata_entity_link_for_keyword(data_instance['display_name'])
                        dbpedia_link = self._search_dbpedia_entity_link_for_keyword(data_instance['display_name'])
                        if wikidata_link:
                            data_instance['wikidata_link'] = wikidata_link
                        if dbpedia_link:
                            data_instance['dbpedia_link'] = dbpedia_link

                    elif field == 'extra_authors':
                        if 'orcid' in data_instance and data_instance['orcid']:
                            data_instance['orcid'] = "https://orcid.org/" + self._clean_whitespaces(data_instance['orcid'])
                        else:
                            data_instance['orcid'] = self._search_orcid(data_instance['extra_author'])
                        data_instance['url_base_authors'] = dataset_dict['url_base_authors']
                    # For all
                    data_instance['url'] = url

        # returns in descriptions causes error
        dataset_dict['notes'] = dataset_dict['notes'].replace('\n', '')
        dataset_dict['notes'] = dataset_dict['notes'].replace('\r', '')
        dataset_dict['organization']['description'] = dataset_dict['organization']['description'].replace('\n', '')
        dataset_dict['organization']['description'] = dataset_dict['organization']['description'].replace('\r', '')

        # Dataset-Dataservice relationships
        # "datasets_served_list": "d1beaa8b-bba9-4f5f-b85e-644e339faac2,1abefb2e-6a83-4004-b7db-74c34b545d2e",
        # "services_used_list": "1d67f22f-9f51-4301-9a9c-3682f39ffafe",
        # "extra_authors": [
        #     {   "doi": "10.57702/y89qq7yc",
        #         "extra_author": "Autor2",
        #         "orcid": "38947593457"
        #     }
        # ],
        #services_used_list = dataset_dict.get('services_used_list', '')
        datasets_served_list = dataset_dict.get('datasets_served_list', '')

        if datasets_served_list:
            ds_list = datasets_served_list.split(',')
            result_list = []
            for ds in ds_list:
                related_dataset = self.get_LDM_local_dataset(ds)
                related_ds_url = self._get_dataset_url_from(related_dataset)
                result_list.append({'url': url, 'related_ds_url': related_ds_url})
            dataset_dict["datasets_served_list"] = result_list

        dataset_dict["organization"]["organization_url"] = self._get_organization_url_from(dataset_dict)

        return dataset_dict
    def _clean_whitespaces(self, target_str):
        target_str = target_str.replace('\n', '')
        target_str = target_str.replace('\r', '')
        target_str = target_str.replace(' ', '')
        target_str = target_str.replace('   ', '')
        return target_str


    def _get_dataset_url_from(self, dataset_dict):
        if self.ViruosoEndpointEnabled:
            url = self.pubbyURL + dataset_dict['id']
        else:
            url = self.home_url + "/" + dataset_dict['type'] + "/" + dataset_dict['id']
        return url

    def _get_organization_url_from(self, dataset_dict):
        if self.ViruosoEndpointEnabled:
            url = self.pubbyURL + 'org-' + dataset_dict['organization']['id']
        else:
            url = self.home_url + "/organization/" + dataset_dict['organization']['id']
        return url

    def _get_organization_url_from_org_dict(self, org_dict):
        simul_ds_dict = {'organization': org_dict}
        return self._get_organization_url_from(simul_ds_dict)

    def _get_tag_url_from(self, tag_dict):
        if self.ViruosoEndpointEnabled:
            url = self.pubbyURL + "tag-" + tag_dict['id']
        else:
            url = self.home_url + "/dataset/?tags=" + tag_dict['name'].replace(" ","+")
        return url

    def _get_resource_url_from(self, resource_dict):
        if self.ViruosoEndpointEnabled:
            url = self.pubbyURL + "resource-" + resource_dict['id']
        else:
            url = resource_dict['url']
        return url

    def _get_authors_base_url_from(self, dataset_dict):
        if self.ViruosoEndpointEnabled:
            url = self.pubbyURL + 'author-'
        else:
            url = self.home_url + "/dataset/?q="
        return url


    def convert_dataset_dict_to_DCAT(self, dataset_dict):

        # get Dataset Name
        dataset_name = dataset_dict.get('name', None)
        if dataset_name is None:
            return

        if dataset_dict:
            log.info("Converting Dataset to N3: " + dataset_name)

            temp_json_file = self.RDFizer_temp_folder + "/temp.json"

            # RDFizer set current dataset name
            rdfizer_config = {
                "name": dataset_name,
            }

            # RDFizer set current mapping file
            mapping_file = self.RDFizer_default_dataset_mapping
            if dataset_dict.get('type', '') == 'service':
                mapping_file = self.RDFizer_default_dataservice_mapping
            self.RDFizer_mapping_file = self.RDFizer_mapping_path + '/' + mapping_file

            self.RDFizer_set_config(rdfizer_config)

            dataset_dict = self.preprocess_dataset_dict(dataset_dict)

            # save dataset as temporal file
            self.write_dataset_dict_to_json_file(temp_json_file, dataset_dict)

            # RDFizer RUN
            self.run_RDFizer()

            # delete temporal file
            if os.path.exists(temp_json_file):
                os.remove(temp_json_file)

    def convert_organization_dict_to_DCAT(self, organization_dict):

        # get Dataset Name
        organization_name = organization_dict.get('name', None)
        if organization_name is None:
            return

        if organization_dict:
            log.info("Converting Dataset to N3: " + organization_name)

            temp_json_file = self.RDFizer_temp_folder + "/temp.json"

            # RDFizer set current dataset name
            rdfizer_config = {
                "name": organization_name,
            }

            # RDFizer set current mapping file
            mapping_file = self.RDFizer_default_dataset_mapping
            self.RDFizer_mapping_file = self.RDFizer_mapping_path + '/' + "organization.ttl"

            self.RDFizer_set_config(rdfizer_config)

            #organization_dict = self.preprocess_dataset_dict(organization_dict)
            log.info(organization_dict)

            # save dataset as temporal file
            self.write_dataset_dict_to_json_file(temp_json_file, organization_dict)

            # RDFizer RUN
            self.run_RDFizer()

            # delete temporal file
            if os.path.exists(temp_json_file):
                os.remove(temp_json_file)


    def convert_all_datasets_to_DCAT(self, start_at=0):
        dataset_list = self.get_LDM_local_datasets_list()
        start_at = int(start_at)

        for dataset_name in dataset_list[start_at:]:
            dataset_dict = self.get_LDM_local_dataset(dataset_name)
            self.convert_dataset_dict_to_DCAT(dataset_dict)

    def convert_RDF_to_format(self, source_file, rdf_format, output_file_name, output_folder='default'):

        if output_folder == 'default':
            output_folder = self.RDFizer_output_folder+'/parsed'
            if not os.path.exists(output_folder):
                os.mkdir(output_folder)

        '''   
        'RDF_Format': 'Turtle'
        'keyword': 'turtle, ttl or turtle2'
        'Notes': 'turtle2 is just turtle with more spacing & linebreaks'

        'RDF_Format': 'RDF/XML'
        'keyword': 'xml or pretty-xml'
        'Notes': 'Was the default format, rdflib < 6.0.0'

        'RDF_Format': 'JSON-LD'
        'keyword': 'json-ld'
        'Notes': 'There are further options for compact syntax and other JSON-LD variants'

        'RDF_Format': 'N-Triples'
        'keyword': 'ntriples, nt or nt11'
        'Notes': 'nt11 is exactly like nt, only utf8 encoded'

        'RDF_Format': 'Notation-3'
        'keyword': 'n3'
        'Notes': 'N3 is a superset of Turtle that also caters for rules and a few other things'

        'RDF_Format': 'Trig'
        'keyword': 'trig'
        'Notes': 'Turtle-like format for RDF triples + context (RDF quads) and thus multiple graphs'

        'RDF_Format': 'Trix'
        'keyword': 'trix'
        'Notes': 'RDF/XML-like format for RDF quads'

       'RDF_Format': 'N-Quads'
        'keyword': 'nquads'
        'Notes': 'N-Triples-like format for RDF quads'
        '''

        allowed_formats = self.RDF_allowed_formats

        if rdf_format in allowed_formats.keys():
            g = Graph()
            g.parse(source_file, format='n3')
            output_file = output_folder + '/' + output_file_name
            g.serialize(format=rdf_format, destination=output_file)

    def get_DCAT_data_from_file(self, dcat_file):

        with open(dcat_file, 'r') as f:
            dcat_data = f.read()
        return dcat_data

    def get_DCAT_data_from(self, ds_name, out_format):

        # check ds_name exists
        dataset_dict = self.get_LDM_local_dataset(ds_name)
        if not dataset_dict:
            return {}

        allowed_formats = self.RDF_allowed_formats
        ext = ''
        if out_format in allowed_formats:
            ext = allowed_formats[out_format]
        else:

            log.error("ERROR: FORMAT "+out_format+" NOT ALLOWED.")
            return {}

        dcat_data = ''
        subfolder = ''
        if out_format != 'nt':
            subfolder = '/parsed'
        file_name = self.RDFizer_output_folder +subfolder+'/'+ds_name+'.'+allowed_formats[out_format]
        file_name_nt = self.RDFizer_output_folder +'/'+ds_name+'.nt'

        if os.path.exists(file_name):
            dcat_data = self.get_DCAT_data_from_file(file_name)
        else:
            # generate nt file
            if out_format == 'nt' or not os.path.exists(file_name_nt):
                self.convert_dataset_dict_to_DCAT(dataset_dict)
            if out_format != 'nt':
                file_name_aux = ds_name + '.' + allowed_formats[out_format]
                self.convert_RDF_to_format(file_name_nt, out_format, file_name_aux)

        dcat_data = self.get_DCAT_data_from_file(file_name)

        return dcat_data
    def delete_RDF_parsed_files_for_dataset(self, dataset_name):

        allowed_formats = self.RDF_allowed_formats
        for f in allowed_formats.keys():
            file_name = self.RDFizer_output_folder+'/parsed/'+dataset_name + '.' + allowed_formats[f]
            if os.path.exists(file_name):
                os.remove(file_name)


    def _search_orcid(self, author_names):
        orcid_util = ORCID_Util()
        return orcid_util.search_orcid(author_names)

    def _search_wikidata_entity_link_for_keyword(self, keyword_txt):
        falcon_util = Falcon_Util()
        return falcon_util.get_wikidata_link_from_keyword(keyword_txt)

    def _search_dbpedia_entity_link_for_keyword(self, keyword_txt):
        falcon_util = Falcon_Util()
        return falcon_util.get_dbpedia_link_from_keyword(keyword_txt)

    def copy_Dataset_RDFfile_to_folder(self, ds_name, destination_folder):

        # check ds_name exists
        dataset_dict = self.get_LDM_local_dataset(ds_name)
        if not dataset_dict:
            return "ERROR: Dataset name is not valid."
        if not os.path.exists(destination_folder):
            return "ERROR: Destination folder is not valid."

        file_name = ds_name + '.nt'
        file_name_nt = self.RDFizer_output_folder + '/' + file_name
        file_name_destination = destination_folder + '/' + file_name
        if not os.path.exists(file_name_nt):
            self.convert_dataset_dict_to_DCAT(dataset_dict)
        if os.path.exists(file_name_nt):
            os.system('cp ' + file_name_nt + ' ' + file_name_destination)
            return "File " + file_name_destination + " was created."
        else:
            return "ERROR generating file " + file_name_nt

    def get_DCAT_RDF_raw_data(self, ds_name):

        # check ds_name exists
        dataset_dict = self.get_LDM_local_dataset(ds_name)
        if not dataset_dict:
            log.error(f"ERROR: Dataset name or id: {ds_name} is not valid.")
            return {}

        # this line allows using name or id
        ds_name = dataset_dict['name']

        file_name = ds_name + '.nt'
        file_name_nt = self.RDFizer_output_folder + '/' + file_name

        if not os.path.exists(file_name_nt):
            self.convert_dataset_dict_to_DCAT(dataset_dict)
        if os.path.exists(file_name_nt):
            return self.get_DCAT_data_from_file(file_name_nt)
        else:
            log.error("ERROR generating file " + file_name_nt)
            return {}

    def get_DCAT_RDF_raw_data_org(self, org_name):

        # check ds_name exists
        orga_dict = self.get_LDM_local_organization(org_name)
        if not orga_dict:
            log.error(f"ERROR: Dataset name or id: {org_name} is not valid.")
            return {}

        # this line allows using name or id
        orga_name = orga_dict['name']

        file_name = orga_name + '.nt'
        file_name_nt = self.RDFizer_output_folder + '/' + file_name

        self.convert_organization_dict_to_DCAT(orga_dict)
        if os.path.exists(file_name_nt):
            return self.get_DCAT_data_from_file(file_name_nt)
        else:
            log.error("ERROR generating file " + file_name_nt)
            return {}