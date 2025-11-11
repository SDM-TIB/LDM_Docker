import urllib.parse
from xml.etree import ElementTree

import requests
from ckanext.tibimport.logic2 import DatasetParser
from ckanext.tibimport.open_licenses import open_access_licenses

class GOETTINGEN_ParserProfile(DatasetParser):
    '''

    A class defined to access Goettingen's Datasets
    using the Goettingen's API https://data.goettingen-research-online.de/api/ and parsing the retrieved
    data to dataset_dic as needed by the LDM

    Goettingen API docs: https://guides.dataverse.org/en/5.14/api/search.html

    '''

    def __init__(self):
        self.repository_name = "Göttingen Research Online Data"
        self.dataset_title_prefix = "goe-"
        # https://data.goettingen-research-online.de/api/search?q=*&type=dataset&per_page=1000&start=2000
        # https://data.goettingen-research-online.de/api/datasets/export?exporter=schema.org&persistentId=doi%3A10.25625/BZYLZ0
        self.current_page = 1
        self.ds_per_page = 500
        # REQUIREMENT: Please harvest type 'Dataset' ONLY: 
        self.goettingen_ListRecords_url = 'https://data.goettingen-research-online.de/api/search?q=*&type=dataset&per_page='+str(self.ds_per_page)
        self.goettingen_export_to_schema_org_url = 'https://data.goettingen-research-online.de/api/datasets/export?exporter=schema.org&persistentId=doi%3A'
        
        self.current_dataset_schema = "http://schema.org"        
        
        # Set to True to force update of all datasets
        self.force_update = False

        # Total of datasets available in goettingen
        self.total_goettingen_datasets = 0

        # schema validation report
        self.current_schema_report = {}


        self.log_file_prefix = "GOE_"
        super().__init__()


    def get_all_datasets_dicts(self):
        '''
             Using goettingen's API get a list of dictionaries with the complete Dataset's
             metadata inside.
             Notice: Dataset's dictionaries must be adapted to CKAN schema

             Returns: an array of  dictionary with the list of datasets or an empty array
        '''

        ds_list = []
        ds_list = self.get_datasets_list()


        dict_list = []
        for dataset in ds_list:
            dict_list.append(self.parse_goettingen_RECORD_DICT_to_LDM_CKAN_DICT(dataset))

        return dict_list

    def get_datasets_list(self, ds_list=[], first_page=True):
        '''
            Uses the goettingen API to retrieve a list of datasets as a list of dictionaries

            Returns: a list of datasets or an empty list
            Notice: the dictionaries contains metadata NOT in CKAN's schema
        '''
        self.set_log("infos_searching_ds")

        if first_page:
            # Find first page of Datasets
            url = self.goettingen_ListRecords_url
            self.current_page = 0

        else:
            # Find page from resumption token url
            self.current_page += 1
            start_point = self.ds_per_page * self.current_page
            url = self.goettingen_ListRecords_url+'&start=' + str(start_point)
        print("\n\nCALLING URL:", url)
        # Find page of Datasets
        try:
            response = requests.get(url)
        except requests.exceptions.RequestException as e:  # This is the correct syntax
            self.set_log("error_API", url + " - " + e.__str__())
            return []

        if not response.ok:
            self.set_log("error_api_data", url)
            return []
       # print("\nRESP: \n", response.content)
        api_data = response.json()
        api_data = api_data.get("data", {}).get('items', [])
        
        if not api_data:
            return ds_list
        
        # get schema data only first time
        if not self.current_schema_report:
            self.current_schema_report = self._get_schema_report()

        # if API shows results then try next page
        next_page = True if len(api_data)>0 else False

        api_data = self.extend_metadata_from_API(api_data)
        
        if len(api_data)>0:
            if ds_list:
                ds_list.extend(api_data)
            else:
                ds_list = api_data

        # Update total of Datasets
        self.total_goettingen_datasets = len(ds_list)
        
        if next_page:
            self.get_datasets_list(ds_list, False)

        return ds_list

    def extend_metadata_from_API(self, api_data):

        result_list = []    
        for dataset in api_data:
            ds_doi = dataset['global_id']
            export_url = self.goettingen_export_to_schema_org_url + ds_doi.replace('doi:', '')
            # Find Dataset's metadata
            try:
                response = requests.get(export_url)
            except requests.exceptions.RequestException as e:  
                self.set_log("error_API", export_url + " - " + e.__str__())
            if not response.ok:
                self.set_log("error_api_data", export_url)
                
            ds_data = response.json()
            
            ds_data = self.check_is_open_license(ds_data)
            # print("\n\nEXTENDED DATA:", ds_data)
            if ds_data.get("identifier", False):

                # Add subjects from first API call
                subjects_list = dataset.get('subjects', [])
                if subjects_list:
                    ds_data['subjects'] = subjects_list

                # Adding publications
                # "publications":[{"citation":"Government of India, Ministry of..",
                #                  "url":"http://fsi.nic.in/details.php?pgID=sb_64"}]    
                publications = dataset.get('publications', [])
                if publications:
                    ds_data['publications'] = publications
                
                result_list.append(ds_data)

        return result_list
    
    def check_is_open_license(self, ds_dict):

        ds_license = ds_dict.get('license', "").replace('http', 'https')
        if ds_license:
            for license in open_access_licenses.values():
                if ds_license in license['url'] or ds_license in license['legalcode_url']:
                    ds_dict['license_title'] = license['title']
                    return ds_dict
        return {}

    def _get_page_of_Datasets(self, url):

        # Find page of Datasets
        try:
            response = requests.get(url)
        except requests.exceptions.RequestException as e:  # This is the correct syntax
            self.set_log("error_API", url + " - " + e.__str__())
            return []

        if not response.ok:
            self.set_log("error_api_data", url)
            return []
        
        api_data = response.json()
        api_data = api_data.get("data", {}).get('items', [])
        
        return  api_data

    def get_remote_datasets_paged(self, resumption_token=""):
        '''
         Uses the goettingen API to retrieve a list of datasets as a list of dictionaries
         Returns: a list of datasets or an empty list
         Notice: the dictionaries contains metadata NOT in CKAN's schema
        '''
        self.set_log("infos_searching_ds")
        
        if not resumption_token:
            # Find first page of Datasets
            url = self.goettingen_ListRecords_url
            self.current_page = 0

        else:
            # Find page from resumption token url
            self.current_page += 1
            start_point = self.ds_per_page * self.current_page
            url = self.goettingen_ListRecords_url+'&start=' + str(start_point)

        
        # Find page of Datasets
        api_data = self._get_page_of_Datasets(url)
        
        # if API shows results then try next page
        if api_data:
            resumption_token = "go_to_next_page"
        else:
            resumption_token = ""
            return {"ds_list": [], "resumptionToken": resumption_token}

        api_data = self.extend_metadata_from_API(api_data)
        
        # get schema data only first time
        if not self.current_schema_report:
            self.current_schema_report = self._get_schema_report()

        ds_list = api_data

        # Update total of Datasets
        self.total_goettingen_datasets += len(ds_list)

        # Convert dics to LDM-CKAN dicts
        dict_list = []
        for dataset in ds_list:
            dict_list.append(self.parse_goettingen_RECORD_DICT_to_LDM_CKAN_DICT(dataset))

        return {"ds_list": dict_list, "resumptionToken": resumption_token}

    # def _get_goettingen_resumption_token(self, xml_tree_data):
    #     r_token = {'resumptionToken': ''}

    #     for record in xml_tree_data.iter(self.ns0 + 'resumptionToken'):
    #         if record.text:
    #             r_token['resumptionToken'] = record.text
    #             r_token.update(record.attrib)

    #     if 'completeListSize' in r_token:
    #         self.total_goettingen_datasets = int(r_token['completeListSize'])

    #     return r_token


    # def parse_goettingen_XML_result_to_DICT(self, xml_tree_data):

    #     ds_result = []

    #     for record in xml_tree_data.iter(self.ns0 + 'record'):
    #         ds_result.append(self.parse_goettingen_XML_RECORD_to_DICT(record))

    #     return ds_result





# ['{http://www.openarchives.org/OAI/2.0/}record', 
# '{http://www.openarchives.org/OAI/2.0/}header', 
#   '{http://www.openarchives.org/OAI/2.0/}identifier', 
#   '{http://www.openarchives.org/OAI/2.0/}datestamp', 
# '{http://www.openarchives.org/OAI/2.0/}setSpec', 
# '{http://www.openarchives.org/OAI/2.0/}setSpec', 
# '{http://www.openarchives.org/OAI/2.0/}setSpec', 
# '{http://www.openarchives.org/OAI/2.0/}setSpec', 
# '{http://www.openarchives.org/OAI/2.0/}setSpec', 
# '{http://www.openarchives.org/OAI/2.0/}setSpec', 
# '{http://www.openarchives.org/OAI/2.0/}metadata', 
# '{http://datacite.org/schema/kernel-4}resource', 
# '{http://datacite.org/schema/kernel-4}identifier', 
# '{http://datacite.org/schema/kernel-4}creators', 
#       '{http://datacite.org/schema/kernel-4}creator', 
#       '{http://datacite.org/schema/kernel-4}creatorName', 
#       '{http://datacite.org/schema/kernel-4}givenName', 
#       '{http://datacite.org/schema/kernel-4}familyName', 
#       '{http://datacite.org/schema/kernel-4}nameIdentifier', 
#       '{http://datacite.org/schema/kernel-4}nameIdentifier', 
#       '{http://datacite.org/schema/kernel-4}affiliation', 
#       '{http://datacite.org/schema/kernel-4}titles', 
#       '{http://datacite.org/schema/kernel-4}title', 
#       '{http://datacite.org/schema/kernel-4}publisher', 
#       '{http://datacite.org/schema/kernel-4}publicationYear', 
# '{http://datacite.org/schema/kernel-4}subjects', '{http://datacite.org/schema/kernel-4}subject', '{http://datacite.org/schema/kernel-4}contributors', '{http://datacite.org/schema/kernel-4}contributor', '{http://datacite.org/schema/kernel-4}contributorName', '{http://datacite.org/schema/kernel-4}dates', '{http://datacite.org/schema/kernel-4}date', '{http://datacite.org/schema/kernel-4}language', '{http://datacite.org/schema/kernel-4}resourceType', '{http://datacite.org/schema/kernel-4}alternateIdentifiers', '{http://datacite.org/schema/kernel-4}alternateIdentifier', '{http://datacite.org/schema/kernel-4}alternateIdentifier', '{http://datacite.org/schema/kernel-4}relatedIdentifiers', '{http://datacite.org/schema/kernel-4}relatedIdentifier', '{http://datacite.org/schema/kernel-4}rightsList', '{http://datacite.org/schema/kernel-4}rights', '{http://datacite.org/schema/kernel-4}descriptions', '{http://datacite.org/schema/kernel-4}description']














    # def parse_goettingen_XML_RECORD_to_DICT(self, xml_tree_obj):

    #     record = xml_tree_obj
    #     # print("\n\n\nRECORD:\n", xml_tree_obj)
    #     tags = [elem.tag for elem in xml_tree_obj.iter()]
    #     # print(tags)
        
    #     ns0 = self.ns0
    #     ns2 = self.ns2
    #     ns3 = self.ns3
    #     ds_result = {}

    #     # HEADER
    #     # <ns0:record>
    #     #   <ns0:header>
    #     #       <identifier>oai:https://leopard.tu-braunschweig.de/:dbbs_mods_00078205</identifier>
    #     #       <datestamp>2024-11-28</datestamp>
    #     #   </ns0:header>
    #     #   <metadata>
    #     #       <resource xmlns="http://datacite.org/schema/kernel-4" xsi:schemaLocation="http://datacite.org/schema/kernel-4 http://schema.datacite.org/meta/kernel-4.3/metadata.xsd">
    #     #          <identifier identifierType="DOI">10.24355/dbbs.084-202411180831-0</identifier>
    #     #         </resource>
    #     #   </metadata>
    #     identifier = record.find('./' + ns0 + 'header/' + ns0 + 'identifier').text
    #     datestamp = record.find('./' + ns0 + 'header/' + ns0 + 'datestamp').text
    #     ds_result['header'] = {'identifier': identifier, 'datestamp': datestamp}

    #     # <ns0:metadata><ns2:goettingenDataset>
    #     ds_result['metadata'] = {'goettingenDataset': {}}

    # # METADATA MANDATORY
    #     # METADATA - IDENTIFIER
    #     #     <ns3:identifier identifierType="DOI">10.22000/447</ns3:identifier>
    #     path_from_goettingendataset = ns2 + 'identifier'
        
    #     ds_result['metadata']['goettingenDataset'] = self._find_metadata_in_record_simple(record, path_from_goettingendataset)


    #     # METADATA - CREATORS
    #     #     <ns2:creators>
    #     #         <ns2:creator>
    #     #             <ns2:creatorName>Macotela, Edith Liliana</ns3:creatorName>
    #     #             <ns2:givenName>Edith Liliana</ns3:givenName>
    #     #             <ns2:familyName>Macotela</ns3:familyName>
    #     #             <ns2:nameIdentifier schemeURI="http://orcid.org/" nameIdentifierScheme="ORCID">0000-0003-3076-1946</ns3:nameIdentifier>
    #     #             <ns2:creatorAffiliation>Leibniz Institute of Atmospheric Physics at the University of Rostock</ns3:creatorAffiliation>
    #     #         </ns2:creator>
    #     #     </ns2:creators>
    #     path_from_goettingendataset = ns2 + 'creators/' + ns2 + 'creator'
    #     subfields = [ns2+'creatorName', ns2+'givenName', ns2+'familyName', ns2+'creatorAffiliation', ns2+'nameIdentifier']
    #     ds_result['metadata']['goettingenDataset']['creators'] = self._find_metadata_in_record(record, path_from_goettingendataset, 'creator', subfields)

    #     # METADATA TITLES
    #     #  <titles>
    #     #   <title xml:lang="de">Projekt ADoRe-OA: Umfrage zur Ermittlung von Bedarfen zur Be- und Verarbeitung publikationsbezogener Daten im Rahmen von Open-Access-Förderungen</title>
    #     #   <title titleType="TranslatedTitle" xml:lang="en">Project ADoRe-OA: Survey to determine requirements for the processing of publication-related data in the context of Open Access funding</title>
    #     #  </titles>
    #     path_from_goettingendataset = ns2 + 'titles/' + ns2 + 'title'
    #     subfields = []
    #     ds_result['metadata']['goettingenDataset']['titles'] = self._find_metadata_in_record(record, path_from_goettingendataset, 'title', subfields)


    #     # METADATA PUBLISHER
    #     #     <publisher>Universitätsbibliothek Braunschweig</publisher>
    #     path_from_goettingendataset = ns2 + 'publisher'
    #     ds_result['metadata']['goettingenDataset']['publisher'] = self._find_metadata_in_record_simple(record,
    #                                                                                         path_from_goettingendataset)
                                                                                                                                  
       
    #     # METADATA - PUBLICATION YEAR
    #     #     <publicationYear>2024</publicationYear>
    #     path_from_goettingendataset = ns2 + 'publicationYear'
    #     ds_result['metadata']['goettingenDataset']['publicationYear'] = self._find_metadata_in_record_simple(record,
    #                                                                                                     path_from_goettingendataset)

    #     # METADATA SUBJECT AREAS
    #     # <subjects>
    #     #   <subject>Open Access</subject>
    #     #   <subject subjectScheme="ddc">025</subject>
    #     # </subjects>
    #     subfields = []
    #     path_from_goettingendataset = ns2 + 'subjects/' + ns2 + 'subject'
    #     ds_result['metadata']['goettingenDataset']['subjectAreas'] = self._find_metadata_in_record(record,
    #                                                                                           path_from_goettingendataset,
    #                                                                                           'subject', subfields)

    #     # METADATA RESOURCE TYPE
    #     #     <resourceType resourceTypeGeneral="Dataset">research_data</resourceType>
    #     path_from_goettingendataset = ns2 + 'resourceType'
    #     ds_result['metadata']['goettingenDataset']['resourceType'] = self._find_metadata_in_record_simple(record,
    #                                                                                              path_from_goettingendataset)
                                                                                     
                                                                                   
    #     # METADATA RIGHTS
    #     # <rightsList>
    #     #   <rights rightsIdentifier="CC-BY-4.0" rightsURI="https://creativecommons.org/licenses/by/4.0/" xml:lang="en">Attribution 4.0</rights>
    #     # </rightsList>
    #     subfields = [ns2 + 'rightsList', ns2 + 'rights']
    #     path_from_goettingendataset = ns2 + 'rightsList'
    #     ds_result['metadata']['goettingenDataset']['rightsList'] = self._find_metadata_in_record(record,
    #                                                                                     path_from_goettingendataset,
    #                                                                                     'rights', subfields)
        
    # # OPTIONAL METADATA
    #     # METADATA - DESCRIPTIONS
    #     # <descriptions>
    #     #    <description descriptionType="Abstract" xml:lang="de">Die im Rahmen des BMBF-geförderten Projekts ADoRe-OA und der damit verbundenen Weiterentwicklung von CODA (Customizable Open Access Database Application) durchgeführten Umfrage wurde ermittelt, welche Daten zur Publikationsförderung wie erhoben und im weiteren Prozess be- und verarbeitet werden. Welche Anforderungen werden z.B. bezüglich Schnittstellen, Funktionalitäten und Metadaten werden an ein Tool gestellt, das die damit verbundenen Prozesse ideal abbildet und somit den Arbeitsaufwand minimiert. Vor diesem Hintergrund richtete sich diese Umfrage besonders an Mitarbeiter und Mitarbeiterinnen an Bibliotheken und/oder Verwaltungseinrichtungen, die in Ihrem Arbeitsalltag mit der Be- bzw. Verarbeitung dieser Daten, der Prüfung und/oder der Bewirtschaftung von Anträgen zur Förderung von Open-Access-Publikationen betraut sind.</description>
    #     #    <description descriptionType="Abstract" xml:lang="en">The survey carried out as part of the BMBF-funded ADoRe-OA project and the associated further development of CODA (Customizable Open Access Database Application) determined which data is collected for publication funding and how it is handled and processed in the further process. What requirements are placed on a tool, e.g. with regard to interfaces, functionalities and metadata, that ideally maps the associated processes and thus minimizes the workload? Against this background, this survey was aimed in particular at employees of libraries and/or administrative institutions who are entrusted with the processing of this data, the review and/or management of applications for the funding of open access publications in their everyday work.</description>
    #     # </descriptions>
    #     path_from_goettingendataset = ns2 + 'descriptions/' + ns2 + 'description'
    #     ds_result['metadata']['goettingenDataset']['descriptions'] = self._find_metadata_in_record(record,
    #                                                                                           path_from_goettingendataset,
    #                                                                                           'description')

    #     # METADATA - KEYWORDS
    #     # <keywords>
    #     #     <keyword>downy mildew resistance</keyword>
    #     #     <keyword>untargeted metabolomics</keyword>
    #     # </keywords>
    #     path_from_goettingendataset = ns3 + 'keywords/' + ns3 + 'keyword'
    #     ds_result['metadata']['goettingenDataset']['keywords'] = self._find_metadata_in_record(record, path_from_goettingendataset, 'keyword')

    #     # METADATA - CONTRIBUTORS
    #     # <contributors>
    #     #   <contributor contributorType="HostingInstitution">
    #     #      <contributorName>Universitätsbibliothek Braunschweig</contributorName>
    #     #      <givenName>Thomas</givenName>
    #     #      <familyName>Spengler</familyName>
    #     #      <nameIdentifier nameIdentifierScheme="ORCID" schemeURI="http://orcid.org/">0000-0002-0212-1899</nameIdentifier>
    #     #      <affiliation>Institute of Automotive Management and Industrial Production, TU Braunschweig</affiliation>
    #     # </contributor>
    #     # </contributors>
    #     path_from_goettingendataset = ns2 + 'contributors/' + ns2 + 'contributor'
    #     subfields = [ns2 + 'contributorName', ns2 + 'givenName', ns2 + 'familyName', ns2 + 'affiliation',
    #                  ns2 + 'nameIdentifier']
    #     ds_result['metadata']['goettingenDataset']['contributors'] = self._find_metadata_in_record(record,
    #                                                                                       path_from_goettingendataset,
    #                                                                                       'contributor', subfields)

    #     # METADATA LANGUAGE
    #     #     <language>en</language>
    #     path_from_goettingendataset = ns2 + 'language'
    #     ds_result['metadata']['goettingenDataset']['language'] = self._find_metadata_in_record_simple(record,
    #                                                                                              path_from_goettingendataset)
    #     # METADATA - ALTERNATE IDENTIFIERS
    #     # <alternateIdentifiers>
    #     #   <alternateIdentifier alternateIdentifierType="URL">https://leopard.tu-braunschweig.de/receive/dbbs_mods_00074785</alternateIdentifier>
    #     #   <alternateIdentifier alternateIdentifierType="MyCoRe">dbbs_mods_00074785</alternateIdentifier>
    #     # </alternateIdentifiers>
    #     path_from_goettingendataset = ns2 + 'alternateIdentifiers/' + ns2 + 'alternateIdentifier'
    #     ds_result['metadata']['goettingenDataset']['alternateIdentifiers'] = self._find_metadata_in_record(record, path_from_goettingendataset, 'alternateIdentifier')

    #     # METADATA - RELATED IDENTIFIERS
    #     #  <relatedIdentifiers>
    #     #    <relatedIdentifier relatedIdentifierType="URL" relatedMetadataScheme="mods" relationType="HasMetadata" schemeURI="https://www.loc.gov/standards/mods/v3/mods-3-7.xsd">https://leopard.tu-braunschweig.de/receive/dbbs_mods_00074775?XSL.Transformer=mods</relatedIdentifier>
    #     #    <relatedIdentifier relatedIdentifierType="DOI" relationType="References">https://doi.org/10.1021/acs.jnatprod.3c00789</relatedIdentifier>
    #     #  </relatedIdentifiers>
    #     # Types =
    #     # - ARK
    #     # - arXiv
    #     # - bibcode
    #     # - DOI
    #     # - EAN13
    #     # - EISSN
    #     # - Handle
    #     # - IGSN
    #     # - ISBN
    #     # - ISSN
    #     # - ISTC
    #     # - LISSN
    #     # - LSID
    #     # - PMID
    #     # - PURL
    #     # - UPC
    #     # - URL
    #     # - URN
    #     # Relation Types:
    #     # - IsCitedBy
    #     # - Cites
    #     # - IsSupplementTo
    #     # - IsSupplementedBy
    #     # - IsContinuedBy
    #     # - Continues
    #     # - HasMetadata
    #     # - Is MetadataFor
    #     # - IsNewVersionOf
    #     # - IsPreviousVersionOf
    #     # - IsPartOf
    #     # - HasPart
    #     # - IsReferencedBy
    #     # - References
    #     # - IsDocumentedBy
    #     # - Documents
    #     # - IsCompiledBy
    #     # - Compiles
    #     # - IsVariantFormOf
    #     # - IsOriginalFormOf
    #     # - IsIdenticalTo
    #     # - IsReviewedBy
    #     # - Reviews
    #     # - IsDerivedFrom
    #     # - IsSourceOf
    #     path_from_goettingendataset = ns2 + 'relatedIdentifiers/' + ns2 + 'relatedIdentifier'
    #     ds_result['metadata']['goettingenDataset']['relatedIdentifiers'] = self._find_metadata_in_record(record, path_from_goettingendataset, 'relatedIdentifier')

 
    #     return ds_result

    # def _find_metadata_in_record_simple(self, record, path, subfields=[]):

    #     target = './' + self.ns0 + 'metadata/' + self.ns2 + 'resource/' + path
        
    #     metadata = record.find(target)

    #     result = {}
    #     name = path.split('}', 1)[1]
    #     if metadata is not None:
    #         if metadata.attrib:
    #             result = {name: metadata.text}
    #             result.update(metadata.attrib)
    #         elif metadata.text:
    #             result = metadata.text
    #     return result


    # def _find_metadata_in_record(self, record, path, metadata_name, subfields=[]):

    #     target = './' + self.ns0 + 'metadata/' + self.ns2 + 'resource/' + path
    #     metadata = record.findall(target)

    #     list_result = []

    #     for value in metadata:
    #         result = {}
    #         if not subfields:
    #             result[metadata_name] = {metadata_name: value.text}
    #             result.update(value.attrib)
    #             list_result.append(result)
    #         else:
    #             dict_result = {metadata_name: {}}
    #             for field in subfields:
    #                 elem = value.find('./' + field)
    #                 name = field.split('}',1)[1]
    #                 if elem != None and elem.attrib:
    #                     dict_result[metadata_name][name] = {name: elem.text}
    #                     dict_result[metadata_name][name].update(elem.attrib)
    #                 elif elem != None:
    #                     dict_result[metadata_name][name] = elem.text

    #             if dict_result[metadata_name]:
    #                 list_result.append(dict_result)
    #     return list_result


    def parse_goettingen_RECORD_DICT_to_LDM_CKAN_DICT(self, goettingen_metadata):

        ldm_dict = self._get_LDM_vdataset_template()
        
        # idenfier
        identifier_type = 'DOI'
        identifier_url = self._get_goettingen_value(goettingen_metadata, ['identifier'])
        identifier = identifier_url.replace("https://doi.org/", "")
        publication_year = self._get_goettingen_value(goettingen_metadata, ['datePublished']).split("-")[0]

        if identifier_type == 'DOI':
            ldm_dict['doi'] = identifier
            ldm_dict['doi_date_published'] = publication_year
            ldm_dict['url'] = identifier_url

        # Creation date
        ldm_dict['source_metadata_created'] = publication_year

        # creators
        ldm_dict = self._get_goettingen_creators(goettingen_metadata, ldm_dict)

        # title
        title = self._get_goettingen_value(goettingen_metadata, ['name'])
        name = self.adjust_dataset_name(identifier_type+'-'+identifier)
        ldm_dict['title'] = title.capitalize()
        ldm_dict['name'] = name

        # rights - Already set while checking open license
        ldm_dict['license_id'] = self._get_goettingen_value(goettingen_metadata, ['license'])
        ldm_dict['license_title'] = self._get_goettingen_value(goettingen_metadata, ['license_title'])

        # descriptions
        ldm_dict['notes'] = self._get_goettingen_value(goettingen_metadata, ['description'])

        # publishers
        ldm_dict = self._get_goettingen_publishers(goettingen_metadata, ldm_dict)

        # publication year
        if publication_year:
            ldm_dict['publication_year'] = publication_year

        # subject areas
        ldm_dict = self._get_goettingen_subject_areas(goettingen_metadata, ldm_dict)

        # resource type
        # '@type': 'Dataset',
        resource_type = self._get_goettingen_value(goettingen_metadata, ['@type'])
        
        ldm_dict['resource_type'] = resource_type

        # related publications
        ldm_dict = self._get_goettingen_related_publications(goettingen_metadata, ldm_dict)
        
         # keywords
        ldm_dict = self._get_goettingen_keywords(goettingen_metadata, ldm_dict)

        return ldm_dict


    # def _get_goettingen_title(self, goettingen_metadata, ldm_dict):

    #     titles = goettingen_metadata.get('titles', [])
    #     title_txt = ""

    #     for title in titles:
    #         title_txt = title.get("title", "").get('title', "")
    #         break # just take first one
            
    #     return title_txt
    
    # def _get_goettingen_description(self, goettingen_metadata, ldm_dict):

    #     descriptions = goettingen_metadata.get('descriptions', [])
    #     description_txt = ""

    #     for description in descriptions:
    #         desc_type = self._get_goettingen_value(description, ['descriptionType'])
    #         desc_txt = self._get_goettingen_value(description, ['description', 'description'])
    #         desc = desc_type + ": " + desc_txt
    #         if description_txt:
    #             desc = '\r\n' + desc
    #         description_txt = description_txt + desc

    #     ldm_dict['notes'] = description_txt
    #     return ldm_dict

    def _get_goettingen_creators(self, goettingen_metadata, ldm_dict):

        # 'creator': [{'@type': 'Person', 
        #              'givenName': 'Sarah', 
        #              'familyName': 'Khan', 
        #              'name': 'Khan, Sarah'}],

        creators = goettingen_metadata.get('creator', [])
        extra_authors = []
        pos = 1
        for creator in creators:
            orcid = ""
            
            # first is author
            if pos == 1:
                ldm_dict['author'] = self._get_goettingen_value(creator, ['name'])
                ldm_dict['givenName'] = self._get_goettingen_value(creator, ['givenName'])
                ldm_dict['familyName'] = self._get_goettingen_value(creator, ['familyName'])
                ldm_dict['orcid'] = orcid
                pos += 1
            else:
                # following are extra_authors
                extra_author = {"extra_author": self._get_goettingen_value(creator, ['name']),
                                "givenName": self._get_goettingen_value(creator, ['givenName']),
                                "familyName": self._get_goettingen_value(creator, ['familyName']),
                                "orcid": orcid}
                extra_authors.append(extra_author)
        if extra_authors:
            ldm_dict['extra_authors'] = extra_authors

        return ldm_dict

    def _get_goettingen_keywords(self, goettingen_metadata, ldm_dict):

        keywords = goettingen_metadata.get('keywords', [])
        tag_list = []
        # filter subjects: the API is joining subjects and keywors as the result for keywords
        subjects = goettingen_metadata.get('subjects', [])

        for keyword in keywords:
            tag = keyword
            # create ckan tag dict
            # some cases are ; separated list of tags
            tag = tag.replace(';', ',')
            # some cases are "·" separated list of tags
            tag = tag.replace('·', ',')
            if ',' in tag: # some cases are comma separated list of tags
                for t in tag.split(','):
                    t = self._adjust_tag(t)
                    if t: # some cases list end with comma ,
                        if t not in subjects:    
                            tag_dict = { "display_name": t,
                                        "name": t,
                                        "state": "active",
                                        "vocabulary_id": None}
                            tag_list.append(tag_dict)
            else:
                tag = self._adjust_tag(tag)
                if tag:
                    if tag.strip() not in subjects:    
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

    def _get_goettingen_publishers(self, goettingen_metadata, ldm_dict):
        #'publisher': {'@type': 'Organization', 'name': 'GRO.data'},
        publisher = goettingen_metadata.get('publisher', [])
        
        #  CKAN   "publishers": [
        #         {
        #             "publisher": "publisher1"
        #         },
        #         {
        #             "publisher": "publisher2"
        #         }
        if 'name' in publisher:
            ldm_dict['publishers'] = [{'publisher': publisher['name'] }]

        return ldm_dict

    def _get_goettingen_subject_areas(self, goettingen_metadata, ldm_dict):

        s_areas = goettingen_metadata.get('subjects', [])
        s_areas_list = []

        for s_area in s_areas:
            # create ckan subject areas dict
            s_area_dict = { "subject_area_additional": "",
                            "subject_area_name": s_area }
            s_areas_list.append(s_area_dict)
        if s_areas_list:
            ldm_dict['subject_areas'] = s_areas_list

        return ldm_dict

    def _get_goettingen_related_publications(self, goettingen_metadata, ldm_dict):

        r_identifiers_list = []
        
        # Adding publications
        # "publications":[{"citation":"Government of India, Ministry of..",
        #                  "url":"http://fsi.nic.in/details.php?pgID=sb_64"}]
        publications = goettingen_metadata.get('publications', [])

        for pub in publications:
            citation = self._get_goettingen_value(pub, ['citation'])
            url = self._get_goettingen_value(pub, ['url'])
            id_relation = 'IsPublishedIn'
            # create ckan related identifiers dict
    #           repeating_subfields:
    # - field_name: identifier
    #   label: Identifier
    #   required: false
    # - field_name: identifier_type
    #   label: Type
    #   required: false
    # - field_name: relation_type
    #   label: Relation Type
    #   required: false
    # - field_name: title
    #   label: Title
    #   required: false
    # - field_name: year
    #   label: Year
    #   required: false
    # - field_name: authors
    #   label: Author/s
    #   required: false
    # - field_name: orcid_authors
    #   label: ORCID/s
    #   required: false
    # - field_name: email_authors
    #   label: Email/s
    #   required: false
    # - field_name: source
    #   label: Source
    #   required: false
            r_identifier_dict = { "identifier": url,
                            "identifier_type": 'URL',
                            "relation_type": id_relation,
                            "title": citation}
            r_identifiers_list.append(r_identifier_dict)
        if r_identifiers_list:
            ldm_dict['related_identifiers'] = r_identifiers_list

        return ldm_dict

    def _get_goettingen_value(self, goettingen_metadata, list_fields=[]):

        mt_dict = goettingen_metadata
        value = ""

        for field in list_fields:
            if isinstance(mt_dict, dict) and field in mt_dict:
                mt_dict = mt_dict[field]
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
            "owner_org": "goettingen",
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
             "isopen": True,
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
             "organization": self._get_goettingen_organization_ckan_dict(),
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
            Using the goettingen harvesting tool determine if the current schema is matching the schema implemented.
            Returning a dict with the results of comparing the metadata schema used in the code
            with the metadata schema retrieved by remote servers

            result = {'status_ok': True,
                      'report': 'Text explaining the results'}
        '''

        if not self.current_schema_report:
            self.current_schema_report = self._get_schema_report()

        return self.current_schema_report


    def _get_schema_report(self):

        current_schema = {'current_goettingen_schema': self.current_dataset_schema,
                          'current_dataset_schema': self.current_dataset_schema
                          }
        schema_ok = True

        errors = {}
        
        report = {'status_ok': schema_ok,
                  'report': {'current_metadata': current_schema,
                             'errors': errors},
                  }
        return report


    def get_organization(self, name='goettingen'):
        '''
            In goettingen Datasets are no related to a specific organization.
            goettingen's imported datasets allways belongs to goettingen organization in LDM.

            Returns: a dictionary with the organization's metadata
        '''

        self.set_log("infos_searching_org", name)

        org_dict = self._get_goettingen_organization_ckan_dict()

        return org_dict

    def _get_goettingen_organization_ckan_dict(self):

        org_dict = {
        "approval_status": "approved",
        "description": "Göttingen Research Online is an institutional repository for the publication of research data at the Göttingen Campus. It is managed by the Göttingen eResearch Alliance, a joint group of SUB and GWDG. .",
        "display_name": "GöttingenResearchOnline",
        "image_display_url": "logo-goettingen.png",
        "image_url": "logo-goettingen.png",
        "is_organization": True,
        "name": "goettingen",
        "state": "active",
        "title": "GöttingenResearchOnline",
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
        exclude_in_comparison = ['owner_org', 'license_title', 'organization', 'tags', 'isopen']

        for field in remote_dataset.keys():

            # special case  tags
            if field == 'keywords':
                for tag in remote_dataset['keywords']:
                    tag_name = tag['display_name']
                    tag_found = False
                    for tag_local in local_dataset['tags']:
                        if tag_local['display_name'] == tag_name:
                            tag_found = True
                    if not tag_found:
                        result = True
                        break

            print("\nField: ", field, " L= ", local_dataset.get(field, "KEY ERROR"), " R= ", remote_dataset[field])
            # print("\nField: ", field)

            if field in local_dataset and field not in exclude_in_comparison:
                # print("\nField: ", field, " L= ", local_dataset[field], " R= ", remote_dataset[field])
                if local_dataset[field] != remote_dataset[field]:
                    print("\nField: ", field)
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
            self.logger.message = "Searching Datasets in goettingen's harvesting tool."

        def error_API(data):
            self.logger.message = "Error Connecting goettingen's harvesting tool: " + data

        def error_api_data(data):
            self.logger.message = "Error retrieving data from API: " + data

        def infos_ds_found(data):
            self.logger.message = "Number of Datasets found: " + data

        def infos_ds_metadata_found(data):
            self.logger.message = "Metadata found with name: " + data

        def infos_searching_org(data):
            self.logger.message = "Searching Organizaion in goettingen API. Name: " + data

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
