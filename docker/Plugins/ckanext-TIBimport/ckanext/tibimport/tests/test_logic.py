# pytest --ckan-ini=test.ini ckanext/tibimport/tests -s

#import unittest
from __future__ import absolute_import

import ckan.lib.helpers as helpers
import json
import os
#import sys
#sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

#from logic import *
from ckanext.tibimport.exceptions import RDFParserException
from ckanext.tibimport.logic import LUH_DCAT_DatasetParser

def test__get_datasets_list_json():
    obj = LUH_DCAT_DatasetParser()

    res_dict = obj._get_datasets_list_json()
  #  print(res_dict)
  #  print(len(res_dict))
    assert bool(res_dict)

def test__get_rdfurl_from_dataset_title():
    obj = LUH_DCAT_DatasetParser()
    title = "a-generic-gust-definition-and-detection-method-based-on-wavelet-analysis"
    res = obj._get_rdfurl_from_dataset_title(title)
    expected = "https://data.uni-hannover.de/dataset/a-generic-gust-definition-and-detection-method-based-on-wavelet-analysis.rdf"
  #  print(res)
    assert res == expected

def test__get_rdfdata_from_rdfurl():
    obj = LUH_DCAT_DatasetParser()
    url = "https://data.uni-hannover.de/dataset/a-generic-gust-definition-and-detection-method-based-on-wavelet-analysis.rdf"

    res = obj._get_rdfdata_from_rdfurl(url)
   # print(res)
    assert bool(res)

def test_get_dataset_dict_from_rdfdata():
    data = '<?xml version="1.0" encoding="utf-8"?>\n<rdf:RDF\n  xmlns:foaf="http://xmlns.com/foaf/0.1/"\n  xmlns:dct="http://purl.org/dc/terms/"\n  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"\n  xmlns:dcat="http://www.w3.org/ns/dcat#"\n  xmlns:vcard="http://www.w3.org/2006/vcard/ns#"\n>\n  <dcat:Dataset rdf:about="https://data.uni-hannover.de/dataset/c76adf5a-9aa8-4ebe-bbbe-0e61436cf033">\n    <dcat:keyword>Wavelet Analysis</dcat:keyword>\n    <dcat:keyword>Meteorology</dcat:keyword>\n    <dcat:keyword>LES</dcat:keyword>\n    <dct:modified rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">2020-06-08T12:37:20.096728</dct:modified>\n    <dcat:contactPoint>\n      <vcard:Organization rdf:nodeID="N18307a5cea3745c9b6177a4ad19224ac">\n        <vcard:hasEmail rdf:resource="mailto:knoop@muk.uni-hannover.de"/>\n        <vcard:fn>Helge Knoop</vcard:fn>\n      </vcard:Organization>\n    </dcat:contactPoint>\n    <dct:identifier>c76adf5a-9aa8-4ebe-bbbe-0e61436cf033</dct:identifier>\n    <dcat:keyword>LES model</dcat:keyword>\n    <dct:description>This dataset is associated with the paper Knoop et al. (2019) titled  "A generic gust definition and detection method based on wavelet-analysis" published in "Advances in Science and Research (ASR)" within the Special Issue: 18th EMS Annual Meeting: European Conference for Applied Meteorology and Climatology 2018. It contains the data and analysis software required to recreate all figures in the publication.</dct:description>\n    <dcat:keyword>Gusts</dcat:keyword>\n    <dct:title>A generic gust definition and detection method based on wavelet-analysis</dct:title>\n    <dcat:keyword>large eddy simulation</dcat:keyword>\n    <dcat:distribution>\n      <dcat:Distribution rdf:about="https://data.uni-hannover.de/dataset/c76adf5a-9aa8-4ebe-bbbe-0e61436cf033/resource/bd5d8d95-b3e2-4f25-a928-d75df8faf462">\n        <dct:description>Wind velocity data in netCDF format, a python script for data analysis and a requirements.txt file containing all python package dependencies.</dct:description>\n        <dcat:accessURL rdf:resource="https://data.uni-hannover.de/dataset/c76adf5a-9aa8-4ebe-bbbe-0e61436cf033/resource/bd5d8d95-b3e2-4f25-a928-d75df8faf462/download/wavelet_gust_analysis.zip"/>\n        <dct:format>ZIP</dct:format>\n        <dct:title>wavelet_gust_analysis.zip</dct:title>\n        <dcat:mediaType>application/zip</dcat:mediaType>\n        <dcat:byteSize rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal">96112.0</dcat:byteSize>\n      </dcat:Distribution>\n    </dcat:distribution>\n    <dcat:distribution>\n      <dcat:Distribution rdf:about="https://data.uni-hannover.de/dataset/c76adf5a-9aa8-4ebe-bbbe-0e61436cf033/resource/8fa5e23c-6e72-486e-87f9-e16c75a38c4b">\n        <dcat:byteSize rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal">86184.0</dcat:byteSize>\n        <dct:format>ZIP</dct:format>\n        <dcat:accessURL rdf:resource="https://data.uni-hannover.de/dataset/c76adf5a-9aa8-4ebe-bbbe-0e61436cf033/resource/8fa5e23c-6e72-486e-87f9-e16c75a38c4b/download/a-generic-gust-definition-and-detection-method-based-on-wavelet-analysis-duoest.zip"/>\n        <dcat:mediaType>application/zip</dcat:mediaType>\n        <dct:title>All resource data</dct:title>\n      </dcat:Distribution>\n    </dcat:distribution>\n    <dct:issued rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">2019-07-09T17:21:22.824534</dct:issued>\n    <dct:publisher>\n      <foaf:Organization rdf:about="https://data.uni-hannover.de/organization/2d2ca2a7-26f5-497b-b5a4-a559a28f3042">\n        <foaf:name>AG PALM</foaf:name>\n      </foaf:Organization>\n    </dct:publisher>\n  </dcat:Dataset>\n</rdf:RDF>\n'
    expected = "LUH_ A generic gust definition and detection method based on wavelet-analysis"
    dataset_dict = {}
    obj = LUH_DCAT_DatasetParser()
    obj.parse_to_rdf_class(data)
    dataset_dict = obj.parse_dataset_to_ckan_dict()

    print(dataset_dict["extras"][6]["value"])
    print(helpers._make_safe_id_component("Hola mundo como estas"))
    assert expected == dataset_dict['title']
    #
    # {"extras": [{"key": "issued", "value": "2019-07-09T17:21:22.824534"},
    #             {"key": "modified", "value": "2020-06-08T12:37:20.096728"},
    #             {"key": "identifier", "value": "c76adf5a-9aa8-4ebe-bbbe-0e61436cf033"},
    #             {"key": "contact_name", "value": "Helge Knoop"},
    #             {"key": "contact_email", "value": "knoop@muk.uni-hannover.de"}, {"key": "publisher_uri",
    #                                                                              "value": "https://data.uni-hannover.de/organization/2d2ca2a7-26f5-497b-b5a4-a559a28f3042"},
    #             {"key": "publisher_name", "value": "AG PALM"},
    #             {"key": "uri", "value": "https://data.uni-hannover.de/dataset/c76adf5a-9aa8-4ebe-bbbe-0e61436cf033"}],
    #  "resources": [{"name": "All resource data",
    #                 "access_url": "https://data.uni-hannover.de/dataset/c76adf5a-9aa8-4ebe-bbbe-0e61436cf033/resource/8fa5e23c-6e72-486e-87f9-e16c75a38c4b/download/a-generic-gust-definition-and-detection-method-based-on-wavelet-analysis-duoest.zip",
    #                 "url": "https://data.uni-hannover.de/dataset/c76adf5a-9aa8-4ebe-bbbe-0e61436cf033/resource/8fa5e23c-6e72-486e-87f9-e16c75a38c4b/download/a-generic-gust-definition-and-detection-method-based-on-wavelet-analysis-duoest.zip",
    #                 "mimetype": "application/zip", "format": "ZIP", "size": 86184,
    #                 "uri": "https://data.uni-hannover.de/dataset/c76adf5a-9aa8-4ebe-bbbe-0e61436cf033/resource/8fa5e23c-6e72-486e-87f9-e16c75a38c4b"},
    #                {"name": "wavelet_gust_analysis.zip",
    #                 "description": "Wind velocity data in netCDF format, a python script for data analysis and a requirements.txt file containing all python package dependencies.",
    #                 "access_url": "https://data.uni-hannover.de/dataset/c76adf5a-9aa8-4ebe-bbbe-0e61436cf033/resource/bd5d8d95-b3e2-4f25-a928-d75df8faf462/download/wavelet_gust_analysis.zip",
    #                 "url": "https://data.uni-hannover.de/dataset/c76adf5a-9aa8-4ebe-bbbe-0e61436cf033/resource/bd5d8d95-b3e2-4f25-a928-d75df8faf462/download/wavelet_gust_analysis.zip",
    #                 "mimetype": "application/zip", "format": "ZIP", "size": 96112,
    #                 "uri": "https://data.uni-hannover.de/dataset/c76adf5a-9aa8-4ebe-bbbe-0e61436cf033/resource/bd5d8d95-b3e2-4f25-a928-d75df8faf462"}],
    #  "title": "A generic gust definition and detection method based on wavelet-analysis",
    #  "notes": "This dataset is associated with the paper Knoop et al. (2019) titled  \"A generic gust definition and detection method based on wavelet-analysis\" published in \"Advances in Science and Research (ASR)\" within the Special Issue: 18th EMS Annual Meeting: European Conference for Applied Meteorology and Climatology 2018. It contains the data and analysis software required to recreate all figures in the publication.",
    #  "tags": [{"name": "large eddy simulation"}, {"name": "Gusts"}, {"name": "Meteorology"},
    #           {"name": "Wavelet Analysis"}, {"name": "LES model"}, {"name": "LES"}], "license_id": ""}

def test_get_organization_data_from_api():
    title = "AG PALM"
    obj = LUH_DCAT_DatasetParser()
    res = obj.get_organization_data_from_api(title)

#    print(res)
    assert title == res['display_name']