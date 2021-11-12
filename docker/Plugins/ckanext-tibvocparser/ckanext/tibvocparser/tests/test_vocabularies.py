# pytest --ckan-ini=test.ini ckanext/tibvocparser/tests -s

from ckanext.tibvocparser.tibparser import Datacite_parser, CSL_parser, DublinCore_parser, BibTeX_parser
from ckanext.tibvocparser.tests.data_mocks import ckan_dataset_example, expected_datacite_xml,\
    expected_csl_json, expected_dublincore_xml, expected_bibtex_str, expected_csl_json_for_check_citation,\
    expected_csl_citation, expected_csl_bibliography


import xmltodict, json

# Datacite
# https://datacite.readthedocs.io/en/latest/
from datacite import DataCiteMDSClient, schema42

# CSL
#Doc: https://docs.citationstyles.org/en/1.0.1/specification.html
# Import the citeproc-py classes we'll use below.
from citeproc import CitationStylesStyle, CitationStylesBibliography
from citeproc import Citation, CitationItem
from citeproc import formatter
from citeproc.source.json import CiteProcJSON

# DublinCore
# https://dcxml.readthedocs.io/en/latest/
# Voc doc: https://www.dublincore.org/specifications/dublin-core/dces/
from dcxml import simpledc

# BibTeX
# BibTeX-doc: https://www.bibtex.com/g/bibtex-format/
# parser: https://bibtexparser.readthedocs.io/en/master/index.html
from bibtexparser.bwriter import BibTexWriter
from bibtexparser.bibdatabase import BibDatabase


def test_Datacite_Parser():
    #with patch('ckanext.tibvocparser.tibparser.get_local_dataset') as mock_get:
        # Configure the mock to return a response with an OK status code and data
        #mock_get.return_value.ok = True
        #mock_get.return_value = ckan_dataset_example
        ds_dict = ckan_dataset_example
        #print("DICT:", ds_dict)
        parser = Datacite_parser(ds_dict)
        #print("DATASET:\n", parser.ds_dict)
        res = parser.parse_to_datacite()
        #print("DATACITE RESULT:\n", res)
        assert xmltodict.parse(res) == xmltodict.parse(expected_datacite_xml)

def test_CSL_Parser():

        ds_dict = ckan_dataset_example
        #print("DICT:", ds_dict)
        parser = CSL_parser(ds_dict)
        #print("DATASET:\n", parser.ds_dict)
        res = parser.parse_to_csl()
        print("CSL RESULT:\n", res)
        assert res == json.dumps(expected_csl_json)

        json_data = json.loads(expected_csl_json_for_check_citation)
        # Process the JSON data to generate a citeproc-py BibliographySource.

        bib_source = CiteProcJSON(json_data)
        # for key, entry in bib_source.items():
        #     print(key)
        #     for name, value in entry.items():
        #         print('   {}: {}'.format(name, value))

        # load a CSL style (from the current directory)

        bib_style = CitationStylesStyle('harvard1', validate=False)

        # Create the citeproc-py bibliography, passing it the:
        # * CitationStylesStyle,
        # * BibliographySource (CiteProcJSON in this case), and
        # * a formatter (plain, html, or you can write a custom formatter)

        bibliography = CitationStylesBibliography(bib_style, bib_source, formatter.html)

        # Processing citations in a document needs to be done in two passes as for some
        # CSL styles, a citation can depend on the order of citations in the
        # bibliography and thus on citations following the current one.
        # For this reason, we first need to register all citations with the
        # CitationStylesBibliography.

        citation1 = Citation([CitationItem('luh-a-generic-gust-definition-and-detection-method-based-on-wavelet-analysis')])

        bibliography.register(citation1)

        # In the second pass, CitationStylesBibliography can generate citations.
        # CitationStylesBibliography.cite() requires a callback function to be passed
        # along to be called in case a CitationItem's key is not present in the
        # bibliography.

        def warn(citation_item):
            print("WARNING: Reference with key '{}' not found in the bibliography."
                  .format(citation_item.key))

        print('Citations')
        print('---------')

        assert bibliography.cite(citation1, warn) == expected_csl_citation
        print(bibliography.cite(citation1, warn))

        # And finally, the bibliography can be rendered.

        # print('')
        print('Bibliography')
        print('------------')

        for item in bibliography.bibliography():
            print(str(item))
        item = bibliography.bibliography()
        assert str(item[0]) == expected_csl_bibliography

def test_DublinCore_Parser():
    ds_dict = ckan_dataset_example
    # print("DICT:", ds_dict)
    parser = DublinCore_parser(ds_dict)
    # print("DATASET:\n", parser.ds_dict)
    res = parser.parse_to_dublincore()
    #print("DUBLINCORE RESULT:\n", res)
    assert res == expected_dublincore_xml


def test_BibTeX_Parser():
    ds_dict = ckan_dataset_example
    # print("DICT:", ds_dict)
    parser = BibTeX_parser(ds_dict)
    # print("DATASET:\n", parser.ds_dict)
    res = parser.parse_to_bibtex()
    print("BIBTEX RESULT:\n", res)
    assert res == expected_bibtex_str

def test_BibTeX_Parser2():


    db = BibDatabase()


    key = ['k1', 'k2']
    key = str(key).strip('[]')
    db.entries = [
        {'journal': 'Nice Journal',
         'comments': 'A comment',
         'pages': '12--23',
         'month': 'jan',
         'abstract': 'This is an abstract. This line should be long enough to test\nmultilines...',
         'title': 'An amazing title',
         'year': '2013',
         'volume': '12',
         'ID': 'Cesar2013',
         'author': 'Jean César',
         'keyword': key,
         'publisher': 'TOB',
         'doi': '302483094093409',
         'url': 'http://web.com',
         'institution': "ACME",
         'ENTRYTYPE': 'dataset'}]

    writer = BibTexWriter()
    writer.indent = '    '  # indent entries with 4 spaces instead of one
    #writer.comma_first = True  # place the comma at the beginning of the line

    #print('BibTeX generated:', writer.write(db))

def test_datacite():
    data = {
        'identifier': {
            'identifierType': 'DOI',
            'identifier': '10.1234/foo.bar',
        },
        'creators': [
            {'name': 'Smith, John'},
        ],
        'titles': [
            {'title': 'Minimal Test Case', }
        ],
        'publisher': 'Invenio Software',
        'publicationYear': '2015',
        'types': {
            'resourceType': 'Dataset',
            'resourceTypeGeneral': 'Dataset'
        },
        'schemaVersion': 'http://datacite.org/schema/kernel-4',
    }

    # Validate dictionary
    assert schema42.validate(data)

    doc = schema42.tostring(data)
    #print("DATA:\n", doc)

# def test_CSL():
#     json_input = """
#     [
#         {
#             "id": "ITEM-1",
#             "title": "Ignore me",
#             "type": "dataset",
#             "issued": {
#                 "date-parts": [[1987,  8,  3],
#                                [2003, 10, 23]]
#             },
#             "page" : "1-7",
#             "author": [
#                 {
#                     "family": "Doe",
#                     "given": "John"
#                 }
#             ],
#            "publisher": "Routledge",
#            "publisher-place": "New York",
#            "URL": "http://www.test01.com"
#         }
#      ]
#     """
#
#
#     # Parse the JSON input using json.loads()
#     # (parsing from a file object can be done with json.load)
#
#     json_data = json.loads(json_input)
#
#     # Process the JSON data to generate a citeproc-py BibliographySource.
#
#     bib_source = CiteProcJSON(json_data)
#     ##for key, entry in bib_source.items():
#     ##    print(key)
#     ##    for name, value in entry.items():
#     ##        print('   {}: {}'.format(name, value))
#
#     # load a CSL style (from the current directory)
#
#     bib_style = CitationStylesStyle('harvard1', validate=False)
#
#     # Create the citeproc-py bibliography, passing it the:
#     # * CitationStylesStyle,
#     # * BibliographySource (CiteProcJSON in this case), and
#     # * a formatter (plain, html, or you can write a custom formatter)
#
#     bibliography = CitationStylesBibliography(bib_style, bib_source, formatter.html)
#
#     # Processing citations in a document needs to be done in two passes as for some
#     # CSL styles, a citation can depend on the order of citations in the
#     # bibliography and thus on citations following the current one.
#     # For this reason, we first need to register all citations with the
#     # CitationStylesBibliography.
#
#     citation1 = Citation([CitationItem('ITEM-1')
#
#     bibliography.register(citation1)
#
#     # In the second pass, CitationStylesBibliography can generate citations.
#     # CitationStylesBibliography.cite() requires a callback function to be passed
#     # along to be called in case a CitationItem's key is not present in the
#     # bibliography.
#
#     def warn(citation_item):
#         print("WARNING: Reference with key '{}' not found in the bibliography."
#               .format(citation_item.key))
#
#     print('Citations')
#     print('---------')
#
#     print(bibliography.cite(citation1, warn))
#
#     # And finally, the bibliography can be rendered.
#
#     print('')
#     print('Bibliography')
#     print('------------')
#
#     for item in bibliography.bibliography():
#         print(str(item))

def test_DublinCore():
    data = dict(
    contributors = ['CERN'],
    coverage = ['Geneva'],
    creators = ['CERN'],
    dates = ['2002'],
    descriptions = ['Simple Dublin Core generation'],
    formats = ['application/xml'],
    identifiers = ['dublin-core'],
    languages = ['en'],
    publishers = ['CERN'],
    relations = ['Invenio Software'],
    rights = ['MIT'],
    sources = ['Python'],
    subject = ['XML'],
    titles = ['Dublin Core XML'],
    types = ['Software'])

    xml = simpledc.tostring(data)

    #print("DublinCore:|n")
    #print("and print the 15 elements (without the container element)\n")
    #for l in xml.splitlines()[2:-1]:
     #   print(l)

    #print("The container element is by default the <oai_dc:dc> element:\n")
    #print(xml.splitlines()[1])

    #print("In case you need an ElementTree instead of a string, it’s as simple as:\n")
    #tree = simpledc.dump_etree(data)
    #print(tree)