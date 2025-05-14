import urllib.parse
from xml.etree import ElementTree

import requests
from ckanext.tibimport.logic2 import DatasetParser
import json
from ckanext.tibimport.dataCite_API_Search import dataCite_API_Search
import time
# pip install selenium webdriver-manager
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager
import requests
import copy
import traceback

from ckanext.tibimport.open_licenses import open_access_licenses
class LEUPHANA_ParserProfile(DatasetParser):
    '''

    A class defined to access leuphana's Datasets
    using the DataCite API (https://api.datacite.org/dois) harvesting DOI metadata for the Datasets published by 
    "Leuphana Uninversität Lünenburg"
    Leuphana's website: https://pubdata.leuphana.de/.
    Requirement: import only Datasets and only open (free to access).

    '''

    def __init__(self):
        self.repository_name = "leuphana (The repository of the Leuphana University Lüneburg)"
        self.dataset_title_prefix = "leu-"

        self.current_dataset_schema = "Schema 4"        
        
        # DataCite API config
        self.publisher_name = "Leuphana Universität Lüneburg"
        self.resource_type = "Dataset"
        self.filter_open_licenses = True
        # records for page retrieved by API
        self.page_size = 50
        self.max_pages = 100
        self.DataCite_api = dataCite_API_Search(self.publisher_name, self.resource_type, self.filter_open_licenses, self.page_size, self.max_pages)

        # Set to True to force update of all datasets
        self.force_update = False

        # Total of datasets available in leuphana
        self.total_leuphana_datasets = 0

        # schema validation report
        self.current_schema_report = {}


        self.log_file_prefix = "LEU_"
        super().__init__()


    def get_all_datasets_dicts(self):
        '''
             Using DataCite API get a list of dictionaries with the complete Dataset's
             metadata inside.
             
             Notice: Dataset's dictionaries must be adapted to CKAN schema

             Returns: an array of  dictionary with the list of datasets or an empty array
        '''

        ds_list = []
        ds_list = self.get_datasets_list()


        dict_list = []
        for dataset in ds_list:
            #dict_list.append(self.parse_leuphana_RECORD_DICT_to_LDM_CKAN_DICT(dataset))
            dict_list.append(dataset)

        return dict_list

    def get_datasets_list(self, ds_list=[]):
        '''
            Uses the DataCite API to retrieve a list of datasets in a list of dictionaries

            Returns: a list of datasets or an empty list
            Notice: the dictionaries contains metadata NOT in CKAN's schema
        '''
        self.set_log("infos_searching_ds")

        
        # Find all Datasets
        ds_list = self.DataCite_api.get_dois_by_publisher_and_type()
        
        # Filter responses to open Datasets (already filtered in the API call)
        # ds_list = self.filter_open_datasets(ds_list)
        
        # Update total of Datasets
        self.total_leuphana_datasets = len(ds_list)
        return ds_list


    def get_remote_datasets_paged(self, resumption_token="1"):
        '''
         Uses the DataCite API to retrieve a list of datasets in a list of dictionaries
         Returns: a list of datasets or an empty list
         Notice: the dictionaries contains metadata NOT in CKAN's schema
        '''
        self.set_log("infos_searching_ds")

        page = int(resumption_token)

        # Find page of Datasets
        ds_list, total_records, total_pages = self.DataCite_api.get_dois_page(page)
        
        ds_list = self.DataCite_api.get_dois_page(page)

        # get schema data only first time
        if not self.current_schema_report:
            self.current_schema_report = self._get_schema_report()

        # Filter responses to open Datasets (already filtered in API call)
        # ds_list = self.filter_open_datasets(ds_list)

        # Update total of Datasets
        self.total_leuphana_datasets += len(ds_list)
        
        # GET RESUMPTION TOKEN FROM xml_tree_data
        pages_to_fetch = min(total_pages, self.max_pages)
        resumption_token = str(page +1) if page < pages_to_fetch else ""
        
        # Convert dics to LDM-CKAN dicts
        dict_list = []
        for dataset in ds_list:
            dict_list.append(self.parse_leuphana_RECORD_DICT_to_LDM_CKAN_DICT(dataset))

        return {"ds_list": dict_list, "resumptionToken": resumption_token}


    # def is_open_dataset(self, ds_dict):
    #     # header': {'json_ld': {'license': ['https://creativecommons.org/licenses/by/4.0/legalcode']}} 
    #     license_list = ds_dict.get('header', {}).get('json_ld', {}).get('license', [])
    #     is_open = False
    #     for license in license_list:
    #         if 'creativecommons.org' in license or 'opendatacommons.org' in license:
    #             is_open = True
    #     return is_open

    # def is_dataset_type(self, ds_dict):
    #      # type_list = 'resourceType': [{'type': {'type': 'Dataset'}}]}}}
    #     ds_types = ds_dict.get('metadata', {}).get('leuphanaDataset', {}).get('resourceType', [])
    #     for ds_type in ds_types:
    #         if 'Dataset' in ds_type['type']['type']:
    #             return True
    #     #print("\nFALSE DS TYPE:\n", ds_dict)    
    #     return False

    # def filter_dataset_type(self, ds_list):
    #     ds_list_result = []
        
    #     for dataset in ds_list:
    #         if self.is_dataset_type(dataset):
    #             ds_list_result.append(dataset)
    #     return ds_list_result   
        
    # def filter_open_datasets(self, ds_list):
        
    #     ds_list_result = []
        
    #     for dataset in ds_list:
    #         if self.is_open_dataset(dataset):
    #             ds_list_result.append(dataset)
    #     return ds_list_result   


    def parse_leuphana_RECORD_DICT_to_LDM_CKAN_DICT(self, leuphana_dict):

        ldm_dict = self._get_LDM_vdataset_template()
        leuphana_metadata = leuphana_dict['metadata']['leuphanaDataset']
        leuphana_metadata_json = leuphana_dict['header']['json_ld']

        # idenfier
        identifier_type = "DOI"
        identifier = self._get_leuphana_value(leuphana_metadata, ['identifier'])
        datestamp = self._get_leuphana_value(leuphana_dict['header'], ['datestamp'])
        publication_year = self._get_leuphana_value(leuphana_metadata_json, ['datePublished'])
        if not publication_year:
            publication_year = datestamp.split('-')[0]

        if identifier_type == 'DOI':
            ldm_dict['doi'] = identifier
            ldm_dict['doi_date_published'] = publication_year
            ldm_dict['url'] = 'https://doi.org/' + identifier

        # Creation date
        ldm_dict['source_metadata_created'] = publication_year

        # creators
        #print("\n\nDOI:\n", identifier)
        ldm_dict = self._get_leuphana_creators(leuphana_metadata, ldm_dict)

        # title
        title = self._get_leuphana_title(leuphana_metadata, ldm_dict)
        name = self.adjust_dataset_name(identifier_type+'-'+identifier)
        ldm_dict['title'] = title.capitalize()
        ldm_dict['name'] = name

        # rights
        rights = leuphana_metadata_json.get('license', [])
        if rights:
            ldm_dict['license_id'] = rights[0]
            ldm_dict['license_title'] = self._get_license_title(rights[0])

        # descriptions
        ldm_dict = self._get_leuphana_description(leuphana_metadata, ldm_dict)

        # publishers
        ldm_dict = self._get_leuphana_publishers(leuphana_metadata, ldm_dict)

        # publication year
        if publication_year:
            ldm_dict['publication_year'] = publication_year

        # subject areas
        ldm_dict = self._get_leuphana_subject_areas(leuphana_metadata, ldm_dict)

        # resource type
        resource_type = self._get_leuphana_value(leuphana_metadata_json, ['resourceType', 'type', 'type'])
        ldm_dict['resource_type'] = resource_type

        # related identifiers
        #ldm_dict = self._get_leuphana_related_identifiers(leuphana_metadata, ldm_dict)

        return ldm_dict

    def _get_license_title(self, license_id):

        for license in open_access_licenses:
            if license_id in license['url'] or license_id in license['legalcode_url']:
                return license['title']
        return ""    

    def _get_leuphana_title(self, leuphana_metadata, ldm_dict):

        titles = leuphana_metadata.get('titles', {})
        title_txt = ""

        for title in titles:
            title_txt = title.get("title", "").get('title', "")
            break # just take first one
            
        return title_txt
    
    def _get_leuphana_description(self, leuphana_metadata, ldm_dict):

        description_txt = leuphana_metadata.get('header', {}).get('json_ld', {}).get('description', "")
        
        ldm_dict['notes'] = description_txt
        return ldm_dict

    def _get_leuphana_creators(self, leuphana_metadata, ldm_dict):

        creators = leuphana_metadata.get('creators', [])
        extra_authors = []
        pos = 1
        for creator in creators:
            orcid = self._get_leuphana_value(creator, ['orcid'])
            givenName = self._get_leuphana_value(creator, ['givenName'])
            familyName = self._get_leuphana_value(creator, ['familyName'])
            if isinstance(orcid, list) and len(orcid)>0:
                orcid = orcid[0]
            if isinstance(givenName, list) and len(givenName)>0:
                givenName = givenName[0]
            if isinstance(familyName, list) and len(familyName)>0:
                familyName = familyName[0]
                
            name = familyName + ', ' + givenName
                 
            # first is author
            if pos == 1:
                ldm_dict['author'] = name
                ldm_dict['givenName'] = givenName
                ldm_dict['familyName'] = familyName
                ldm_dict['orcid'] = orcid
                if not ldm_dict['givenName'] and not ldm_dict['familyName'] and ldm_dict['author']:
                    ldm_dict['givenName'] = ldm_dict['author'].split(',')[-1].strip()
                    ldm_dict['familyName'] = ldm_dict['author'].split(',')[0].strip()

                pos += 1
            else:
                # following are extra_authors
                extra_author = {"extra_author": name,
                                "givenName": givenName,
                                "familyName": familyName,
                                "orcid": orcid}
                if not extra_author['givenName'] and not extra_author['familyName'] and extra_author['extra_author']:
                       extra_author['givenName'] = extra_author['extra_author'].split(',')[-1].strip()
                       extra_author['familyName'] = extra_author['extra_author'].split(',')[0].strip()
                extra_authors.append(extra_author)
        if extra_authors:
            ldm_dict['extra_authors'] = extra_authors

        return ldm_dict

    def _get_leuphana_keywords(self, leuphana_metadata, ldm_dict):

        keywords = leuphana_metadata.get('keywords', [])
        tag_list = []

        for keyword in keywords:
            tag = self._get_leuphana_value(keyword, ['keyword', 'keyword'])
            # create ckan tag dict
            # some cases are ; separated list of tags
            tag = tag.replace(';', ',')
            # some cases are "·" separated list of tags
            tag = tag.replace('·', ',')
            if ',' in tag: # some cases are comma separated list of tags
                for t in tag.split(','):
                    t = self._adjust_tag(t)
                    if t: # some cases list end with comma ,
                        tag_dict = { "display_name": t,
                                     "name": t,
                                     "state": "active",
                                     "vocabulary_id": None}
                        tag_list.append(tag_dict)
            else:
                tag = self._adjust_tag(tag)
                if tag:
                    tag_dict = {"display_name": tag.strip(),
                                "name": tag.strip(),
                                "state": "active",
                                "vocabulary_id": None}
                    tag_list.append(tag_dict)

        if tag_list:
            ldm_dict['tags'] = tag_list

        return ldm_dict

    def _adjust_tag(self, tag):
        PERMITTED_CHARS = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-_. "
        tag = tag.replace("/", "-") # some tags have / chars
        tag = "".join(c for c in tag if c in PERMITTED_CHARS)  # some tags has no permitted chars
        tag = tag.strip()
        # In CKAN tags minimum lenght is 2
        if len(tag) < 2:
            tag = ''
        # In CKAN tag long max = 100
        tag = tag[:100]
        return tag

    def _get_leuphana_publishers(self, leuphana_metadata, ldm_dict):

        publisher = "Medien- und Informationszentrum, Leuphana Universität Lüneburg"
        
        ldm_dict['publishers'] = [{'publisher': publisher}]

        return ldm_dict

    def _get_leuphana_subject_areas(self, leuphana_metadata, ldm_dict):

        s_areas = leuphana_metadata.get('keywords', [])
        s_areas_list = []

        for name in s_areas:
            # create ckan subject areas dict
            s_area_dict = {"subject_area_name": name }
            s_areas_list.append(s_area_dict)
        if s_areas_list:
            ldm_dict['subject_areas'] = s_areas_list

        return ldm_dict

    def _get_leuphana_related_identifiers(self, leuphana_metadata, ldm_dict):

        r_identifiers = leuphana_metadata.get('relatedIdentifiers', [])
        r_identifiers_list = []

        for r_id in r_identifiers:
            identifier = self._get_leuphana_value(r_id, ['relatedIdentifier', 'relatedIdentifier'])
            id_type = self._get_leuphana_value(r_id, ['relatedIdentifierType'])
            id_relation = self._get_leuphana_value(r_id, ['relationType'])
            # create ckan related identifiers dict
            r_identifier_dict = { "identifier": identifier,
                            "identifier_type": id_type,
                            "relation_type": id_relation}
            r_identifiers_list.append(r_identifier_dict)
        if r_identifiers_list:
            ldm_dict['related_identifiers'] = r_identifiers_list

        return ldm_dict

    def _get_leuphana_value(self, leuphana_metadata, list_fields=[]):

        mt_dict = leuphana_metadata
        value = ""

        for field in list_fields:
            if isinstance(mt_dict, dict) and field in mt_dict:
                mt_dict = mt_dict[field]
                if not isinstance(mt_dict, dict):
                    value = mt_dict
            elif isinstance(mt_dict, dict):
                value = mt_dict.get(field, "")
            else:
                value = mt_dict   

        return value

    def _get_LDM_vdataset_template(self):
        #datetime.datetime.now().isoformat()



        LDM_imported_vdataset = {
            "repository_name": self.repository_name,
            "type": "vdataset",
            "source_metadata_created": "",
            "source_metadata_modified": "",
            "owner_org": "leuphana",
            "author": "",
            "author_email": "",
        #     "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700",
             "doi": "",
             "doi_date_published": "",
             "doi_publisher": "",
             "doi_status": "True",
        #     "domain": "https://data.uni-hannover.de",
        #     "have_copyright": "Yes",
        #     "id": "7e6929b4-0aa0-44b4-9a1c-29d42bb78aa3",
        #     "isopen": False,
             "license_id": "",
             "license_title": "",
        #     "maintainer": "Clemens Huebler",
        #     "maintainer_email": "c.huebler@isd.uni-hannover.de",
        #     "metadata_created": "2021-10-07T09:58:55.243407",
        #     "metadata_modified": "2021-10-07T09:58:55.243416",
             "name": "",
             "notes": "",
        #     "num_resources": 2,
        #     "num_tags": 3,
             "organization": self._get_leuphana_organization_ckan_dict(),
        #         "id": "3d4e7da1-a0ef-4af1-9c07-56cf5e35084d",
        #         "name": "institut-fur-statik-und-dynamik",
        #         "title": "Institut für Statik und Dynamik",
        #         "type": "organization",
        #         "description": "(Institute of Structural Analysis) \r\nAppelstraße 9A \r\n__30167 Hannover (Germany)__\r\n\r\nhttps://www.isd.uni-hannover.de/en/institute/",
        #         "image_url": "",
        #         "created": "2021-10-07T11:46:15.762388",
        #         "is_organization": True,
        #         "approval_status": "approved",
        #         "state": "active"
        #     },
        #     "owner_org": "3d4e7da1-a0ef-4af1-9c07-56cf5e35084d",
        #     "private": False,
        #     "production_year": "2022",
        #     "publication_year": "2022",
        #     "resource_type": "Dataset",
        #     "repository_name": "Leibniz University Hannover",
        #     "services_used_list": "",
        #     "source_metadata_created": "2020-06-29T13:56:20.726566",
        #     "source_metadata_modified": "2021-07-06T09:21:41.322946",
        #     "state": "active",
        #     "terms_of_usage": "Yes",
             "title": "",
        #     "type": "vdataset",
             "url": "",
             "citation": [],
        #     "version": "",
        #     "publishers": [
        #         {
        #             "publisher": "publisher1"
        #         },
        #         {
        #             "publisher": "publisher2"
        #         }
        #     ],
        # #     "resources": [
        #         {
        #             "cache_last_updated": None,
        #             "cache_url": None,
        #             "created": "2020-06-29T13:56:24.253776",
        #             "datastore_active": False,
        #             "description": "",
        #             "downloadall_datapackage_hash": "98b5bd1da7a98e0a79ab9dae7e68f8cd",
        #             "downloadall_metadata_modified": "2021-07-06T09:21:25.079814",
        #             "format": "ZIP",
        #             "hash": "",
        #             "id": "da3a4b40-c6b3-42de-87a4-4ea60c441910",
        #             "last_modified": "2021-07-06T09:21:36.339262",
        #             "metadata_modified": "2021-10-07T09:58:55.231269",
        #             "mimetype": "application/zip",
        #             "mimetype_inner": None,
        #             "name": "All resource data",
        #             "package_id": "7e6929b4-0aa0-44b4-9a1c-29d42bb78aa3",
        #             "position": 0,
        #             "resource_type": None,
        #             "revision_id": "5b858701-baff-4dff-86a8-06cb0c01f224",
        #             "size": 875,
        #             "state": "active",
        #             "url": "https://data.uni-hannover.de/dataset/7e6929b4-0aa0-44b4-9a1c-29d42bb78aa3/resource/da3a4b40-c6b3-42de-87a4-4ea60c441910/download/windturbine-simulation-for-meta-modelling-otpq81.zip",
        #             "url_type": ""
        #         },
        #         {
        #             "cache_last_updated": None,
        #             "cache_url": None,
        #             "created": "2020-06-29T13:59:45.579275",
        #             "datastore_active": False,
        #             "description": "This data set correlates environmental conditions acting on an offshore wind turbine (inputs) with fatigue loads of the turbine (outputs).\r\nThe investigated wind turbine is the NREL 5MW reference turbine and the OC3 monopile.\r\nEnvironmental conditions are based on FINO3 data (https://www.fino3.de/en/).\r\nTime series of bending moments and shear forces at mudline and blade root bending moments are computed using the FASTv8 simulation code by the NREL.\r\n10.000 simulations for varying environmental conditions (and varying random seeds) were conducted.\r\nShort-term damage equivalent loads (DELs) representing fatigue were calculated for several relevant positions (at mudline and at the blade root).",
        #             "format": "TXT",
        #             "hash": "",
        #             "id": "0f24dea1-53b3-4cb9-afa4-16b342524aa8",
        #             "last_modified": "2020-06-29T13:59:45.533215",
        #             "metadata_modified": "2021-10-07T09:58:55.233372",
        #             "mimetype": "text/plain",
        #             "mimetype_inner": None,
        #             "name": "Metamodeldata.txt",
        #             "package_id": "7e6929b4-0aa0-44b4-9a1c-29d42bb78aa3",
        #             "position": 1,
        #             "resource_type": None,
        #             "revision_id": "f5dad358-82bc-44cd-84a8-5f68f14a774e",
        #             "size": 1142901,
        #             "state": "active",
        #             "url": "https://data.uni-hannover.de/dataset/7e6929b4-0aa0-44b4-9a1c-29d42bb78aa3/resource/0f24dea1-53b3-4cb9-afa4-16b342524aa8/download/metamodeldata.txt",
        #             "url_type": ""
        #         }
        #     ],
        #     "subject_areas": [
        #         {
        #             "subject_area_additional": "addarea1",
        #             "subject_area_name": "area1"
        #         },
        #         {
        #             "subject_area_additional": "addarea2",
        #             "subject_area_name": "area2"
        #         }
        #     ],
        #     "tags": [
        #         {
        #             "display_name": "FAST",
        #             "id": "235ed4d9-3def-4174-bb4d-51950abe8813",
        #             "name": "FAST",
        #             "state": "active",
        #             "vocabulary_id": None
        #         },
        #         {
        #             "display_name": "meta-model",
        #             "id": "2c83feeb-a00e-4821-91b1-c42fb828a3ad",
        #             "name": "meta-model",
        #             "state": "active",
        #             "vocabulary_id": None
        #         },
        #         {
        #             "display_name": "wind energy",
        #             "id": "81223f1d-955d-4ff4-8be0-1fda56b540ba",
        #             "name": "wind energy",
        #             "state": "active",
        #             "vocabulary_id": None
        #         }
        #     ],
        #     "groups": [],
        #     "relationships_as_subject": [],
        #     "relationships_as_object": []
         }
        return LDM_imported_vdataset

    def check_current_schema(self):
        '''
            Using the leuphana harvesting tool determine if the current schema is matching the schema implemented.
            Returning a dict with the results of comparing the metadata schema used in the code
            with the metadata schema retrieved by remote servers

            result = {'status_ok': True,
                      'report': 'Text explaining the results'}
        '''

        if not self.current_schema_report:
            self.current_schema_report = self._get_schema_report()

        return self.current_schema_report


    def _get_schema_report(self, obj_tree=None):

        # No info to check schema on this profile
        current_schema = {'current_leuphana_schema': self.current_dataset_schema,
                          'current_dataset_schema': self.current_dataset_schema
                          }
        schema_ok = True
        errors = {}
        report = {'status_ok': schema_ok,
                  'report': {'current_metadata': current_schema,
                             'errors': errors},
                  }
        return report


    def get_organization(self, name='leuphana'):
        '''
            In leuphana Datasets are no related to a specific organization.
            leuphana's imported datasets allways belongs to leuphana organization in LDM.

            Returns: a dictionary with the organization's metadata
        '''

        self.set_log("infos_searching_org", name)

        org_dict = self._get_leuphana_organization_ckan_dict()

        return org_dict

    def _get_leuphana_organization_ckan_dict(self):

        org_dict = {
        "approval_status": "approved",
        "description": "The repository of the Leuphana University Lüneburg.",
        "display_name": "leuphana (The repository of the Leuphana University Lüneburg)",
        "image_display_url": "logo-leuphana.png",
        "image_url": "logo-leuphana.png",
        "is_organization": True,
        "name": "leuphana",
        "state": "active",
        "title": "Leuphana (The repository of the Leuphana University Lüneburg)",
        "type": "organization",
        }
        return org_dict

    def adjust_dataset_name(self, ds_name):

        specialChars = " /."
        for specialChar in specialChars:
            ds_name = ds_name.replace(specialChar, '-')
        ds_name = ds_name.lower()
        ds_name = self.dataset_title_prefix + ds_name
        # CKAN limits name to 100 chars
        ds_name = (ds_name[:100]).strip()
        # clean possible spetial chars
        ds_name = urllib.parse.quote(ds_name)
        return ds_name


    def should_be_updated(self, local_dataset, remote_dataset):

        if self.force_update:
            return True

        result = False
        exclude_in_comparison = ['owner_org', 'license_title', 'organization', 'subject_areas']

        for field in remote_dataset.keys():

            # special case  tags
            if field == 'subject_areas':
                for tag in remote_dataset['subject_areas']:
                    tag_name = tag['subject_area_name']
                    tag_found = False
                    for tag_local in local_dataset['subject_areas']:
                        if tag_local['subject_area_name'] == tag_name:
                            tag_found = True
                    if not tag_found:
                        result = True
                        break

            #print("\nField: ", field, " L= ", local_dataset.get(field, "KEY ERROR"), " R= ", remote_dataset[field])
            # print("\nField: ", field)

            if field in local_dataset and field not in exclude_in_comparison:
                # print("\nField: ", field, " L= ", local_dataset[field], " R= ", remote_dataset[field])
                if local_dataset[field] != remote_dataset[field]:
                    #print("\nField: ", field)
                    self.logger.message = "\nField: ", field, " L= ", local_dataset[field], " R= ", remote_dataset[field]
                    self.set_log_msg_info()
                    result = True
                    break

        return result


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
        return { "dataset_keys": dataset_keys, "resource_keys": resource_keys, "resource_types": resource_types}


# LOGGER METHODS
# **************


    def set_log(self, op, data=""):

        self.logger.message = ""

        def infos_searching_ds(data):
            self.logger.message = "Searching Datasets in leuphana's harvesting tool."

        def error_API(data):
            self.logger.message = "Error Connecting leuphana's harvesting tool: " + data

        def error_api_data(data):
            self.logger.message = "Error retrieving data from API: " + data

        def error_searching_website(data):
            self.logger.message = "Error retrieving data from Leuphana's Website: " + data

        def infos_ds_found(data):
            self.logger.message = "Number of Datasets found: " + data

        def infos_ds_metadata_found(data):
            self.logger.message = "Metadata found with name: " + data

        def infos_searching_org(data):
            self.logger.message = "Searching Organizaion in leuphana API. Name: " + data

        def infos_org_found(data):
            self.logger.message = "Organization found: " + data

        def infos_summary_log(data):
            self.logger.message = self.get_summary_log()

        result = {
            'infos_searching_ds': infos_searching_ds,
            'error_API': error_API,
            'error_api_data': error_api_data,
            'error_searching_website': error_searching_website,
            'infos_ds_found': infos_ds_found,
            'infos_ds_metadata_found': infos_ds_metadata_found,
            'infos_searching_org': infos_searching_org,
            'infos_org_found': infos_org_found,
            'infos_org_found': infos_summary_log
        }.get(op)(data)

        if op[0:5]=='infos':
            self.set_log_msg_info()
        elif op[0:5]=='error':
            self.set_log_msg_error()
    
    def set_log_info(self, msg):
        self.logger.message = msg
        self.set_log_msg_info()
