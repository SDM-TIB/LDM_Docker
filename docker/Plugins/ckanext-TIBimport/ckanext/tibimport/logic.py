

import requests
import json
import xml
import rdflib
import rdflib.parser
from rdflib import URIRef, BNode, Literal
from ckanext.tibimport.exceptions import RDFParserException
from rdflib.namespace import Namespace, RDF
from ckan.lib.munge import munge_tag
from ckan.model.license import LicenseRegister
from ckantoolkit import config
from ckan.plugins import toolkit
import ckan.model as model
from ckan.model import Session as session


DCT = Namespace("http://purl.org/dc/terms/")
DCAT = Namespace("http://www.w3.org/ns/dcat#")
ADMS = Namespace("http://www.w3.org/ns/adms#")
VCARD = Namespace("http://www.w3.org/2006/vcard/ns#")
FOAF = Namespace("http://xmlns.com/foaf/0.1/")
SCHEMA = Namespace('http://schema.org/')
TIME = Namespace('http://www.w3.org/2006/time')
LOCN = Namespace('http://www.w3.org/ns/locn#')
GSP = Namespace('http://www.opengis.net/ont/geosparql#')
OWL = Namespace('http://www.w3.org/2002/07/owl#')
SPDX = Namespace('http://spdx.org/rdf/terms#')

GEOJSON_IMT = 'https://www.iana.org/assignments/media-types/application/vnd.geo+json'

PREFIX_MAILTO = u'mailto:'
d = toolkit.g

class CKANDatasetImporter:

    def __init__(self, rdf_parser):
        self.rdf_parser  = rdf_parser

 #     def get_datasets(self):
 #         self.filename = self.get_valid_filename(self.resource_id + "_" + self.resource_date) + ".ipynb"
#          self.filefullpath = self.filepath + "/" + self.filename

      # def get_valid_filename(self, s):
      #     return re.sub('[^\w_)( -]', '', s).lower()
      #
      # def get_notebooks_file(self):
      #     try:
      #         # get file from url
      #         file_request = requests.get(self.resource_url, allow_redirects=True)
      #         # save file in path
      #         open(self.filefullpath, 'wb').write(file_request.content)
      #         os.chmod(self.filefullpath, 0o444)
      #     except requests.exceptions.RequestException as e:  # This is the correct syntax
      #         print("Error finding resource file on the web:", e)
      #         self.filefullpath = "ERROR"
      #
      # def file_exists(self):
      #     return os.path.isfile(self.filefullpath)

    def _add_dataset_to_CKAN(self, dataset_dict):
        context = {'model': model, 'session': session, 'user': toolkit.g.user}

        toolkit.get_action('package_create')(context, dataset_dict)
        aux = ""


    def add_a_test_dataset(self):
        url = "https://data.uni-hannover.de/dataset/a-generic-gust-definition-and-detection-method-based-on-wavelet-analysis.rdf"
        rdfdata = self.rdf_parser._get_rdfdata_from_rdfurl(url)
        self.rdf_parser.parse_to_rdf_class(rdfdata)
        dataset_dict = self.rdf_parser.parse_dataset_to_ckan_dict()
        org_title = dataset_dict["extras"][6]["value"]
        org_dict = self.rdf_parser.get_organization_data_from_api(org_title)
        self.rdf_parser.create_new_organization(org_dict)
        dataset_dict['owner_org'] = org_title.replace(" ","-").lower()
        dataset_dict['name'] = dataset_dict["title"].replace(" ","-").lower()
        self._add_dataset_to_CKAN(dataset_dict)

class RDFParser():
    '''
    An RDF to CKAN parser based on rdflib

    Supports different profiles which are the ones that will generate
    CKAN dicts from the RDF graph.
    '''

    def __init__(self):
        self.g = rdflib.ConjunctiveGraph()
        self._licenceregister_cache = None
        self.compatibility_mode = False


#    def _datasets(self):
#         '''
#         Generator that returns all DCAT datasets on the graph
#
#         Yields rdflib.term.URIRef objects that can be used on graph lookups
#         and queries
#         '''
#         for dataset in self.g.subjects(RDF.type, DCAT.Dataset):
#             yield get_dataset_dict

    # def next_page(self):
    #     '''
    #     Returns the URL of the next page or None if there is no next page
    #     '''
    #     for pagination_node in self.g.subjects(RDF.type, HYDRA.PagedCollection):
    #         for o in self.g.objects(pagination_node, HYDRA.nextPage):
    #             return str(o)
    #     return None


    def parse_to_rdf_class(self, data, _format=None):
        '''
        Parses and RDF graph serialization and into the class graph

        It calls the rdflib parse function with the provided data and format.

        Data is a string with the serialized RDF graph (eg RDF/XML, N3
        ... ). By default RF/XML is expected. The optional parameter _format
        can be used to tell rdflib otherwise.

        It raises a ``RDFParserException`` if there was some error during
        the parsing.

        Returns nothing. Loads the RDF graph in object property: g
        '''

        _format = self.url_to_rdflib_format(_format)
        if not _format or _format == 'pretty-xml':
            _format = 'xml'

        try:
            self.g.parse(data=data, format=_format)
        # Apparently there is no single way of catching exceptions from all
        # rdflib parsers at once, so if you use a new one and the parsing
        # exceptions are not cached, add them here.
        # PluginException indicates that an unknown format was passed.
        except (SyntaxError, xml.sax.SAXParseException,
                rdflib.plugin.PluginException, TypeError) as e:

            raise RDFParserException(e)

    def supported_formats(self):
        '''
        Returns a list of all formats supported by this processor.
        '''
        return sorted([plugin.name
                       for plugin
                       in rdflib.plugin.plugins(kind=rdflib.parser.Parser)])

#    def get_dataset_dict(self):
#         '''
#         Generator that returns CKAN datasets parsed from the RDF graph
#
#         Each dataset is passed to all the loaded profiles before being
#         yielded, so it can be further modified by each one of them.
#
#         Returns a dataset dict that can be passed to eg `package_create`
#         or `package_update`
#         '''
#         for dataset_ref in self._datasets():
#             dataset_dict = {}
#             for profile_class in self._profiles:
#                 profile = profile_class(self.g, self.compatibility_mode)
#                 profile.parse_dataset(dataset_dict, dataset_ref)
#
#             yield dataset_dict

    def url_to_rdflib_format(self, _format):
        '''
        Translates the RDF formats used on the endpoints to rdflib ones
        '''
        if _format == 'ttl':
            _format = 'turtle'
        elif _format in ('rdf', 'xml'):
            _format = 'pretty-xml'
        elif _format == 'jsonld':
            _format = 'json-ld'

        return _format




class LUH_DCAT_DatasetParser(RDFParser):
    '''
    An RDF to CKAN parser based on rdflib

    Supports different profiles which are the ones that will generate
    CKAN dicts from the RDF graph.
    '''

    def __init__(self):
        super().__init__()
        self.title_prefix = "LUH_ "
        self.ckan_api_package_list_url = "https://data.uni-hannover.de/api/3/action/package_list"
        self.ckan_api_organization_show = "https://data.uni-hannover.de/api/3/action/organization_show"
        self.rdf_base_url = "https://data.uni-hannover.de/dataset/"

    def _get_datasets_list_json(self):
        '''
            Uses the LUH API to retrieve a list of datasets in a dictionary

        '''

        try:
            response = requests.get(self.ckan_api_package_list_url)
        except requests.exceptions.RequestException as e:  # This is the correct syntax
            print("Error Connecting:", e)

        response_dict = json.loads(response.content)
        if not response_dict['result']:
            return []
        return response_dict['result']

    def _get_rdfurl_from_dataset_title(self, title):
        '''
             Given the dataset title in LUH datamanager generates the URL
                    for accessing the DCAT representation of the Dataset
        '''
        return self.rdf_base_url + title + ".rdf"

    def _get_rdfdata_from_rdfurl(self, rdfurl):
        '''
             Given the URL returns the rdf data
        '''
        try:
            # get file from url
            file_request = requests.get(rdfurl, allow_redirects=False)
        except requests.exceptions.RequestException as e:  # This is the correct syntax
            print("Error finding resource file on the web:", e)
            return "ERROR"
        return file_request.content

    def get_organization_data_from_api(self, title):
        request_url = self.ckan_api_organization_show + "?id=" + title.replace(" ","-").lower()
        opts = "&include_datasets=false&include_dataset_count=false&include_users=false&include_groups=false&include_followers=false&include_extras=false"
        request_url += opts
        try:
            response = requests.get(request_url)
        except requests.exceptions.RequestException as e:  # This is the correct syntax
            print("Error Connecting:", e)

        response_dict = json.loads(response.content)
        if not response_dict['result']:
            return []
        return response_dict['result']

    def create_new_organization(self, org_dict):
        context = {'model': model,
                   'session': model.Session,
                   'user': d.user,
                   'auth_user_obj': d.userobj}
        toolkit.get_action('organization_create')(context, org_dict)

    def parse_dataset_to_ckan_dict(self):
        '''
        Generator that returns CKAN datasets (dataset_dict) parsed from the RDF graph

        Returns a dataset dict that can be passed to eg `package_create`
        or `package_update`
        '''

        dataset_dict = {}
        dataset_dict['extras'] = []
        dataset_dict['resources'] = []
        for dataset in self.g.subjects(RDF.type, DCAT.Dataset):
            dataset_ref = dataset

        # Basic fields
        for key, predicate in (
                ('title', DCT.title),
                ('notes', DCT.description),
                ('url', DCAT.landingPage),
                ('version', OWL.versionInfo),
                ):
            value = self._object_value(dataset_ref, predicate)
            if value:
                dataset_dict[key] = value

        if not dataset_dict.get('version'):
            # adms:version was supported on the first version of the DCAT-AP
            value = self._object_value(dataset_ref, ADMS.version)
            if value:
                dataset_dict['version'] = value

        # Tags
        # replace munge_tag to noop if there's no need to clean tags
        do_clean = False
        tags_val = [munge_tag(tag) if do_clean else tag for tag in self._keywords(dataset_ref)]
        tags = [{'name': tag} for tag in tags_val]
        dataset_dict['tags'] = tags

        # Extras

        #  Simple values
        for key, predicate in (
                ('issued', DCT.issued),
                ('modified', DCT.modified),
                ('identifier', DCT.identifier),
                ('version_notes', ADMS.versionNotes),
                ('frequency', DCT.accrualPeriodicity),
                ('provenance', DCT.provenance),
                ('dcat_type', DCT.type),
                ):
            value = self._object_value(dataset_ref, predicate)
            if value:
                dataset_dict['extras'].append({'key': key, 'value': value})

        #  Lists
        for key, predicate, in (
                ('language', DCT.language),
                ('theme', DCAT.theme),
                ('alternate_identifier', ADMS.identifier),
                ('conforms_to', DCT.conformsTo),
                ('documentation', FOAF.page),
                ('related_resource', DCT.relation),
                ('has_version', DCT.hasVersion),
                ('is_version_of', DCT.isVersionOf),
                ('source', DCT.source),
                ('sample', ADMS.sample),
                ):
            values = self._object_value_list(dataset_ref, predicate)
            if values:
                dataset_dict['extras'].append({'key': key,
                                               'value': json.dumps(values)})

        # Contact details
        contact = self._contact_details(dataset_ref, DCAT.contactPoint)
        if not contact:
            # adms:contactPoint was supported on the first version of DCAT-AP
            contact = self._contact_details(dataset_ref, ADMS.contactPoint)

        if contact:
            for key in ('uri', 'name', 'email'):
                if contact.get(key):
                    dataset_dict['extras'].append(
                        {'key': 'contact_{0}'.format(key),
                         'value': contact.get(key)})

        # Publisher
        publisher = self._publisher(dataset_ref, DCT.publisher)
        for key in ('uri', 'name', 'email', 'url', 'type'):
            if publisher.get(key):
                dataset_dict['extras'].append(
                    {'key': 'publisher_{0}'.format(key),
                     'value': publisher.get(key)})

        # Temporal
        start, end = self._time_interval(dataset_ref, DCT.temporal)
        if start:
            dataset_dict['extras'].append(
                {'key': 'temporal_start', 'value': start})
        if end:
            dataset_dict['extras'].append(
                {'key': 'temporal_end', 'value': end})

        # Spatial
        spatial = self._spatial(dataset_ref, DCT.spatial)
        for key in ('uri', 'text', 'geom'):
            if spatial.get(key):
                dataset_dict['extras'].append(
                    {'key': 'spatial_{0}'.format(key) if key != 'geom' else 'spatial',
                     'value': spatial.get(key)})

        # Dataset URI (explicitly show the missing ones)
        dataset_uri = (str(dataset_ref)
                       if isinstance(dataset_ref, rdflib.term.URIRef)
                       else '')
        dataset_dict['extras'].append({'key': 'uri', 'value': dataset_uri})

        # access_rights
        access_rights = self._access_rights(dataset_ref, DCT.accessRights)
        if access_rights:
            dataset_dict['extras'].append({'key': 'access_rights', 'value': access_rights})

        # License
        if 'license_id' not in dataset_dict:
            dataset_dict['license_id'] = self._license(dataset_ref)

        # Source Catalog
        # if toolkit.asbool(config.get(DCAT_EXPOSE_SUBCATALOGS, False)):
        #     catalog_src = self._get_source_catalog(dataset_ref)
        #     if catalog_src is not None:
        #         src_data = self._extract_catalog_dict(catalog_src)
        #         dataset_dict['extras'].extend(src_data)

        # Resources
        for distribution in self._distributions(dataset_ref):

            resource_dict = {}

            #  Simple values
            for key, predicate in (
                    ('name', DCT.title),
                    ('description', DCT.description),
                    ('access_url', DCAT.accessURL),
                    ('download_url', DCAT.downloadURL),
                    ('issued', DCT.issued),
                    ('modified', DCT.modified),
                    ('status', ADMS.status),
                    ('license', DCT.license),
                    ):
                value = self._object_value(distribution, predicate)
                if value:
                    resource_dict[key] = value

            resource_dict['url'] = (self._object_value(distribution,
                                                       DCAT.downloadURL) or
                                    self._object_value(distribution,
                                                       DCAT.accessURL))
            #  Lists
            for key, predicate in (
                    ('language', DCT.language),
                    ('documentation', FOAF.page),
                    ('conforms_to', DCT.conformsTo),
                    ):
                values = self._object_value_list(distribution, predicate)
                if values:
                    resource_dict[key] = json.dumps(values)

            # rights
            rights = self._access_rights(distribution, DCT.rights)
            if rights:
                resource_dict['rights'] = rights

            # Format and media type
            normalize_ckan_format = True
            imt, label = self._distribution_format(distribution,
                                                   normalize_ckan_format)

            if imt:
                resource_dict['mimetype'] = imt

            if label:
                resource_dict['format'] = label
            elif imt:
                resource_dict['format'] = imt

            # Size
            size = self._object_value_int(distribution, DCAT.byteSize)
            if size is not None:
                resource_dict['size'] = size

            # Checksum
            for checksum in self.g.objects(distribution, SPDX.checksum):
                algorithm = self._object_value(checksum, SPDX.algorithm)
                checksum_value = self._object_value(checksum, SPDX.checksumValue)
                if algorithm:
                    resource_dict['hash_algorithm'] = algorithm
                if checksum_value:
                    resource_dict['hash'] = checksum_value

            # Distribution URI (explicitly show the missing ones)
            resource_dict['uri'] = (str(distribution)
                                    if isinstance(distribution,
                                                  rdflib.term.URIRef)
                                    else '')

            dataset_dict['resources'].append(resource_dict)

        if self.compatibility_mode:
            # Tweak the resulting dict to make it compatible with previous
            # versions of the ckanext-dcat parsers
            for extra in dataset_dict['extras']:
                if extra['key'] in ('issued', 'modified', 'publisher_name',
                                    'publisher_email',):

                    extra['key'] = 'dcat_' + extra['key']

                if extra['key'] == 'language':
                    extra['value'] = ','.join(
                        sorted(json.loads(extra['value'])))
        dataset_dict = self._adjust_dataset_dict(dataset_dict)
        return dataset_dict

    def _adjust_dataset_dict(self, dataset_dict):
        '''
            Adjust the metadata to the LDM specifications
        '''
        dataset_dict['title'] = self.title_prefix + dataset_dict['title']
        # Save the dataset as virtual dataset (vdataset)
        dataset_dict['type'] = "vdataset"
        return dataset_dict



    # HELPERS FOR dataset_dict contruction
    def _keywords(self, dataset_ref):
        '''
        Returns all DCAT keywords on a particular dataset
        '''
        keywords = self._object_value_list(dataset_ref, DCAT.keyword) or []
        # Split keywords with commas
        keywords_with_commas = [k for k in keywords if ',' in k]
        for keyword in keywords_with_commas:
            keywords.remove(keyword)
            keywords.extend([k.strip() for k in keyword.split(',')])
        return keywords

    def _object_value(self, subject, predicate):
        '''
        Given a subject and a predicate, returns the value of the object

        Both subject and predicate must be rdflib URIRef or BNode objects

        If found, the string representation is returned, else an empty string
        '''
        default_lang = config.get('ckan.locale_default', 'en')
        fallback = ''
        for o in self.g.objects(subject, predicate):
            if isinstance(o, Literal):
                if o.language and o.language == default_lang:
                    return str(o)
                # Use first object as fallback if no object with the default language is available
                elif fallback == '':
                    fallback = str(o)
            else:
                return str(o)
        return fallback

    def _object_value_list(self, subject, predicate):
        '''
        Given a subject and a predicate, returns a list with all the values of
        the objects

        Both subject and predicate must be rdflib URIRef or BNode  objects

        If no values found, returns an empty string
        '''
        return [str(o) for o in self.g.objects(subject, predicate)]

    def _license(self, dataset_ref):
        '''
        Returns a license identifier if one of the distributions license is
        found in CKAN license registry. If no distribution's license matches,
        an empty string is returned.

        The first distribution with a license found in the registry is used so
        that if distributions have different licenses we'll only get the first
        one.
        '''
        if self._licenceregister_cache is not None:
            license_uri2id, license_title2id = self._licenceregister_cache
        else:
            license_uri2id = {}
            license_title2id = {}
            for license_id, license in list(LicenseRegister().items()):
                license_uri2id[license.url] = license_id
                license_title2id[license.title] = license_id
            self._licenceregister_cache = license_uri2id, license_title2id

        for distribution in self._distributions(dataset_ref):
            # If distribution has a license, attach it to the dataset
            license = self._object(distribution, DCT.license)
            if license:
                # Try to find a matching license comparing URIs, then titles
                license_id = license_uri2id.get(license.toPython())
                if not license_id:
                    license_id = license_title2id.get(
                        self._object_value(license, DCT.title))
                if license_id:
                    return license_id
        return ''

    def _distributions(self, dataset):
        '''
        Generator that returns all DCAT distributions on a particular dataset

        Yields rdflib.term.URIRef objects that can be used on graph lookups
        and queries
        '''
        for distribution in self.g.objects(dataset, DCAT.distribution):
            yield distribution

    def _object_value_int(self, subject, predicate):
        '''
        Given a subject and a predicate, returns the value of the object as an
        integer

        Both subject and predicate must be rdflib URIRef or BNode objects

        If the value can not be parsed as intger, returns None
        '''
        object_value = self._object_value(subject, predicate)
        if object_value:
            try:
                return int(float(object_value))
            except ValueError:
                pass
        return None

    def _distribution_format(self, distribution, normalize_ckan_format=True):
        '''
        Returns the Internet Media Type and format label for a distribution

        Given a reference (URIRef or BNode) to a dcat:Distribution, it will
        try to extract the media type (previously knowm as MIME type), eg
        `text/csv`, and the format label, eg `CSV`

        Values for the media type will be checked in the following order:

        1. literal value of dcat:mediaType
        2. literal value of dct:format if it contains a '/' character
        3. value of dct:format if it is an instance of dct:IMT, eg:

            <dct:format>
                <dct:IMT rdf:value="text/html" rdfs:label="HTML"/>
            </dct:format>
        4. value of dct:format if it is an URIRef and appears to be an IANA type

        Values for the label will be checked in the following order:

        1. literal value of dct:format if it not contains a '/' character
        2. label of dct:format if it is an instance of dct:IMT (see above)
        3. value of dct:format if it is an URIRef and doesn't look like an IANA type

        If `normalize_ckan_format` is True and using CKAN>=2.3, the label will
        be tried to match against the standard list of formats that is included
        with CKAN core
        (https://github.com/ckan/ckan/blob/master/ckan/config/resource_formats.json)
        This allows for instance to populate the CKAN resource format field
        with a format that view plugins, etc will understand (`csv`, `xml`,
        etc.)

        Return a tuple with the media type and the label, both set to None if
        they couldn't be found.
        '''

        imt = None
        label = None

        imt = self._object_value(distribution, DCAT.mediaType)

        _format = self._object(distribution, DCT['format'])
        if isinstance(_format, Literal):
            if not imt and '/' in _format:
                imt = str(_format)
            else:
                label = str(_format)
        elif isinstance(_format, (BNode, URIRef)):
            if self._object(_format, RDF.type) == DCT.IMT:
                if not imt:
                    imt = str(self.g.value(_format, default=None))
                label = str(self.g.label(_format, default=None))
            elif isinstance(_format, URIRef):
                # If the URIRef does not reference a BNode, it could reference an IANA type.
                # Otherwise, use it as label.
                format_uri = str(_format)
                if 'iana.org/assignments/media-types' in format_uri and not imt:
                    imt = format_uri
                else:
                    label = format_uri

        if ((imt or label) and normalize_ckan_format and
                toolkit.check_ckan_version(min_version='2.3')):
            import ckan.config
            from ckan.lib import helpers

            format_registry = helpers.resource_formats()

            if imt in format_registry:
                label = format_registry[imt][1]
            elif label in format_registry:
                label = format_registry[label][1]

        return imt, label

    def _contact_details(self, subject, predicate):
        '''
        Returns a dict with details about a vcard expression

        Both subject and predicate must be rdflib URIRef or BNode objects

        Returns keys for uri, name and email with the values set to
        an empty string if they could not be found
        '''

        contact = {}

        for agent in self.g.objects(subject, predicate):

            contact['uri'] = (str(agent) if isinstance(agent,
                              rdflib.term.URIRef) else '')

            contact['name'] = self._get_vcard_property_value(agent, VCARD.hasFN, VCARD.fn)

            contact['email'] = self._without_mailto(self._get_vcard_property_value(agent, VCARD.hasEmail))

        return contact

    def _publisher(self, subject, predicate):
        '''
        Returns a dict with details about a dct:publisher entity, a foaf:Agent

        Both subject and predicate must be rdflib URIRef or BNode objects

        Examples:

        <dct:publisher>
            <foaf:Organization rdf:about="http://orgs.vocab.org/some-org">
                <foaf:name>Publishing Organization for dataset 1</foaf:name>
                <foaf:mbox>contact@some.org</foaf:mbox>
                <foaf:homepage>http://some.org</foaf:homepage>
                <dct:type rdf:resource="http://purl.org/adms/publishertype/NonProfitOrganisation"/>
            </foaf:Organization>
        </dct:publisher>

        {
            'uri': 'http://orgs.vocab.org/some-org',
            'name': 'Publishing Organization for dataset 1',
            'email': 'contact@some.org',
            'url': 'http://some.org',
            'type': 'http://purl.org/adms/publishertype/NonProfitOrganisation',
        }

        <dct:publisher rdf:resource="http://publications.europa.eu/resource/authority/corporate-body/EURCOU" />

        {
            'uri': 'http://publications.europa.eu/resource/authority/corporate-body/EURCOU'
        }

        Returns keys for uri, name, email, url and type with the values set to
        an empty string if they could not be found
        '''

        publisher = {}

        for agent in self.g.objects(subject, predicate):
            publisher['uri'] = (str(agent) if isinstance(agent,
                                                         rdflib.term.URIRef) else '')

            publisher['name'] = self._object_value(agent, FOAF.name)

            publisher['email'] = self._object_value(agent, FOAF.mbox)

            publisher['url'] = self._object_value(agent, FOAF.homepage)

            publisher['type'] = self._object_value(agent, DCT.type)

        return publisher

    def _time_interval(self, subject, predicate):
        '''
        Returns the start and end date for a time interval object

        Both subject and predicate must be rdflib URIRef or BNode objects

        It checks for time intervals defined with both schema.org startDate &
        endDate and W3C Time hasBeginning & hasEnd.

        Note that partial dates will be expanded to the first month / day
        value, eg '1904' -> '1904-01-01'.

        Returns a tuple with the start and end date values, both of which
        can be None if not found
        '''

        start_date = end_date = None

        for interval in self.g.objects(subject, predicate):
            # Fist try the schema.org way
            start_date = self._object_value(interval, SCHEMA.startDate)
            end_date = self._object_value(interval, SCHEMA.endDate)

            if start_date or end_date:
                return start_date, end_date

            # If no luck, try the w3 time way
            start_nodes = [t for t in self.g.objects(interval,
                                                     TIME.hasBeginning)]
            end_nodes = [t for t in self.g.objects(interval,
                                                   TIME.hasEnd)]
            if start_nodes:
                start_date = self._object_value(start_nodes[0],
                                                TIME.inXSDDateTime)
            if end_nodes:
                end_date = self._object_value(end_nodes[0],
                                              TIME.inXSDDateTime)

        return start_date, end_date

    def _spatial(self, subject, predicate):
        '''
        Returns a dict with details about the spatial location

        Both subject and predicate must be rdflib URIRef or BNode objects

        Returns keys for uri, text or geom with the values set to
        None if they could not be found.

        Geometries are always returned in GeoJSON. If only WKT is provided,
        it will be transformed to GeoJSON.

        Check the notes on the README for the supported formats:

        https://github.com/ckan/ckanext-dcat/#rdf-dcat-to-ckan-dataset-mapping
        '''

        uri = None
        text = None
        geom = None

        for spatial in self.g.objects(subject, predicate):

            if isinstance(spatial, URIRef):
                uri = str(spatial)

            if isinstance(spatial, Literal):
                text = str(spatial)

            if (spatial, RDF.type, DCT.Location) in self.g:
                for geometry in self.g.objects(spatial, LOCN.geometry):
                    if (geometry.datatype == URIRef(GEOJSON_IMT) or
                            not geometry.datatype):
                        try:
                            json.loads(str(geometry))
                            geom = str(geometry)
                        except (ValueError, TypeError):
                            pass
                    if not geom and geometry.datatype == GSP.wktLiteral:
                        try:
                            geom = json.dumps(wkt.loads(str(geometry)))
                        except (ValueError, TypeError):
                            pass
                for label in self.g.objects(spatial, SKOS.prefLabel):
                    text = str(label)
                for label in self.g.objects(spatial, RDFS.label):
                    text = str(label)

        return {
            'uri': uri,
            'text': text,
            'geom': geom,
        }

    def _access_rights(self, subject, predicate):
        '''
        Returns the rights statement or an empty string if no one is found.
        '''

        result = ''
        obj = self._object(subject, predicate)
        if obj:
            if isinstance(obj, BNode) and self._object(obj, RDF.type) == DCT.RightsStatement:
                result = self._object_value(obj, RDFS.label)
            elif isinstance(obj, Literal):
                result = six.text_type(obj)
        return result

    def _object(self, subject, predicate):
        '''
        Helper for returning the first object for this subject and predicate

        Both subject and predicate must be rdflib URIRef or BNode objects

        Returns an rdflib reference (URIRef or BNode) or None if not found
        '''
        for _object in self.g.objects(subject, predicate):
            return _object
        return None

    def _get_vcard_property_value(self, subject, predicate, predicate_string_property=None):
        '''
        Given a subject, a predicate and a predicate for the simple string property (optional),
        returns the value of the object. Trying to read the value in the following order
            * predicate_string_property
            * predicate

        All subject, predicate and predicate_string_property must be rdflib URIRef or BNode  objects

        If no value is found, returns an empty string
        '''

        result = ''
        if predicate_string_property:
            result = self._object_value(subject, predicate_string_property)

        if not result:
            obj = self._object(subject, predicate)
            if isinstance(obj, BNode):
                result = self._object_value(obj, VCARD.hasValue)
            else:
                result = self._object_value(subject, predicate)

        return result

    def _without_mailto(self, mail_addr):
        '''
        Ensures that the mail address string has no mailto: prefix.
        '''
        if mail_addr:
            return str(mail_addr).replace(PREFIX_MAILTO, u'')
        else:
            return mail_addr
