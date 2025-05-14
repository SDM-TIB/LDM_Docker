from ckanext.tibimport.logic2 import DatasetParser
import requests
import json
import xmltodict
from xml.etree import ElementTree
import urllib.parse
import ckan.lib.helpers as h
import ckan.plugins.toolkit as toolkit
from ckan.common import config

class PANGEA_ParserProfile(DatasetParser):
    '''

    A class defined to access PANGAEA's Datasets
    using the PANGAEA's harvesting tool https://ws.pangaea.de/oai/ and parsing the retrieved
    data to dataset_dic as needed by the LDM

    PANGAEA Harvesting tool docs: https://www.openarchives.org/OAI/openarchivesprotocol.html#ListRecords

    '''

    def __init__(self, topic="topicAgriculture"):
        self.repository_name = "PANGAEA (Data Publisher for Earth & Environmental Science)"
        # Website: www.pangaea.de

        self.dataset_title_prefix = "png-"
        # Ex. https://ws.pangaea.de/oai/provider?verb=ListRecords&metadataPrefix=pan_md&set=topicAgriculture

        self.pangea_metadataPrefix = 'pan_md'
        self.pangea_ListRecords_base_url = 'https://ws.pangaea.de/oai/provider?verb=ListRecords'

        self.pangea_ListRecords_url = self.pangea_ListRecords_base_url
        # Searching for Datasets on Pangea's schema
        self.pangea_ListRecords_url += '&metadataPrefix=' + self.pangea_metadataPrefix
        # Searching for topic or "Agriculture" Datasets
        self.topic = topic

        self.organization_name = "pangaea_" + self.topic.replace("topic", "").lower()
        # Keep organization created in first importation (Agriculture)
        if self.organization_name == "pangaea_agriculture":
            self.organization_name = "pangaea"

        self.pangea_ListRecords_url += '&set=' + topic
        self.pangaea_allowed_types = {"topicChemistry": "Chemistry",
                                 "topicLithosphere": "Lithosphere",
                                 "topicAtmosphere": "Atmosphere",
                                 "topicBiologicalClassification": "Biological Classification",
                                 "topicPaleontology": "Paleontology",
                                 "topicOceans": "Oceans",
                                 "topicEcology": "Ecology",
                                 "topicLandSurface": "Land Surface",
                                 "topicBiosphere": "Biosphere",
                                 "topicGeophysics": "Geophysics",
                                 "topicCryosphere": "Cryosphere",
                                 "topicLakesRivers": "Lakes & Rivers",
                                 "topicHumanDimensions": "Human Dimensions",
                                 "topicFisheries": "Fisheries",
                                 "topicAgriculture": "Agriculture"}
        
        # tools to continue execution on error
        self.last_resumption_token = ""
        force_token = config.get('force_resumption_token_pangaea', False)
        self.force_resumption_token_pangaea = toolkit.asbool(force_token)
        self.resumption_token_pangaea = config.get('resumption_token_pangaea', "")
        
        # Set to True to force update of all datasets
        self.force_update = False
        
        # Schema values
        self.ns0 = '{http://www.openarchives.org/OAI/2.0/}'
        self.ns2 = '{http://www.pangaea.de/MetaData}'
        self.pangea_schema_version = "2024-07-19"

        # Total of datasets available in PANGAEA
        self.total_pangea_datasets = 0

        # schema validation report
        self.current_schema_report = {}


        self.log_file_prefix = "PNG_"+self.topic.lower()+"_"
        super().__init__()

    def get_all_datasets_dicts(self):
        '''
             Using PANGAEA's "ListRecords" list get a list of dictionaries with the complete Dataset's
             metadata inside.
             Notice: "ListRecords" retrieves results in XML format and by blocks (pages). Uses "ResumptionToken" to
             continue listing the following records.
             Notice: Dataset's dictionaries must be adapted to CKAN schema

             Returns: an array of  dictionary with the list of datasets or an empty array
        '''

        ds_list = []
        ds_list = self.get_datasets_list()


        dict_list = []
        for dataset in ds_list:
            dict_list.append(self.parse_PANGEA_RECORD_DICT_to_LDM_CKAN_DICT(dataset))

        return dict_list

    def get_remote_datasets_paged(self, resumption_token=''):
        '''
         Uses the PANGAEA HARVESTING TOOL to retrieve a list of datasets in a list of dictionaries
         Returns: a list of datasets or an empty list
         Notice: the dictionaries contains metadata NOT in CKAN's schema
        '''
        self.set_log("infos_searching_ds")

        if not resumption_token:
            # allow continue ejecution forcing token from ckan.ini
            if self.force_resumption_token_pangaea:
                url = self.pangea_ListRecords_base_url + '&resumptionToken=' + self.resumption_token_pangaea
                self.last_resumption_token = resumption_token
            else:
                # Find first page of Datasets
                url = self.pangea_ListRecords_url

        else:
            # Find page from resumption token url
            url = self.pangea_ListRecords_base_url + '&resumptionToken=' + resumption_token
            self.last_resumption_token = resumption_token

        # Find page of Datasets
        xml_tree_data = self._get_page_of_Datasets(url)
        if xml_tree_data is None:
            return []

        # get schema data only first time
        if not self.current_schema_report:
            self.current_schema_report = self._get_schema_report(xml_tree_data)

        ds_list = self.parse_PANGEA_XML_result_to_DICT(xml_tree_data)


        # GET RESUMPTION TOKEN FROM xml_tree_data
        resumption_token = self._get_pangea_resumption_token(xml_tree_data)

        # Convert dics to LDM-CKAN dicts
        dict_list = []
        for dataset in ds_list:
            dict_list.append(self.parse_PANGEA_RECORD_DICT_to_LDM_CKAN_DICT(dataset))

        # Update total of Datasets
        self.total_pangea_datasets += len(ds_list)

        return {"ds_list": dict_list, "resumptionToken": resumption_token['resumptionToken']}

    def get_datasets_list(self, ds_list=[], resumption_token=''):
        '''
            Uses the PANGAEA HARVESTING TOOL to retrieve a list of datasets in a list of dictionaries

            Returns: a list of datasets or an empty list
            Notice: the dictionaries contains metadata NOT in CKAN's schema
        '''
        self.set_log("infos_searching_ds")

        if not resumption_token:
            # Find first page of Datasets
            url = self.pangea_ListRecords_url

        else:
            # Find page from resumption token url
            url = self.pangea_ListRecords_base_url+'&resumptionToken=' + resumption_token
       # print("\nURL\n", url)

        # Find page of Datasets
        xml_tree_data = self._get_page_of_Datasets(url)
        if xml_tree_data is None:
            return []

        # get schema data only first time
        if not self.current_schema_report:
            self.current_schema_report = self._get_schema_report(xml_tree_data)

#        tags = [elem.tag for elem in xml_tree_data.iter()]
#        print('TAGS/n', tags)
        if ds_list:
            ds_list.extend(self.parse_PANGEA_XML_result_to_DICT(xml_tree_data))
        else:
            ds_list = self.parse_PANGEA_XML_result_to_DICT(xml_tree_data)

        # Update total of Datasets
        self.total_pangea_datasets = len(ds_list)

        # GET RESUMPTION TOKEN FROM xml_tree_data
        resumption_token = self._get_pangea_resumption_token(xml_tree_data)

        if resumption_token['resumptionToken']:
            #print("\nRT:\n", resumption_token)
            self.get_datasets_list(ds_list, resumption_token['resumptionToken'])

        return ds_list

    def _get_page_of_Datasets(self, url):

        obj_tree = None

        # Find page of Datasets
        try:
            response = requests.get(url)
        except requests.exceptions.RequestException as e:
            self.set_log("error_API", url + " - " + e.__str__())

        if not response.ok:
            self.set_log("error_api_data", url)
        else:
            obj_tree = ElementTree.fromstring(response.content)
        return  obj_tree

    def _get_pangea_resumption_token(self, xml_tree_data):
        r_token = {'resumptionToken': ''}

        for record in xml_tree_data.iter(self.ns0 + 'resumptionToken'):
            if record.text:
                r_token['resumptionToken'] = record.text
                r_token.update(record.attrib)

        return r_token

    def parse_PANGEA_XML_result_to_DICT(self, xml_tree_data):

        ds_result = []

        for record in xml_tree_data.iter(self.ns0 + 'record'):
            if not self.is_dataset_deleted(record):
                ds_result.append(self.parse_PANGEA_XML_RECORD_to_DICT(record))

        return ds_result

    def is_dataset_deleted(self, record):
        status = record.find('./' + self.ns0 + 'header')
        if status.attrib:
            status = status.attrib.get("status", "")
        return status == 'deleted'

    def parse_PANGEA_XML_RECORD_to_DICT(self, xml_tree_obj):

        record = xml_tree_obj
        ns0 = self.ns0
        ns2 = self.ns2
        ds_result = {}

        # HEADER
        # <ns0:record>
        #   <ns0:header>
        #       <ns0:identifier>oai:pangaea.de:doi:10.1594/PANGAEA.786524</identifier>
        #       <ns0:datestamp>2022-11-11T13:48:06Z</datestamp>
        #       <ns0:setSpec>citable</setSpec>
        #       <ns0:setSpec>supplement</setSpec>
        #       <ns0:setSpec>topicAgriculture</setSpec>
        #       <ns0:setSpec>topicLithosphere</setSpec>
        #   </ns0:header>
        identifier = record.find('./' + ns0 + 'header/' + ns0 + 'identifier').text
        datestamp = record.find('./' + ns0 + 'header/' + ns0 + 'datestamp').text
        ds_result['header'] = {'identifier': identifier, 'datestamp': datestamp}

        # <ns0:metadata><ns2:MetaData>
        ds_result['metadata'] = {'pangeaDataset': {}}

        # METADATA - IDENTIFIER
        ds_result['metadata']['pangeaDataset']['identifier'] = identifier


        # METADATA - AUTHOR
        #     <ns2:citation id="dataset786524">
        #         <ns2:author id="dataset.author42192">
        #             <ns2:lastName>Colacevich</ns2:lastName>
        #             <ns2:firstName>Andrea</ns2:firstName>
        #             <ns2:eMail>colacevich2@unisi.it</ns2:eMail>
        #         </ns2:author>
        #         <ns2:author id="dataset.author42193">
        #             <ns2:lastName>Caruso</ns2:lastName>
        #             <ns2:firstName>Tancredi</ns2:firstName>
        #             <sn2:orcid>0000-0002-3607-9609</ns2:orcid>
        #         </ns:author>
        #     </ns2:citation>
        path_from_pangeadataset = ns2 + 'citation/' + ns2 + 'author'
        subfields = [ns2+'lastName', ns2+'firstName', ns2+'eMail', ns2+'orcid']
        ds_result['metadata']['pangeaDataset']['authors'] = self._find_metadata_in_record(record, path_from_pangeadataset, 'author', subfields)

        # METADATA TITLE
        #    <ns2:citation id="dataset786524">
        #         <ns2:title>Floral and faunal characteristics and content</ns2:title>
        #     </ns2:citation>
        path_from_pangeadataset = ns2 + 'citation/' + ns2 + 'title'
        ds_result['metadata']['pangeaDataset']['title'] = self._find_metadata_in_record_simple(record, path_from_pangeadataset)

        # METADATA URI
        #    <ns2:citation id="dataset786524">
        #         <ns2:URI>pangaea.de:doi:10.1594/PANGAEA.786524</ns2:URI>
        #     </ns2:citation>
        path_from_pangeadataset = ns2 + 'citation/' + ns2 + 'URI'
        ds_result['metadata']['pangeaDataset']['URI'] = self._find_metadata_in_record_simple(record, path_from_pangeadataset)

        # METADATA YEAR
        #    <ns2:citation id="dataset786524">
        #         <ns2:year>2009</ns2:year>
        #     </ns2:citation>
        path_from_pangeadataset = ns2 + 'citation/' + ns2 + 'year'
        ds_result['metadata']['pangeaDataset']['year'] = self._find_metadata_in_record_simple(record, path_from_pangeadataset)

        # METADATA - TECHNICALLINFO
        #<ns2:technicalInfo>
        #     <ns2:entry key="xmlLastModified" value="2022-11-11T13:48:06Z"/>
        #     <ns2:entry key="lastModified" value="2017-08-08T07:09:25"/>
        #     <ns2:entry key="filename" value="Colacevich_2009"/>
        #     <ns2:entry key="mimeType" value="application/zip"/>
        #     <ns2:entry key="status" value="published"/>
        #     <ns2:entry key="status_num" value="4"/>
        #     <ns2:entry key="DOIRegistryStatus" value="registered"/>
        #     <ns2:entry key="DOIRegistryStatus_num" value="4"/>
        #     <ns2:entry key="DOIRegistrationDate" value="2012-08-22T03:10:49"/>
        #     <ns2:entry key="hierarchyLevel" value="parent"/>
        #     <ns2:entry key="collectionType" value="publication series"/>
        #     <ns2:entry key="collectionType_num" value="4"/>
        #     <ns2:entry key="collectionChilds" value="D786522,D786523"/>
        #     <ns2:entry key="loginOption" value="unrestricted"/>
        #     <ns2:entry key="loginOption_num" value="1"/>
        # </ns2:technicalInfo>"
        path_from_pangeadataset = ns2 + 'technicalInfo/' + ns2 + 'entry'
        ds_result['metadata']['pangeaDataset']['technicalInfo'] = self._find_metadata_in_record_by_key(record, path_from_pangeadataset)

        # METADATA - SETSPECS
        # <ns0:record>
        #   <ns0:header>
        #       <ns0:identifier>oai:pangaea.de:doi:10.1594/PANGAEA.786524</identifier>
        #       <ns0:datestamp>2022-11-11T13:48:06Z</datestamp>
        #       <ns0:setSpec>citable</setSpec>
        #       <ns0:setSpec>supplement</setSpec>
        #       <ns0:setSpec>topicAgriculture</setSpec>
        #       <ns0:setSpec>topicLithosphere</setSpec>
        #   </ns0:header>
        ds_result['metadata']['pangeaDataset']['setSpecs'] = self._get_pangea_setSpecs(record)

        # METADATA - LICENSE
        #<ns2:license id="license101">
        #     <ns2:label>CC-BY-3.0</ns2:label>
        #     <ns2:name>Creative Commons Attribution 3.0 Unported</ns2:name>
        #     <ns2:URI>https://creativecommons.org/licenses/by/3.0/</ns2:URI>
        #</ns2:license>"
        path_from_pangeadataset = ns2 + 'license'
        subfields = [ns2 + 'label', ns2 + 'name', ns2 + 'URI']
        ds_result['metadata']['pangeaDataset']['license'] = self._find_metadata_in_record(record,
                                                                                          path_from_pangeadataset,
                                                                                          'license', subfields)

        # METADATA ABSTRACT
        #<ns2:abstract>Although soil algae are among the main primary producers in most...
        #</ns2:abstract>
        path_from_pangeadataset = ns2 + 'abstract'
        ds_result['metadata']['pangeaDataset']['abstract'] = self._find_metadata_in_record_simple(record,
                                                                                               path_from_pangeadataset)

        # METADATA KEYWORDS
        # <ns2:keywords>
        #   <ns2:keyword id="keywords.term539" type="fromDatabase">ipy</ns2:keyword>
        ds_result['metadata']['pangeaDataset']['keywords'] = self._find_keywords_in_record(record)

        # METADATA - supplementTo
        # <ns2:supplementTo id="ref36829">
        #         <ns2:author id="ref36829.author42192">
        #             <ns2:lastName>Colacevich</ns2:lastName>
        #             <ns2:firstName>Andrea</ns2:firstName>
        #             <ns2:eMail>colacevich2@unisi.it</ns2:eMail>
        #         </ns2:author>
        #         <ns2:author id="ref36829.author42193">
        #             <ns2:lastName>Caruso</ns2:lastName>
        #             <ns2:firstName>Tancredi</ns2:firstName>
        #             <ns2:orcid>0000-0002-3607-9609</ns2:orcid>
        #         </ns2:author>
        #         <ns2:year>2009</ns2:year>
        #         <ns2:title>Photosynthetic pigments in soils from northern Victoria Land (continental Antarctica) as proxies for soil algal community structure and function</ns2:title>
        #         <ns2:source id="ref36829.journal14918" relatedTermIds="34058" type="journal">Soil Biology and Biochemistry</ns2:source>
        #         <ns2:volume>41(10)</ns2:volume>
        #         <ns2:URI>https://doi.org/10.1016/j.soilbio.2009.07.020</ns2:URI>
        #         <ns2:pages>2105-2114</ns2:pages>
        #     </ns2:supplementTo>
        path_from_pangeadataset = ns2 + 'citation/' + ns2 + 'supplementTo'
        subfields = [ns2 + 'title', ns2 + 'source', ns2 + 'URI', ns2 + 'volume', ns2 + 'pages', ns2 + 'year', ns2 + 'author']
        subsubfields_target = [ns2 + 'author']
        subsubfields = [ns2+'lastName', ns2+'firstName', ns2+'eMail', ns2+'orcid']
        ds_result['metadata']['pangeaDataset']['supplementTo'] = self._find_metadata_in_record_three_levels(record,
                                                                                          path_from_pangeadataset,
                                                                                          'supplementTo', subfields, subsubfields_target, subsubfields)
       # METADATA - reference
        # <ns2:reference dataciteRelType="References" group="210" id="ref103803" relationType="Related to" relationTypeId="12" typeId="ref" >
        #     <ns2:author id="ref103803.author74988" >
        #         <ns2:lastName>Puy</ns2:lastName>
        #         <ns2:firstName>Arnald</ns2:firstName>
        #         <ns2:eMail>apuy@princeton.edu</ns2:eMail>
        #         <ns2:orcid>0000-0001-9469-2156</ns2:orcid>
        #     </ns2:author>
        #     <ns2:prepubStatus>in press</ns2:prepubStatus>
        #     <ns2:title>Current models underestimate future irrigated areas</ns2:title>
        #     <ns2:source id="ref103803.journal6096" relatedTermIds="33974" type="journal" >Geophysical Research Letters</ns2:source>
        #     <ns2:URI>https://doi.org/10.1029/2020GL087360</ns2:URI>
        # </ns2:reference>

        path_from_pangeadataset = ns2 + 'reference'
        subfields = [ns2 + 'title', ns2 + 'source', ns2 + 'journal', ns2 + 'type',
                     ns2 + 'URI', ns2 + 'volume', ns2 + 'pages', ns2 + 'year', ns2 + 'author']
        subsubfields_target = [ns2 + 'author']
        subsubfields = [ns2+'lastName', ns2+'firstName', ns2+'eMail', ns2+'orcid']
        ds_result['metadata']['pangeaDataset']['reference'] = self._find_metadata_in_record_three_levels(record,
                                                                                          path_from_pangeadataset,
                                                                                          'reference', subfields, subsubfields_target, subsubfields)
        return ds_result

    def _get_pangea_setSpecs(self, record):

        setSpecs_list = []
        setSpecs = record.findall('./' + self.ns0 + 'header/' + self.ns0 + 'setSpec')
        for setSpec in setSpecs:
            setSpecs_list.append(setSpec.text)

        return setSpecs_list

    def _find_keywords_in_record(self, record):

        target = './' + self.ns0 + 'metadata/' + self.ns2 + 'MetaData/' + self.ns2 + 'keywords/' + self.ns2 + 'keyword'
        metadata = record.findall(target)

        result = []

        for keyword in metadata:
            if keyword.attrib:
                attr_dict = keyword.attrib
                if "type" in attr_dict and attr_dict["type"] == 'fromDatabase':
                    result.append(keyword.text)

        return result

    def _find_metadata_in_record_by_key(self, record, path):

        target = './' + self.ns0 + 'metadata/' + self.ns2 + 'MetaData/' + path
        metadata = record.findall(target)

        result = {}

        for entry in metadata:
            if entry.attrib:
                values_dict = entry.attrib
                if "key" in values_dict and "value" in values_dict:
                    result[values_dict["key"]] = values_dict["value"]

        return result

    def _find_metadata_in_record_simple(self, record, path, subfields=[]):

        target = './' + self.ns0 + 'metadata/' + self.ns2 + 'MetaData/' + path
        metadata = record.find(target)

        result = {}
        name = path.split('}', 1)[1]
        if metadata is not None:
            if metadata.attrib:
                result = {name: metadata.text}
                result.update(metadata.attrib)
            elif metadata.text:
                result = metadata.text
        return result

    def _find_metadata_in_record(self, record, path, metadata_name, subfields=[]):

        target = './' + self.ns0 + 'metadata/' + self.ns2 + 'MetaData/' + path
        metadata = record.findall(target)
        list_result = []

        for value in metadata:
            result = {}
            if not subfields:
                result[metadata_name] = {metadata_name: value.text}
                result.update(value.attrib)
                list_result.append(result)
            else:
                dict_result = {metadata_name: {}}
                for field in subfields:
                    elem = value.find('./' + field)
                    name = field.split('}',1)[1]
                    if elem != None and elem.attrib:
                        dict_result[metadata_name][name] = {name: elem.text}
                        dict_result[metadata_name][name].update(elem.attrib)
                    elif elem != None:
                        dict_result[metadata_name][name] = elem.text

                if dict_result[metadata_name]:
                    list_result.append(dict_result)
        return list_result

    def _find_metadata_in_record_three_levels(self, record, path, metadata_name, subfields=[], subsubfields_target=[], subsubfields=[]):

        target = './' + self.ns0 + 'metadata/' + self.ns2 + 'MetaData/' + path
        metadata = record.findall(target)
        list_result = []

        for value in metadata:
            result = {}
            if not subfields:
                result[metadata_name] = {metadata_name: value.text}
                result.update(value.attrib)
                list_result.append(result)
            else:
                dict_result = {metadata_name: {}}
                for field in subfields:
                    elem = value.find('./' + field)
                    name = field.split('}',1)[1]

                    if field in subsubfields_target:
                        path_from_pangeadataset = path + '/' + field
                        dict_result[metadata_name][name+'s'] = self._find_metadata_in_record(record, path_from_pangeadataset,
                                                                                                        name, subsubfields)

                    elif elem != None and elem.attrib:
                        dict_result[metadata_name][name] = {name: elem.text}
                        dict_result[metadata_name][name].update(elem.attrib)
                    elif elem != None:
                        dict_result[metadata_name][name] = elem.text

                if dict_result[metadata_name]:
                    list_result.append(dict_result)
        return list_result

    def parse_PANGEA_RECORD_DICT_to_LDM_CKAN_DICT(self, pangea_dict):

        ldm_dict = self._get_LDM_vdataset_template()
        pangea_metadata = pangea_dict['metadata']['pangeaDataset']

        # idenfier (DOI)
        identifier = self._get_pangea_value(pangea_metadata, ['identifier'])
        identifier = identifier.replace('oai:pangaea.de:doi:','')
        publication_date = self._get_pangea_value(pangea_metadata, ['technicalInfo', 'DOIRegistrationDate'])
        publication_year = self._get_pangea_value(pangea_metadata, ['year'])

        if not publication_date:
            publication_date = publication_year

        ldm_dict['doi'] = identifier
        ldm_dict['doi_date_published'] = publication_year

        url = self._get_pangea_value(pangea_metadata, ['URI'])
        if not url:
            url = 'https://doi.org/' + identifier
        ldm_dict['url'] = url

        # Creation date
        ldm_dict['source_metadata_created'] = publication_year

        # authors
        ldm_dict = self._get_pangea_authors(pangea_metadata, ldm_dict)

        # title
        title = self._get_pangea_value(pangea_metadata, ['title'])
        name = self.adjust_dataset_name(identifier)
        ldm_dict['title'] = title
        ldm_dict['name'] = name

        # license
        license = pangea_metadata.get('license', [])
        if license:
            ldm_dict['license_id'] = self._get_pangea_value(license[0], ['license', 'label'])
            ldm_dict['license_title'] = self._get_pangea_value(license[0], ['license', 'name'])

        # abstract
        abstract = self._get_pangea_value(pangea_metadata, ['abstract'])
        ldm_dict['notes'] = abstract

        # keywords
        keywords  = self._get_pangea_value(pangea_metadata, ['keywords'])
        ldm_dict = self._get_pangea_keywords(keywords, ldm_dict)

        # publication year
        if publication_year:
            ldm_dict['publication_year'] = publication_year

        # subject areas
        ldm_dict = self._get_pangea_subject_areas(pangea_metadata, ldm_dict)

        # resource type
        resource_type = self._get_pangea_value(pangea_metadata, ['technicalInfo', 'mimeType'])
        resource = self._get_pangea_value(pangea_metadata, ['technicalInfo', 'filename'])
        resource_type_txt = resource_type
        if resource_type_txt and resource:
            resource_type_txt = resource_type_txt + " - filename: " + resource
        else:
            resource_type_txt = resource

        ldm_dict['resource_type'] = resource_type_txt

        # Related identifiers from "supplementTo"
        ldm_dict = self._get_pangea_related_identifiers_supplementTo(pangea_metadata, ldm_dict)

        # Related identifiersfrom "reference"
        ldm_dict = self._get_pangea_related_identifiers_reference(pangea_metadata, ldm_dict)

        return ldm_dict

    def _get_pangea_authors(self, pangea_metadata, ldm_dict):

        authors = pangea_metadata.get('authors', [])
        extra_authors = []
        pos = 1
        for author in authors:
            firstName = self._get_pangea_value(author, ['author', 'firstName'])
            lastName = self._get_pangea_value(author, ['author', 'lastName'])
            author_name = lastName + ", " + firstName
            orcid = self._get_pangea_value(author, ['author', 'orcid'])

            # first is author
            if pos == 1:
                ldm_dict['author'] = author_name
                ldm_dict['givenName'] = firstName
                ldm_dict['familyName'] = lastName
                ldm_dict['orcid'] = orcid
                pos += 1
            else:
                # following are extra_authors
                extra_author = {"extra_author": author_name,
                                "givenName": firstName,
                                "familyName": lastName,
                                "orcid": orcid}
                extra_authors.append(extra_author)
        if extra_authors:
            ldm_dict['extra_authors'] = extra_authors

        return ldm_dict

    def _get_pangea_keywords(self, keywords_list, ldm_dict):

        keywords_list = self._adjust_tags(keywords_list)
        tag_list = []

        for keyword in keywords_list:
            tag = keyword
            # some cases are ; separated list of tags
            tag = tag.replace(';', ',')
            # some cases are "·" separated list of tags
            tag = tag.replace('·', ',')
            # some cases are "·" separated list of tags
            tag = tag.replace('-', ',')
            
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
        
    def _adjust_tags(self, tag_list):

        PERMITTED_CHARS = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-_. "
        result_list = []

        for tag in tag_list:
            tag = tag.replace("/", "-") # some tags have / chars
            tag = "".join(c for c in tag if c in PERMITTED_CHARS)  # some tags has no permitted chars
            tag = tag.strip()
            result_list.append(tag)

        return result_list

    def _get_pangea_subject_areas(self, pangea_metadata, ldm_dict):

        s_areas = pangea_metadata.get('setSpecs', [])
        s_areas_list = []

        for s_area in s_areas:
            # Ex. ['citable', 'supplement', 'topicAgriculture', 'topicLakesRivers', 'topicLithosphere']
            if s_area[0:5] == 'topic':
                s_area_name = (s_area[5:])

                # create ckan subject areas dict
                s_area_dict = { "subject_area_additional": "",
                                "subject_area_name": s_area_name }
                s_areas_list.append(s_area_dict)
        if s_areas_list:
            ldm_dict['subject_areas'] = s_areas_list

        return ldm_dict

    def _get_pangea_related_identifiers_supplementTo(self, pangea_metadata, ldm_dict):
        return self._get_pangea_related_identifiers(pangea_metadata, ldm_dict, 'IsSupplementTo')

    def _get_pangea_related_identifiers_reference(self, pangea_metadata, ldm_dict):
        return self._get_pangea_related_identifiers(pangea_metadata, ldm_dict, 'References')


    def _get_pangea_related_identifiers(self, pangea_metadata, ldm_dict, ref_type):

        if ref_type == 'IsSupplementTo':
            r_identifiers = pangea_metadata.get('supplementTo', [])
            search_field = 'supplementTo'
        elif ref_type == 'References':
            r_identifiers = pangea_metadata.get('reference', [])
            search_field = 'reference'

        r_identifiers_list = []

        for r_id in r_identifiers:
            identifier = self._get_pangea_value(r_id, [search_field, 'URI'])
            id_type = 'DOI'
            id_relation = ref_type
            title = self._get_pangea_value(r_id, [search_field, 'title'])
            source = self._get_pangea_value(r_id, [search_field, 'source', 'source'])
            # if source:
            #     source = source.get('source', '')
            year = self._get_pangea_value(r_id, [search_field, 'year'])

            authors_list = self._get_pangea_value(r_id, [search_field, 'authors'])
            author_res = self._get_authors_data_from_related_identifiers(authors_list)

            # create ckan related identifiers dict
            r_identifier_dict = {"identifier": identifier,
                                 "identifier_type": id_type,
                                 "relation_type": id_relation,
                                 "title": title,
                                 "year": year,
                                 "authors": author_res['authors'],
                                 "orcid_authors": author_res['orcid_authors'],
                                 "email_authors": author_res['email_authors'],
                                 "source": source}

            r_identifiers_list.append(r_identifier_dict)
        if r_identifiers_list:
            if 'related_identifiers' in ldm_dict and len(ldm_dict['related_identifiers']):
                ldm_dict['related_identifiers'] += r_identifiers_list
            else:
                ldm_dict['related_identifiers'] = r_identifiers_list
        
        # Solr limits to 32776 the field
        # Get the UTF-8 encoded bytes
        if 'related_identifiers' in ldm_dict and len(ldm_dict['related_identifiers']):
            max_bytes = 30000
            r_string = str(ldm_dict['related_identifiers'])
            encoded = r_string.encode('utf-8')
            #print("\n\nRELATED IDENTIFIER", ldm_dict['related_identifiers'], "\nBYTES\n", encoded)            
            # If already within limit, return original
            while len(encoded) > max_bytes:
                ldm_dict['related_identifiers'] = ldm_dict['related_identifiers'][:-1]
                r_string = str(ldm_dict['related_identifiers'])
                encoded = r_string.encode('utf-8')

        return ldm_dict

    def _get_authors_data_from_related_identifiers(self, authors_list):

        author_res = ''
        orcid_author_res = ''
        email_author_res = ''

        for author in authors_list:
            author_dict = author['author']
            if author_res:
                author_res += ','
                orcid_author_res += ','
                email_author_res += ','
            author_res += author_dict.get('lastName', '') + ' ' + author_dict.get('firstName', '')
            orcid_author_res += author_dict.get('orcid', '')
            email_author_res += author_dict.get('eMail', '')

        return {"authors": author_res,
                "orcid_authors": orcid_author_res,
                "email_authors": email_author_res}


    def _get_pangea_value(self, pangea_metadata, list_fields=[]):
        ''' Returns the value in pangea's metadata dict referenced by
        the path in list_fields parameter '''

        mt_dict = pangea_metadata
        value = ""

        for field in list_fields:
            if isinstance(mt_dict, dict) and field in mt_dict:
                mt_dict = mt_dict[field]
                if not isinstance(mt_dict, dict):
                    value = mt_dict
            else:
                if not isinstance(mt_dict, dict):
                    value = mt_dict
                else:
                    value = mt_dict.get(field, "")

        return value

    def _get_LDM_vdataset_template(self):
        #datetime.datetime.now().isoformat()


        LDM_imported_vdataset = {
            "repository_name": self.repository_name,
            "type": "vdataset",
            "source_metadata_created": "",
            "source_metadata_modified": "",
            "owner_org": self.organization_name,
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
             "organization": self._get_pangea_organization_ckan_dict(),
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
            Using the PANGAEA harvesting tool determine if the current schema is matching the schema implemented.
            Returning a dict with the results of comparing the metadata schema used in the code
            with the metadata schema retrieved by remote servers

            result = {'status_ok': True,
                      'report': 'Text explaining the results'}
        '''

        if not self.current_schema_report:
            self.current_schema_report = self._get_schema_report()

        return self.current_schema_report


    def _get_schema_report(self, obj_tree=None):

        if obj_tree is None:
            url = self.pangea_ListRecords_url

            obj_tree = self._get_page_of_Datasets(url)

        if obj_tree is None:
            # Error accessing API
            schema_dataset = None
        else:
            schema_dataset = obj_tree.find(self.ns0 + 'ListRecords/' + self.ns0 + 'record/' + self.ns0 + 'metadata/' + self.ns2 + 'MetaData')

        current_schema = {'current_pangea_schema': self.ns0,
                          'current_dataset_schema': self.ns2,
                          'current_pangea_schema_version': self.pangea_schema_version,
                          'last_resumption_token': self.last_resumption_token}
        schema_ok = True

        errors = {}
        # if element was found means the schema is correct
        if schema_dataset is None:
            errors['dataset_schema'] = 'ERROR: Current Dataset Schema is incorrect.'
            schema_ok = False
        elif schema_dataset.attrib:
             schema_version = schema_dataset.attrib['version']
             if schema_version != self.pangea_schema_version:
                 errors['dataset_schema_version'] = 'ERROR: Current Dataset Schema version is incorrect. Current_local: '+self.pangea_schema_version+', Current_API: '+ schema_version
                 schema_ok = False

        report = {'status_ok': schema_ok,
                  'report': {'current_metadata': current_schema,
                             'errors': errors},
                  }
        return report

    def get_organization(self, name='radar'):
        '''
            In PANGAEA Datasets are not related to a specific organization.
            PANGAEA's imported datasets allways belongs to PANGAEA organization in LDM.

            Returns: a dictionary with the organization's metadata
        '''

        self.set_log("infos_searching_org", name)

        org_dict = self._get_pangea_organization_ckan_dict()

        return org_dict

    def _get_pangea_organization_ckan_dict(self):

        org_dict = {
        "approval_status": "approved",
        "description": "PANGAEA (Data Publisher for Earth & Environmental Science): The information system PANGAEA is "
                       "operated as an Open Access library aimed at archiving, publishing and distributing georeferenced "
                       "data from earth system research. PANGAEA guarantees long-term availability (greater than 10 years) "
                       "of its content. PANGAEA is open to any project, institution, or individual scientist to use or to "
                       "archive and publish data. PANGAEA focuses on georeferenced observational data, experimental data, "
                       "and models/simulations. Citability, comprehensive metadata descriptions, interoperability of data "
                       "and metadata, a high degree of structural and semantic harmonization of the data inventory as "
                       "well as the commitment of the hosting institutions ensures FAIRness of archived data.",
        "display_name": "PANGAEA (" + self.pangaea_allowed_types.get(self.topic, "") + ")",
        "image_display_url": "pangaea_" + self.topic.lower() + ".png",
        "image_url": "pangaea_" + self.topic.lower() + ".png",
        "is_organization": True,
        "name": self.organization_name,
        "state": "active",
        "title": "PANGAEA (" + self.pangaea_allowed_types.get(self.topic, "") + ")",
        "type": "organization",
        }
        return org_dict

    def adjust_dataset_name(self, ds_name):

        # keep consistency with RADAR profile
        ds_name = 'DOI-' + ds_name

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
        exclude_in_comparison = ['owner_org', 'license_title', 'organization', 'tags']

        for field in remote_dataset.keys():

            # special case  tags
            if field == 'tags':
                for tag in remote_dataset['tags']:
                    tag_name = tag['name']
                    tag_found = False
                    for tag_local in local_dataset['tags']:
                        if tag_local['name'] == tag_name:
                            tag_found = True
                    if not tag_found:
                        result = True
                        break

            #print("\nField: ", field, " L= ", local_dataset[field], " R= ", remote_dataset[field])
            if field in local_dataset and field not in exclude_in_comparison and local_dataset[field] != remote_dataset[field]:
                self.logger.message = "\nField: ", field, " L= ", local_dataset[field], " R= ", remote_dataset[field]
                print("\n\n\n\n***********************", self.logger.message,"+++++++++++++++\n\n\n")
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

        # Save extra fields (not standard ckan fields added by LUH)
        # Listed just for reference and control
        # 'domain'
        # 'terms_of_usage'
        # 'have_copyright'

        return ds_dict


# LOGGER METHODS
# **************
    def get_summary_log(self):
        summary_log = {'Repository_name': self.repository_name + ' - ' + self.topic,
                       "Datasets_inserted": self.logger.datasets_inserted,
                       "Datasets_updated": self.logger.datasets_modified,
                       "Datasets_skiped": self.logger.datasets_skiped,
                       "LOG_file": self.log_file_path+self.log_file,
                       "SCHEMA_REPORT": self.check_current_schema()}

        return summary_log


    def set_log(self, op, data=""):

        self.logger.message = ""

        def infos_searching_ds(data):
            self.logger.message = "Searching Datasets in PANGAEA's harvesting tool."

        def error_API(data):
            self.logger.message = "Error Connecting PANGAEA's harvesting tool: " + data

        def error_api_data(data):
            self.logger.message = "Error retrieving data from API: " + data

        def infos_ds_found(data):
            self.logger.message = "Number of Datasets found: " + data

        def infos_ds_metadata_found(data):
            self.logger.message = "Metadata found with name: " + data

        def infos_searching_org(data):
            self.logger.message = "Searching Organizaion in PANGAEA API. Name: " + data

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
            'infos_org_found': infos_summary_log
        }.get(op)(data)

        if op[0:5]=='infos':
            self.set_log_msg_info()
        elif op[0:5]=='error':
            self.set_log_msg_error()
