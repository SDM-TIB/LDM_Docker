from ckanext.tibimport.logic2 import DatasetParser
import requests
import json
import xmltodict
from xml.etree import ElementTree
import urllib.parse
import ckan.lib.helpers as h

class RADAR_ParserProfile(DatasetParser):
    '''

    A class defined to access RADAR's Datasets
    using the RADAR's harvesting tool https://www.radar-service.eu/oai/ and parsing the retrieved
    data to dataset_dic as needed by the LDM

    RADAR Harvesting tool docs: https://www.openarchives.org/OAI/openarchivesprotocol.html#ListRecords

    '''

    def __init__(self):
        self.repository_name = "RADAR (Research Data Repository)"
        self.dataset_title_prefix = "rdr-"
        # Ex. https://www.radar-service.eu/oai/OAIHandler?verb=ListRecords&from=0001-01-01T00:00:00Z&until=9999-12-31T23:59:59Z&metadataPrefix=radar

        self.radar_ListRecords_url = 'https://www.radar-service.eu/oai/OAIHandler?verb=ListRecords'
        self.radar_from_date = '0001-01-01T00:00:00Z'
        self.radar_until_date = '9999-12-31T23:59:59Z'
        self.radar_metadataPrefix = 'radar'
        # Schema values
        self.ns0 = '{http://www.openarchives.org/OAI/2.0/}'
        self.ns2 = '{http://radar-service.eu/schemas/descriptive/radar/v09/radar-dataset}'
        self.ns3 = '{http://radar-service.eu/schemas/descriptive/radar/v09/radar-elements}'

        # Set to True to force update of all datasets
        self.force_update = False

        # Total of datasets available in RADAR
        self.total_radar_datasets = 0

        # schema validation report
        self.current_schema_report = {}


        self.log_file_prefix = "RDR_"
        super().__init__()


    def get_all_datasets_dicts(self):
        '''
             Using RADAR's "ListRecords" list get a list of dictionaries with the complete Dataset's
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
            dict_list.append(self.parse_RADAR_RECORD_DICT_to_LDM_CKAN_DICT(dataset))

        return dict_list

    def get_datasets_list(self, ds_list=[], resumption_token=''):
        '''
            Uses the RADAR HARVESTING TOOL to retrieve a list of datasets in a list of dictionaries

            Returns: a list of datasets or an empty list
            Notice: the dictionaries contains metadata NOT in CKAN's schema
        '''
        self.set_log("infos_searching_ds")

        if not resumption_token:
            # Find first page of Datasets
            url = self.radar_ListRecords_url+'&from='+self.radar_from_date+'&until='+\
                  self.radar_until_date+'&metadataPrefix='+self.radar_metadataPrefix

        else:
            # Find page from resumption token url
            url = self.radar_ListRecords_url+'&resumptionToken=' + resumption_token
       # print("\nURL\n", url)

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
        xml_tree_data = ElementTree.fromstring(response.content)

        # get schema data only first time
        if not self.current_schema_report:
            self.current_schema_report = self._get_schema_report(xml_tree_data)

#        tags = [elem.tag for elem in xml_tree_data.iter()]
#        print('TAGS/n', tags)
        if ds_list:
            ds_list.extend(self.parse_RADAR_XML_result_to_DICT(xml_tree_data))
        else:
            ds_list = self.parse_RADAR_XML_result_to_DICT(xml_tree_data)

        # GET RESUMPTION TOKEN FROM xml_tree_data
        resumption_token = self._get_radar_resumption_token(xml_tree_data)

        if resumption_token['resumptionToken']:
            #print("\nRT:\n", resumption_token)
            self.get_datasets_list(ds_list, resumption_token['resumptionToken'])

        return ds_list

    def _get_radar_resumption_token(self, xml_tree_data):
        r_token = {'resumptionToken': ''}

        for record in xml_tree_data.iter(self.ns0 + 'resumptionToken'):
            if record.text:
                r_token['resumptionToken'] = record.text
                r_token.update(record.attrib)

        if 'completeListSize' in r_token:
            self.total_radar_datasets = int(r_token['completeListSize'])
        return r_token


    def parse_RADAR_XML_result_to_DICT(self, xml_tree_data):

        ds_result = []

        for record in xml_tree_data.iter(self.ns0 + 'record'):
            ds_result.append(self.parse_RADAR_XML_RECORD_to_DICT(record))

        return ds_result


    def parse_RADAR_XML_RECORD_to_DICT(self, xml_tree_obj):

        record = xml_tree_obj
        ns0 = self.ns0
        ns2 = self.ns2
        ns3 = self.ns3
        ds_result = {}

        # HEADER
        # <ns0:record>
        #   <ns0:header>
        #       <ns0:identifier>10.22000/447</ns0:identifier>
        #       <ns0:datestamp>2022-04-04T09:06:49Z</ns0:datestamp>
        #   </ns0:header>
        identifier = record.find('./' + ns0 + 'header/' + ns0 + 'identifier').text
        datestamp = record.find('./' + ns0 + 'header/' + ns0 + 'datestamp').text
        ds_result['header'] = {'identifier': identifier, 'datestamp': datestamp}

        # <ns0:metadata><ns2:radarDataset>
        ds_result['metadata'] = {'radarDataset': {}}

    # METADATA MANDATORY
        # METADATA - IDENTIFIER
        #     <ns3:identifier identifierType="DOI">10.22000/447</ns3:identifier>
        path_from_radardataset = ns3 + 'identifier'
        ds_result['metadata']['radarDataset']['identifier'] = self._find_metadata_in_record_simple(record, path_from_radardataset)


        # METADATA - CREATORS
        #     <ns3:creators>
        #         <ns3:creator>
        #             <ns3:creatorName>Macotela, Edith Liliana</ns3:creatorName>
        #             <ns3:givenName>Edith Liliana</ns3:givenName>
        #             <ns3:familyName>Macotela</ns3:familyName>
        #             <ns3:nameIdentifier schemeURI="http://orcid.org/" nameIdentifierScheme="ORCID">0000-0003-3076-1946</ns3:nameIdentifier>
        #             <ns3:creatorAffiliation>Leibniz Institute of Atmospheric Physics at the University of Rostock</ns3:creatorAffiliation>
        #         </ns3:creator>
        #     </ns3:creators>
        path_from_radardataset = ns3 + 'creators/' + ns3 + 'creator'
        subfields = [ns3+'creatorName', ns3+'givenName', ns3+'familyName', ns3+'creatorAffiliation', ns3+'nameIdentifier']
        ds_result['metadata']['radarDataset']['creators'] = self._find_metadata_in_record(record, path_from_radardataset, 'creator', subfields)

        # METADATA TITLE
        #     <ns3:title>MacotelaGRL2021</ns3:title>
        path_from_radardataset = ns3 + 'title'
        ds_result['metadata']['radarDataset']['title'] = self._find_metadata_in_record_simple(record, path_from_radardataset)

        # METADATA PUBLISHERS
        #     <ns3:publishers>
        #         <ns3:publisher>Leibniz Institute of Atmospheric Physics at the University of Rostock</ns3:publisher>
        #     </ns3:publishers>
        path_from_radardataset = ns3 + 'publishers/' + ns3 + 'publisher'
        ds_result['metadata']['radarDataset']['publishers'] = self._find_metadata_in_record(record,
                                                                                            path_from_radardataset,
                                                                                            'publisher')

        # METADATA - PRODUCTION YEAR
        #     <ns3:productionYear>2021</ns3:productionYear>
        path_from_radardataset = ns3 + 'productionYear'
        ds_result['metadata']['radarDataset']['productionYear'] = self._find_metadata_in_record_simple(record,
                                                                                                       path_from_radardataset)

        # METADATA - PUBLICATION YEAR
        #     <ns3:publicationYear>2021</ns3:publicationYear>
        path_from_radardataset = ns3 + 'publicationYear'
        ds_result['metadata']['radarDataset']['publicationYear'] = self._find_metadata_in_record_simple(record,
                                                                                                        path_from_radardataset)

        # METADATA SUBJECT AREAS
        #     <ns3:subjectAreas>
        #         <ns3:subjectArea>
        #             <ns3:controlledSubjectAreaName>Physics</ns3:controlledSubjectAreaName>
        #         </ns3:subjectArea>
        #         <ns3:subjectArea>
        #             <ns3:controlledSubjectAreaName>Other</ns3:controlledSubjectAreaName>
        #             <ns3:additionalSubjectAreaName>Atmospheric Physics</ns3:additionalSubjectAreaName>
        #         </ns3:subjectArea>
        #     </ns3:subjectAreas>
        subfields = [ns3 + 'controlledSubjectAreaName', ns3 + 'additionalSubjectAreaName']
        path_from_radardataset = ns3 + 'subjectAreas/' + ns3 + 'subjectArea'
        ds_result['metadata']['radarDataset']['subjectAreas'] = self._find_metadata_in_record(record,
                                                                                              path_from_radardataset,
                                                                                              'subjectArea', subfields)

        # METADATA RESOURCE TYPE
        #     <ns3:resource resourceType="Dataset" />
        path_from_radardataset = ns3 + 'resource'
        ds_result['metadata']['radarDataset']['resource'] = self._find_metadata_in_record_simple(record,
                                                                                                 path_from_radardataset)

        # METADATA RIGHTS
        #     <ns3:rights>
        #         <ns3:controlledRights>CC BY 4.0 Attribution</ns3:controlledRights>
        #     </ns3:rights>
        subfields = [ns3 + 'controlledRights', ns3 + 'additionalRights']
        path_from_radardataset = ns3 + 'rights'
        ds_result['metadata']['radarDataset']['rights'] = self._find_metadata_in_record(record,
                                                                                        path_from_radardataset,
                                                                                        'rights', subfields)
        # METADATA RIGHTS HOLDERS
        #     <ns3:rightsHolders>
        #         <ns3:rightsHolder>Leibniz Institute of Atmospheric Physics at the University of Rostock</ns3:rightsHolder>
        #     </ns3:rightsHolders>
        path_from_radardataset = ns3 + 'rightsHolders/' + ns3 + 'rightsHolder'
        ds_result['metadata']['radarDataset']['rightsHolders'] = self._find_metadata_in_record(record,
                                                                                               path_from_radardataset,
                                                                                               'rightsHolder')

    # OPTIONAL METADATA
        # METADATA ADDITIONAL TITLES
        # <additionalTitles>
        #     <additionalTitle additionalTitleType="Subtitle">Supplementary Data PhD Thesis</additionalTitle>
        #     <additionalTitle additionalTitleType="Subtitle">Supplementary Data PhD Thesis</additionalTitle>
        # </additionalTitles>
        path_from_radardataset = ns3 + 'additionalTitles/' + ns3 + 'additionalTitle'
        ds_result['metadata']['radarDataset']['additionalTitles'] = self._find_metadata_in_record(record,
                                                                                               path_from_radardataset,
                                                                                               'additionalTitle')

        # METADATA - DESCRIPTIONS
        #     <ns3:descriptions>
        #         <ns3:description descriptionType="Abstract">Data to reproduce the figures in publication.</ns3:description>
        #     </ns3:descriptions>
        path_from_radardataset = ns3 + 'descriptions/' + ns3 + 'description'
        ds_result['metadata']['radarDataset']['descriptions'] = self._find_metadata_in_record(record,
                                                                                              path_from_radardataset,
                                                                                              'description')

        # METADATA - KEYWORDS
        # <keywords>
        #     <keyword>downy mildew resistance</keyword>
        #     <keyword>untargeted metabolomics</keyword>
        # </keywords>
        path_from_radardataset = ns3 + 'keywords/' + ns3 + 'keyword'
        ds_result['metadata']['radarDataset']['keywords'] = self._find_metadata_in_record(record, path_from_radardataset, 'keyword')

        # METADATA - CONTRIBUTORS
        # <contributors>
        #     <contributor contributorType="Producer">
        #           <contributorName>Pohl, Ernst</contributorName>
        #           <givenName>Ernst</givenName>
        #           <familyName>Pohl</familyName>
        #           <nameIdentifier schemeURI="http://orcid.org/" nameIdentifierScheme="ORCID">0000-0002-5168-4540</nameIdentifier>
        #           <contributorAffiliation>Universität Bonn, Institut für Archäologie und Kulturanthropologie, Abteilung Vor- und Frühgeschichtliche Archäologie</contributorAffiliation>
        #     </contributor>
        # </contributors>
        path_from_radardataset = ns3 + 'contributors/' + ns3 + 'contributor'
        subfields = [ns3 + 'contributorName', ns3 + 'givenName', ns3 + 'familyName', ns3 + 'contributorAffiliation',
                     ns3 + 'nameIdentifier']
        ds_result['metadata']['radarDataset']['contributors'] = self._find_metadata_in_record(record,
                                                                                          path_from_radardataset,
                                                                                          'contributor', subfields)

        # METADATA LANGUAGE
        #     <ns3:language>eng</ns3:language>
        path_from_radardataset = ns3 + 'language'
        ds_result['metadata']['radarDataset']['language'] = self._find_metadata_in_record_simple(record,
                                                                                                 path_from_radardataset)
        # METADATA - ALTERNATE IDENTIFIERS
        # <alternateIdentifiers>
        #     <alternateIdentifier alternateIdentifierType="GenBank accession number">MN729603</alternateIdentifier>
        #     <alternateIdentifier alternateIdentifierType="CAS Registry Number">111830-76-3</alternateIdentifier>
        # </alternateIdentifiers>
        path_from_radardataset = ns3 + 'alternateIdentifiers/' + ns3 + 'alternateIdentifier'
        ds_result['metadata']['radarDataset']['alternateIdentifiers'] = self._find_metadata_in_record(record, path_from_radardataset, 'alternateIdentifier')

        # METADATA - RELATED IDENTIFIERS
        #     <ns3:relatedIdentifiers>
        #         <ns3:relatedIdentifier relatedIdentifierType="DOI" relationType="IsSupplementTo">10.1029/2021GL094581</ns3:relatedIdentifier>
        #     </ns3:relatedIdentifiers>
        # Types =
        # - ARK
        # - arXiv
        # - bibcode
        # - DOI
        # - EAN13
        # - EISSN
        # - Handle
        # - IGSN
        # - ISBN
        # - ISSN
        # - ISTC
        # - LISSN
        # - LSID
        # - PMID
        # - PURL
        # - UPC
        # - URL
        # - URN
        # Relation Types:
        # - IsCitedBy
        # - Cites
        # - IsSupplementTo
        # - IsSupplementedBy
        # - IsContinuedBy
        # - Continues
        # - HasMetadata
        # - Is MetadataFor
        # - IsNewVersionOf
        # - IsPreviousVersionOf
        # - IsPartOf
        # - HasPart
        # - IsReferencedBy
        # - References
        # - IsDocumentedBy
        # - Documents
        # - IsCompiledBy
        # - Compiles
        # - IsVariantFormOf
        # - IsOriginalFormOf
        # - IsIdenticalTo
        # - IsReviewedBy
        # - Reviews
        # - IsDerivedFrom
        # - IsSourceOf
        path_from_radardataset = ns3 + 'relatedIdentifiers/' + ns3 + 'relatedIdentifier'
        ds_result['metadata']['radarDataset']['relatedIdentifiers'] = self._find_metadata_in_record(record, path_from_radardataset, 'relatedIdentifier')

        # METADATA - GEOLOCATION
        # <geoLocations>
        #     <geoLocation>
        #         <geoLocationCountry>GERMANY</geoLocationCountry>
        #         <geoLocationRegion>North-Rhine Westphalia, Rhineland-Platinate</geoLocationRegion>
        #         <geoLocationPoint>00000</geoLocationPoint>
        #         <geoLocationBox>11111</geoLocationBox>
        #     </geoLocation>
        # </geoLocations>
        path_from_radardataset = ns3 + 'geoLocations/' + ns3 + 'geoLocation'
        subfields = [ns3 + 'geoLocationCountry', ns3 + 'geoLocationRegion', ns3 + 'geoLocationPoint', ns3 + 'geoLocationBox']
        ds_result['metadata']['radarDataset']['geoLocations'] = self._find_metadata_in_record(record,
                                                                                          path_from_radardataset,
                                                                                          'geoLocation', subfields)

        # METADATA - DATA SOURCES
        # <dataSources>
        #     <dataSource dataSourceDetail="Instrument">Waters e2695 chromatography workstation with photodiode array detector (PDA) and a QDA mass detector (Waters)</dataSource>
        #     <dataSource dataSourceDetail="Instrument">BioRad CFX ConnectTM Real-Time System</dataSource>
        # </dataSources>
        path_from_radardataset = ns3 + 'dataSources/' + ns3 + 'dataSource'
        ds_result['metadata']['radarDataset']['dataSources'] = self._find_metadata_in_record(record, path_from_radardataset, 'dataSource')

        # METADATA - SOFTWARE TYPE
        # <software>
        #     <softwareType type="Resource Production">
        #         <softwareName softwareVersion="3">Waters Empower</softwareName>
        #         <softwareName softwareVersion="2.1">BioRad CFX (qPCR)</softwareName>
        #         <alternativeSoftwareName alternativeSoftwareVersion="3.6.2">R</alternativeSoftwareName>
        #     </softwareType>
        # </software>
        path_from_radardataset = ns3 + 'software/' + ns3 + 'softwareType'
        subfields = [ns3 + 'softwareName', ns3 + 'alternativeSoftwareName']
        ds_result['metadata']['radarDataset']['software'] = self._find_metadata_in_record(record,
                                                                                          path_from_radardataset,
                                                                                          'softwareType', subfields)
        # METADATA - DATA PROCESSING
        # <processing>
        #     <dataProcessing>Kollisionsdetektion</dataProcessing>
        # </processing>
        path_from_radardataset = ns3 + 'processing/' + ns3 + 'dataProcessing'
        ds_result['metadata']['radarDataset']['processing'] = self._find_metadata_in_record(record, path_from_radardataset, 'dataProcessing')

        # METADATA - RELATED INFORMATIONS
        # <relatedInformations>
        #     <relatedInformation relatedInformationType="10.1038/s42003-021-01967-9">DOI Journal Article</relatedInformation>
        # </relatedInformations>
        path_from_radardataset = ns3 + 'relatedInformations/' + ns3 + 'relatedInformation'
        ds_result['metadata']['radarDataset']['relatedInformations'] = self._find_metadata_in_record(record, path_from_radardataset, 'relatedInformation')

        # METADATA - FUNDING REFERENCES
        # <fundingReferences>
        #     <fundingReference>
        #         <funderName>Landwirtschaftliche Rentenbank</funderName>
        #         <funderIdentifier type="Other">Project No. 182849149 (SFB 953)</funderIdentifier>
        #         <awardNumber>UBO 53C-50009_00_71030002</awardNumber>
        #         <awardURI>https://gepris.dfg.de/gepris/projekt/318064602</awardURI>
        #         <awardTitle>Biosynthese der Piperamide im schwarzen Pfeffer (Piper nigrum)</awardTitle>
        #     </fundingReference>
        # </fundingReferences>
        path_from_radardataset = ns3 + 'fundingReferences/' + ns3 + 'fundingReference'
        subfields = [ns3 + 'funderName', ns3 + 'funderIdentifier', ns3 + 'awardNumber', ns3 + 'awardURI', ns3 + 'awardTitle']
        ds_result['metadata']['radarDataset']['fundingReferences'] = self._find_metadata_in_record(record,
                                                                                          path_from_radardataset,
                                                                                          'fundingReference', subfields)

        return ds_result

    def _find_metadata_in_record_simple(self, record, path, subfields=[]):

        target = './' + self.ns0 + 'metadata/' + self.ns2 + 'radarDataset/' + path
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

        target = './' + self.ns0 + 'metadata/' + self.ns2 + 'radarDataset/' + path
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


    def parse_RADAR_RECORD_DICT_to_LDM_CKAN_DICT(self, radar_dict):

        ldm_dict = self._get_LDM_vdataset_template()
        radar_metadata = radar_dict['metadata']['radarDataset']

        # idenfier
        identifier_type = self._get_radar_value(radar_metadata, ['identifier', 'identifierType'])
        identifier = self._get_radar_value(radar_metadata, ['identifier', 'identifier'])
        publication_year = self._get_radar_value(radar_metadata, ['publicationYear'])

        if identifier_type == 'DOI':
            ldm_dict['doi'] = identifier
            ldm_dict['doi_date_published'] = publication_year
            ldm_dict['url'] = 'https://doi.org/' + identifier

        # Creation date
        ldm_dict['source_metadata_created'] = publication_year

        # creators
        ldm_dict = self._get_radar_creators(radar_metadata, ldm_dict)

        # title
        title = self._get_radar_value(radar_metadata, ['title'])
        name = self.adjust_dataset_name(identifier_type+'-'+identifier)
        ldm_dict['title'] = title.capitalize()
        ldm_dict['name'] = name

        # rights
        rights = radar_metadata.get('rights', [])
        if rights:
            ldm_dict['license_id'] = self._get_radar_value(rights[0], ['rights', 'controlledRights'])
            ldm_dict['license_title'] = self._get_radar_value(rights[0], ['rights', 'additionalRights'])

        # descriptions
        ldm_dict = self._get_radar_description(radar_metadata, ldm_dict)

        # keywords
        ldm_dict = self._get_radar_keywords(radar_metadata, ldm_dict)

        # publishers
        ldm_dict = self._get_radar_publishers(radar_metadata, ldm_dict)

        # production year
        production_year = self._get_radar_value(radar_metadata, ['productionYear'])
        if production_year:
            ldm_dict['production_year'] = production_year

        # publication year
        if publication_year:
            ldm_dict['publication_year'] = publication_year

        # subject areas
        ldm_dict = self._get_radar_subject_areas(radar_metadata, ldm_dict)

        # resource type
        resource_type = self._get_radar_value(radar_metadata, ['resource', 'resourceType'])
        resource = self._get_radar_value(radar_metadata, ['resource', 'resource'])
        resource_type_txt = resource_type
        if resource_type_txt and resource:
            resource_type_txt = resource_type_txt + " - " + resource
        else:
            resource_type_txt = resource

        ldm_dict['resource_type'] = resource_type_txt

        # related identifiers
        ldm_dict = self._get_radar_related_identifiers(radar_metadata, ldm_dict)

        return ldm_dict


    def _get_radar_description(self, radar_metadata, ldm_dict):

        descriptions = radar_metadata.get('descriptions', [])
        description_txt = ""

        for description in descriptions:
            desc_type = self._get_radar_value(description, ['descriptionType'])
            desc_txt = self._get_radar_value(description, ['description', 'description'])
            desc = desc_type + ": " + desc_txt
            if description_txt:
                desc = '\r\n' + desc
            description_txt = description_txt + desc

        ldm_dict['notes'] = description_txt
        return ldm_dict

    def _get_radar_creators(self, radar_metadata, ldm_dict):

        creators = radar_metadata.get('creators', [])
        extra_authors = []
        pos = 1
        for creator in creators:
            orcid = ""
            author_id_type = self._get_radar_value(creator, ['creator', 'nameIdentifier', 'nameIdentifierScheme'])
            if author_id_type.lower() == 'orcid':
                orcid = self._get_radar_value(creator, ['creator', 'nameIdentifier', 'nameIdentifier'])

            # first is author
            if pos == 1:
                ldm_dict['author'] = self._get_radar_value(creator, ['creator', 'creatorName'])
                ldm_dict['orcid'] = orcid
                pos += 1
            else:
                # following are extra_authors
                extra_author = {"extra_author": self._get_radar_value(creator, ['creator', 'creatorName']),
                                "orcid": orcid}
                extra_authors.append(extra_author)
        if extra_authors:
            ldm_dict['extra_authors'] = extra_authors

        return ldm_dict

    def _get_radar_keywords(self, radar_metadata, ldm_dict):

        keywords = radar_metadata.get('keywords', [])
        tag_list = []

        for keyword in keywords:
            tag = self._get_radar_value(keyword, ['keyword', 'keyword'])
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
        return tag

    def _get_radar_publishers(self, radar_metadata, ldm_dict):

        publishers = radar_metadata.get('publishers', [])
        publishers_list = []

        for publisher in publishers:
            val = self._get_radar_value(publisher, ['publisher', 'publisher'])
            # create ckan publisher dict
            publisher_dict = {"publisher": val}
            publishers_list.append(publisher_dict)
        if publishers_list:
            ldm_dict['publishers'] = publishers_list

        return ldm_dict

    def _get_radar_subject_areas(self, radar_metadata, ldm_dict):

        s_areas = radar_metadata.get('subjectAreas', [])
        s_areas_list = []

        for s_area in s_areas:
            name = self._get_radar_value(s_area, ['subjectArea', 'controlledSubjectAreaName'])
            add_name = self._get_radar_value(s_area, ['subjectArea', 'additionalSubjectAreaName'])
            # create ckan subject areas dict
            s_area_dict = { "subject_area_additional": add_name,
                            "subject_area_name": name }
            s_areas_list.append(s_area_dict)
        if s_areas_list:
            ldm_dict['subject_areas'] = s_areas_list

        return ldm_dict

    def _get_radar_related_identifiers(self, radar_metadata, ldm_dict):

        r_identifiers = radar_metadata.get('relatedIdentifiers', [])
        r_identifiers_list = []

        for r_id in r_identifiers:
            identifier = self._get_radar_value(r_id, ['relatedIdentifier', 'relatedIdentifier'])
            id_type = self._get_radar_value(r_id, ['relatedIdentifiers', 'relatedIdentifierType'])
            id_relation = self._get_radar_value(r_id, ['relatedIdentifiers', 'relationType'])
            # create ckan related identifiers dict
            r_identifier_dict = { "identifier": identifier,
                            "identifier_type": id_type,
                            "relation_type": id_relation}
            r_identifiers_list.append(r_identifier_dict)
        if r_identifiers_list:
            ldm_dict['related_identifiers'] = r_identifiers_list

        return ldm_dict

    def _get_radar_value(self, radar_metadata, list_fields=[]):

        mt_dict = radar_metadata
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
            "owner_org": "radar",
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
             "organization": self._get_radar_organization_ckan_dict(),
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
            Using the RADAR harvesting tool determine if the current schema is matching the schema implemented.
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
            url = self.radar_ListRecords_url + '&from=' + self.radar_from_date + '&until=' + \
                      self.radar_until_date + '&metadataPrefix=' + self.radar_metadataPrefix
            # Find page of Datasets
            try:
                response = requests.get(url)
            except requests.exceptions.RequestException as e:  # This is the correct syntax
                self.set_log("error_API", self.radar_ListRecords_url + " - " + e.__str__())

            if not response.ok:
                self.set_log("error_api_data", self.radar_ListRecords_url)
            else:
                obj_tree = ElementTree.fromstring(response.content)

        if obj_tree is None:
            # Error accessing API
            schema_dataset = None
            schema_dataset_element = None
        else:
            schema_dataset = obj_tree.find(self.ns0 + 'ListRecords/' + self.ns0 + 'record/' + self.ns0 + 'metadata/' + self.ns2 + 'radarDataset')
            schema_dataset_element = obj_tree.find(self.ns0 + 'ListRecords/' + self.ns0 + 'record/' + self.ns0 + 'metadata/' + self.ns2 + 'radarDataset/' + self.ns3 + 'identifier')

        current_schema = {'current_radar_schema': self.ns0,
                          'current_dataset_schema': self.ns2,
                          'current_dataset_element_schema': self.ns3}
        schema_ok = True

        errors = {}
        # if both elements were found means the schema is correct
        if schema_dataset is None:
            errors['dataset_schema'] = 'ERROR: Current Dataset Schema is incorrect.'
            schema_ok = False
        if schema_dataset_element is None:
            errors['dataset_element_schema'] = 'ERROR: Current Dataset Element Schema is incorrect.'
            schema_ok = False

        report = {'status_ok': schema_ok,
                  'report': {'current_metadata': current_schema,
                             'errors': errors},
                  }
        return report


    def get_organization(self, name='radar'):
        '''
            In RADAR Datasets are no related to a specific organization.
            RADAR's imported datasets allways belongs to RADAR organization in LDM.

            Returns: a dictionary with the organization's metadata
        '''

        self.set_log("infos_searching_org", name)

        org_dict = self._get_radar_organization_ckan_dict()

        return org_dict

    def _get_radar_organization_ckan_dict(self):

        org_dict = {
        "approval_status": "approved",
        "description": "RADAR (Research Data Repository) is a cross-disciplinary repository for archiving and publishing research data from completed scientific studies and projects. The focus is on research data from subjects that do not yet have their own discipline-specific infrastructures for research data management. ",
        "display_name": "RADAR",
        "image_display_url": "radar-logo.svg",
        "image_url": "radar-logo.svg",
        "is_organization": True,
        "name": "radar",
        "state": "active",
        "title": "RADAR",
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
            self.logger.message = "Searching Datasets in RADAR's harvesting tool."

        def error_API(data):
            self.logger.message = "Error Connecting RADAR's harvesting tool: " + data

        def error_api_data(data):
            self.logger.message = "Error retrieving data from API: " + data

        def infos_ds_found(data):
            self.logger.message = "Number of Datasets found: " + data

        def infos_ds_metadata_found(data):
            self.logger.message = "Metadata found with name: " + data

        def infos_searching_org(data):
            self.logger.message = "Searching Organizaion in RADAR API. Name: " + data

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
