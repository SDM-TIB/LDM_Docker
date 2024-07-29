from ckan.plugins import toolkit
import requests
import json
import logging
import logging.config
from datetime import date
import ckan.model as model
import ckan.logic as logic
from ckan.common import config
from ckan.model import Package
from ckan.lib.helpers import lang as ckan_lang
from ckan.lib.helpers import render_datetime
from ckan.lib.helpers import url_for

# https://datacite.readthedocs.io/en/latest/
from datacite import DataCiteMDSClient, schema42

from datetime import datetime
import dateutil.parser as parser
from logging import getLogger

# DublinCore XML
# https://dcxml.readthedocs.io/en/latest/
# Voc doc: https://www.dublincore.org/specifications/dublin-core/dces/
from dcxml import simpledc

# CSL
#Doc: https://docs.citationstyles.org/en/1.0.1/specification.html
# https://github.com/citation-style-language/schema#csl-json-schema
# https://citationstyles.org/developers/
# https://github.com/brechtm/citeproc-py
# pip install citeproc-py // for testing

# BibTeX
# BibTeX-doc: https://www.bibtex.com/g/bibtex-format/
# http://www.bibtex.org/
# parser library: https://bibtexparser.readthedocs.io/en/master/index.html

from bibtexparser.bwriter import BibTexWriter
from bibtexparser.bibdatabase import BibDatabase

log = getLogger(__name__)
NotFound = logic.NotFound

class TIBVoc_parser:

    def __init__(self, ds_name):
        self.ds_dict = get_local_dataset(ds_name)
        self.Datacite_parser = Datacite_parser(self.ds_dict)
        self.CSL_parser = CSL_parser(self.ds_dict)
        self.Dublincore_parser = DublinCore_parser(self.ds_dict)
        self.Bibtex_parser = BibTeX_parser(self.ds_dict)

    def get_datacite_dataset(self):
        return self.Datacite_parser.parse_to_datacite()

    def get_csl_dataset(self):
        return self.CSL_parser.parse_to_csl()

    def get_dublincore_dataset(self):
        return self.Dublincore_parser.parse_to_dublincore()

    def get_bibtex_dataset(self):
        return self.Bibtex_parser.parse_to_bibtex()



class Datacite_parser:
    ''' Class for parsing CKAN dataset's dictionary to DataCite vocabulary ver. 4.2'''
    def __init__(self, ds_dict):
        self.data = {}
        self.ds_dict = ds_dict

        self.resourceType_mapping = {
                'dataset': 'Dataset',
                'vdataset': 'Dataset',
                'service': 'Service'}

    def parse_to_datacite(self):

        if not self.ds_dict:
            toolkit.abort(404)

        metadata_dict = self.create_metadata_dict()
        #print("METADATA:", metadata_dict)

        # Validate dictionary
        schema42.validate(metadata_dict)

        return schema42.tostring(metadata_dict)


    def create_metadata_dict(self):

        result_metadata_dict = {}

        required_fields = {
            'creators': [],
            'titles': [],
            'publisher': None,
            'publicationYear': None,
            'types': None,
            'schemaVersion': 'http://datacite.org/schema/kernel-4',
            'identifier': ""
        }

        # now the optional fields
        optional_fields = {
            'subjects': [],
            'contributors': [],
            'dates': [],
            'language': '',
            'alternateIdentifiers': [],
            'relatedIdentifiers': [],
            'sizes': '',
            'formats': [],
            'version': '',
            'rightsList': [],
            'descriptions': [],
            'geolocations': [],
            'fundingReferences': []
        }

        # Adding required fields
        required_fields['creators'] = self._add_required_creator()
        required_fields['titles'] = self._add_required_titles()
        required_fields['publisher'] = self.ds_dict.get('doi_publisher', 'Not defined')

        publicationYear = self.ds_dict.get('doi_date_published', None)
        if not publicationYear:
            publicationYear = self.ds_dict.get('metadata_created')

        #print("YEAR:", publicationYear)
        required_fields['publicationYear'] = render_datetime(publicationYear, date_format='%Y')
        required_fields['types'] = self._add_required_types()
        required_fields['identifier'] = self._add_required_identifier()

        # Adding optional fields
        optional_fields['subjects'] = self._add_optional_subjects()
        optional_fields['contributors'] = self._add_optional_contributors()
        optional_fields['dates'] = self._add_optional_dates()
        optional_fields['language'] = self._add_optional_language()
        optional_fields['alternateIdentifiers'] = self._add_optional_alternateIdentifiers()
        optional_fields['sizes'] = self._add_optional_sizes()
        optional_fields['formats'] = self._add_optional_formats()
        optional_fields['version'] = self._add_optional_version()
        optional_fields['rightsList'] = self._add_optional_rights()
        optional_fields['descriptions'] = self._add_optional_descriptions()

        result_metadata_dict.update(required_fields)
        result_metadata_dict.update(optional_fields)

        return result_metadata_dict

    # REQUIRED FIELDS
    # ***************

    # CREATORS
    # data = {'creators': [{
    #     'name': 'Smith, John',
    #     'familyName': 'Smith',
    #     'givenName': 'John',
    #     "affiliation": [{
    #       "name": "DataCite",
    #       "affiliationIdentifier": "https://ror.org/04wxnsj81",
    #       "affiliationIdentifierScheme": "ROR"
    #     }, {
    #       "name": "DataCite2",
    #       "affiliationIdentifier": "https://ror.org/04wxnsj81",
    #       "affiliationIdentifierScheme": "ROR"
    #     }
    #     ],
    #     'nameIdentifiers': [
    #         {
    #             'nameIdentifier': '1234',
    #             'schemeUri': 'http://orcid.org',
    #             'nameIdentifierScheme': 'orcid',
    #         },
    #     ]
    # }]}
    def _add_required_creator(self):
        creators = []
        # Main creator
        creator = {'name': self.ds_dict.get('author', "Not defined") }
        if 'orcid' in self.ds_dict and self.ds_dict['orcid']:
            creator['nameIdentifiers'] = self._create_orcid_object(self.ds_dict['orcid'])
        creators.append(creator)
        # Other creators
        if 'extra_authors' in self.ds_dict:
            for author in self.ds_dict['extra_authors']:
                creator = {'name': author['extra_author']}
                if 'orcid' in author:
                    creator['nameIdentifiers'] = self._create_orcid_object(author['orcid'])
                creators.append(creator)
        return creators

    def _create_orcid_object(self, orcid):
        return [{'nameIdentifier': orcid,
                 'schemeUri': 'http://orcid.org',
                 'nameIdentifierScheme': 'orcid'}]

    # TITLES
    def _add_required_titles(self):
        return [{'title': self.ds_dict.get('title')}]

    # Types
    def _add_required_types(self):
        resource_type = self.resourceType_mapping[self.ds_dict.get('type')]
        return {
            'resourceType': resource_type,
            'resourceTypeGeneral': resource_type
        }

    # Identifier
    def _add_required_identifier(self):
        id = self.ds_dict.get('doi', None)
        type = 'DOI'
        if not id:
            id = self.ds_dict.get('url_resource')
            type = 'URL'
        return {
                'identifierType': type,
                'identifier': id
            }

    # OPTIONAL FIELDS
    # ****************
    def _add_optional_subjects(self):
        # SUBJECTS
        # use the tag list
        try:
            tags = self.ds_dict.get('tag_string', '').split(',')
            tags += [tag['name'] if isinstance(tag, dict) else tag for tag in self.ds_dict.get('tags', [])]
            return [{'subject': tag} for tag in sorted({t for t in tags if t != ''})]
        except Exception as e:
            log.error("_add_optional_subjects(): " + e)

    def _add_optional_contributors(self):
        # CONTRIBUTORS
        # use the author and maintainer; no splitting or parsing for either
        # no try/except for this because it's just a simple .get() and if that doesn't work then we
        # want to know
        author = self.ds_dict.get('author')
        maintainer = self.ds_dict.get('maintainer')
        result = []

        if author is not None:
            result.append(
                {
                    'contributor_type': 'Researcher',
                    'name': author
                })
        if maintainer != "" and maintainer is not None:
            result.append({
                'contributor_type': 'DataManager',
                'name': maintainer
            })
        return result

    def _add_optional_dates(self):
        # DATES
        # created, updated, and doi publish date
        date_errors = {}
        result = []

        try:
            result.append({
                'dateType': 'Created',
                'date': render_datetime(self.ds_dict.get('metadata_created'), '%d/%m/%Y')
            })
        except Exception as e:
            log.error("_add_optional_dates() Ex1: " + e)
        try:
            result.append({
                'dateType': 'Updated',
                'date': render_datetime(self.ds_dict.get('metadata_modified'), '%d/%m/%Y')
            })
        except Exception as e:
            log.error("_add_optional_dates() Ex2: " +e)
        if 'doi_date_published' in self.ds_dict:
            try:
                result.append({
                    'dateType': 'Issued',
                    'date': render_datetime(self.ds_dict.get('doi_date_published'), '%d/%m/%Y')
                })
            except Exception as e:
                log.error("_add_optional_dates() Ex3: " +e)

        return  result

    def _add_optional_language(self):
        # LANGUAGE
        # use language set in CKAN
        result = {}
        try:
            result = ckan_lang()
        except Exception as e:
            log.error("_add_optional_language(): " + e.__str__())

    def _add_optional_alternateIdentifiers(self):
            # ALTERNATE IDENTIFIERS
            # add permalink back to this site
        result = {}
        try:
            permalink = f'{get_site_url()}/dataset/{self.ds_dict["id"]}'
            result = [{
                'alternateIdentifierType': 'URL',
                'alternateIdentifier': permalink
            }]
        except Exception as e:
            log.error("_add_optional_alternateIdentifiers(): " + e)

        # RELATED IDENTIFIERS
        # nothing relevant in default schema

    def _add_optional_sizes(self):

       # SIZES
       # sum up given sizes from resources in the package and convert from bytes to kilobytes
       resources = self.ds_dict['resources']
       total_size = 0
       for r in resources:
           total_size += 0 if not r['size'] else int(r['size'])
       total_size = round((total_size / 1024)).__str__() + " kb"

       return {total_size}

    def _add_optional_formats(self):
        # FORMATS
        # list unique formats from package resources
        resources = self.ds_dict['resources']
        total_formats = []
        for r in resources:
            total_formats.append(r['format'])
        #total_formats = ['PDF','PDF','ZIP','XML']
        #total_formats = list(set(total_formats))
        return dict.fromkeys(total_formats)

    def _add_optional_version(self):
        # VERSION
        # doesn't matter if there's no version, it'll get filtered out later
        return self.ds_dict.get('version')

    def _add_optional_rights(self):
        # RIGHTS
        # use the package license and get details from CKAN's license register
        result = {}
        license_id = self.ds_dict.get('license_id', 'notspecified')
        try:
            if license_id != 'notspecified' and license_id is not None:
                license_register = Package.get_license_register()
                license = license_register.get(license_id)
                if license is not None:
                    result = [
                        {
                            'url': license.url,
                            'identifier': license.id
                        }
                    ]
        except Exception as e:
            log.error("_add_optional_rights(): " + e)

    def _add_optional_descriptions(self):
        # DESCRIPTIONS
        # use package notes
        return [
        {
            'descriptionType': 'Other',
            'description': self.ds_dict.get('notes', '')
        }
    ]

    # GEOLOCATIONS
    # nothing relevant in default schema

    # FUNDING
    # nothing relevant in default schema

# vod-doc: https://docs.citationstyles.org/en/1.0.1/specification.html
class CSL_parser:

    def __init__(self, ds_dict):
        self.ds_dict = ds_dict

        self.resourceType_mapping = {
            'dataset': 'dataset',
            'vdataset': 'dataset',
            'service': 'dataset'}

    def parse_to_csl(self):
        if not self.ds_dict:
            toolkit.abort(404)

        data_fields = {
            'publisher': "",
            'DOI': "",
            'title': "",
            'issued': [],
            'abstract': "",
            'author': [],
            'note': "",
            'version': "",
            'type': "",
            'id': "",
            'page': "",
            'publisher-place': "",
            'URL': "",
        }

        # Adding fields
        data_fields['publisher'] = self.ds_dict.get('doi_publisher')
        data_fields['DOI'] = self.ds_dict.get('doi')
        data_fields['title'] = self.ds_dict.get('title')
        data_fields['issued'] = self._add_issued_field()
        data_fields['abstract'] = self.ds_dict.get('notes').replace('"', "'")
        data_fields['author'] = self._get_authors()
        data_fields['version'] = self.ds_dict.get('version')
        data_fields['type'] = self.resourceType_mapping[self.ds_dict.get('type')]
        data_fields['id'] = self.ds_dict.get('name')
        data_fields['URL'] = self.ds_dict.get('url_resource')

        return json.dumps(self._clean_empty_fields(data_fields))

    def _get_authors(self):
        authors = []
        # Main author
        author = {"family": self.ds_dict.get('author')}
        if 'orcid' in self.ds_dict and self.ds_dict['orcid']:
            author['uri'] = 'http://orcid.org/'+self.ds_dict['orcid']
        authors.append(author)
        # Other authors
        if 'extra_authors' in self.ds_dict:
            for item in self.ds_dict['extra_authors']:
                author = {"family": item['extra_author']}
                if 'orcid' in item:
                    author['uri'] = 'http://orcid.org/' + item['orcid']
                authors.append(author)
        return authors

    def _add_issued_field(self):
        publicationDate = self.ds_dict.get('doi_date_published', None)
        if not publicationDate:
            publicationDate = self.ds_dict.get('metadata_created')

        publicationDate = render_datetime(publicationDate, date_format='%Y %m %d').split()

        return {
            "date-parts": [publicationDate]
        }

    def _clean_empty_fields(self, data_dict):
        return {k: v for k, v in data_dict.items() if v}


class DublinCore_parser:

    def __init__(self, ds_dict):
        self.ds_dict = ds_dict

        self.resourceType_mapping = {
            'dataset': 'dataset',
            'vdataset': 'dataset',
            'service': 'dataset'}

    def parse_to_dublincore(self):
        if not self.ds_dict:
            toolkit.abort(404)

        data_fields = dict(
            contributors=[],
            coverage=[],
            creators=[],
            dates=[],
            descriptions=[],
            formats=[],
            identifiers=[],
            languages=['en'],
            publishers=[],
            relations=[],
            rights=[],
            sources=[],
            subjects=[],
            titles=[],
            types=['Software'])

        # Adding fields
        data_fields['contributors'] = [self.ds_dict['organization']['title']]
        data_fields['creators'] = self._get_authors()
        data_fields['dates'] = [self._add_dates_field()]
        data_fields['descriptions'] = [self.ds_dict.get('notes')]
        data_fields['formats'] = self._add_formats_field()
        data_fields['identifiers'] = self._add_identifiers_field()
        data_fields['publisher'] = self.ds_dict.get('doi_publisher')
        data_fields['rights'] = [self.ds_dict.get('license_title')]
        data_fields['sources'] = [self._add_sources_field()]
        data_fields['subjects'] = self._add_subjects_field()
        data_fields['titles'] = [self.ds_dict.get('title')]
        data_fields['types'] = [self.resourceType_mapping[self.ds_dict.get("type")]]

        return simpledc.tostring(data_fields)

    def _get_authors(self):
        authors = []
        # Main author
        author = self.ds_dict.get('author')
        authors.append(author)
        # Other authors
        if 'extra_authors' in self.ds_dict:
            for item in self.ds_dict['extra_authors']:
                author = item['extra_author']
                authors.append(author)
        return authors

    def _add_dates_field(self):
        publicationDate = self.ds_dict.get('doi_date_published', None)
        if not publicationDate:
            publicationDate = self.ds_dict.get('metadata_created')

        publicationDate = render_datetime(publicationDate, date_format='%Y-%m-%d')

        return publicationDate

    def _add_formats_field(self):
        # FORMATS
        # list unique formats from package resources
        resources = self.ds_dict['resources']
        total_formats = []
        for r in resources:
            total_formats.append(r['format'])
        #total_formats = ['PDF','PDF','ZIP','XML']
        #total_formats = list(set(total_formats))
        return list(dict.fromkeys(total_formats))

    def _add_identifiers_field(self):
        result = [self.ds_dict.get('url_resource')]
        doi = self.ds_dict.get('doi')
        if doi:
            result.append(doi)
        return result

    def _add_sources_field(self):
        return self.ds_dict.get("repository_name", "")


    def _add_subjects_field(self):
        # SUBJECTS
        # use the tag list
        result = []
        for tag in self.ds_dict.get('tags', []):
            result.append(tag['name'])

        return result

# BibTeX-doc: https://www.bibtex.com/g/bibtex-format/
    # Standard field types
    #
    #     address: address of the publisher or the institution
    #     annote: an annotation
    #     author: list of authors of the work
    #     booktitle: title of the book
    #     chapter: number of a chapter in a book
    #     edition: edition number of a book
    #     editor: list of editors of a book
    #     howpublished: a publication notice for unusual publications
    #     institution: name of the institution that published and / or sponsored the report
    #     journal: name of the journal or magazine the article was published in
    #     month: the month during the work was published
    #     note: notes about the reference
    #     number: number of the report or the issue number for a journal article
    #     organization: name of the institution that organized or sponsored the conference or that published the manual
    #     pages: page numbers or a page range
    #     publisher: name of the publisher
    #     school: name of the university or degree awarding institution
    #     series: name of the series or set of books
    #     title: title of the work
    #     type: type of the technical report or thesis
    #     volume: volume number
    #     year: year the work was published
    #
    #     Non - standard field  types
    #     These fields are frequently used, but are not supported by all BibTeX styles.
    #     doi: DOI number(like 10.1038 / d41586 - 018 - 07848 - 2)
    #     issn: ISSN number(like 1476 - 4687)
    #     isbn: ISBN number(like 9780201896831)
    #     url: URL of a web page
        '''@dataset{solvsten_steffan_christ_2021_5638551,
  author       = {Sølvsten, Steffan Christ and
                  Van de Pol, Jaco},
  title        = {Adiar 1.0.1 : Experiment Data},
  month        = nov,
  year         = 2021,
  publisher    = {Zenodo},
  doi          = {10.5281/zenodo.5638551},
  url          = {https://doi.org/10.5281/zenodo.5638551}
}
'''

class BibTeX_parser:

    def __init__(self, ds_dict):
        self.ds_dict = ds_dict

        self.resourceType_mapping = {
            'dataset': 'dataset',
            'vdataset': 'dataset',
            'service': 'misc'}

    def parse_to_bibtex(self):
        if not self.ds_dict:
            toolkit.abort(404)

        data_fields = {
            'journal': '',
            'comments': '',
            'pages': '',
            'month': '',
            'abstract': '',
            'title': '',
            'year': '',
            'volume': '',
            'ID': '',
            'author': '',
            'keyword': '',
            'publisher': '',
            'doi': '',
            'url': '',
            'institution': '',
            'ENTRYTYPE': ''}

        # Adding fields
        data_fields['author'] = self._get_authors()
        data_fields['title'] = self.ds_dict.get('title')
        publication_date = self._get_publication_date()
        data_fields['month'] = publication_date[1].lower()
        data_fields['year'] = publication_date[0]

        data_fields['publisher'] = self.ds_dict.get('doi_publisher', "")
        data_fields['doi'] = self.ds_dict.get('doi', "")
        data_fields['url'] = self.ds_dict.get('url_resource', "")
        data_fields['institution'] = self.ds_dict['organization']['title']
        data_fields['keyword'] = self._add_keywords_field()
        data_fields['ENTRYTYPE'] = self.resourceType_mapping[self.ds_dict.get('type')]
        data_fields['abstract'] = str(self.ds_dict.get('notes')).encode().decode('utf-8', 'ignore')
        data_fields['ID'] = self._add_ID_field(data_fields)

        data_fields = {k: v for k, v in data_fields.items() if v != ''}
        db = BibDatabase()
        db.entries = [data_fields]

        writer = BibTexWriter()
        writer.indent = '    '  # indent entries with 4 spaces instead of one

        return writer.write(db)

    def _get_authors(self):
        # Main author
        authors = self.ds_dict.get('author')
        # Other authors
        if 'extra_authors' in self.ds_dict:
            for item in self.ds_dict['extra_authors']:
                authors += " and "+item['extra_author']
        return authors

    def _add_ID_field(self, ds):
        return ds['author'].replace(' ', '_').replace('.', '').replace(',', '') + "_" + ds['year']

    def _get_publication_date(self):

        publicationDate = self.ds_dict.get('doi_date_published', "")
        if publicationDate == "":
            publicationDate = self.ds_dict.get('metadata_created')
        if len(publicationDate) == 4: # is only year
            p_date = [publicationDate, ""]
        else:
            p_date = render_datetime(publicationDate, date_format='%Y %b %d').split()
        return p_date

    def _add_keywords_field(self):
        # SUBJECTS
        # use the tag list
        result = []
        for tag in self.ds_dict.get('tags', []):
            result.append(tag['name'])

        return str(result).strip('[]')

# HELPERS

def get_local_dataset(name):
    # https://docs.ckan.org/en/2.9/api/#ckan.logic.action.get.package_show
    # Note: Returns data even with dataset deleted => ds['state'] = 'deleted'
    params = {'id': name}
    context = {'model': model,
               'session': model.Session}

    try:
        result = toolkit.get_action('package_show')(context, params)
    except NotFound as e:
        return {}

    # Create URL for resource
    result['url_resource'] = get_site_url() + "/" + result['type'] + "/" + result['name']

    return result

def get_site_url():
    '''
    Get the site URL. Try and use ckanext.doi.site_url but if that's not set use ckan.site_url.
    '''
    site_url = toolkit.config.get('ckan.site_url', '')
    return site_url.rstrip('/')

