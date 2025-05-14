# LOCAL CKAN DATA
# ***************
local_organization_data = {'approval_status': 'approved',
                                'created': '2021-07-22T14:33:24.825599',
                                'description': 'The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.',
                                'display_name': 'TIB',
                                'id': '0c5362f5-b99e-41db-8256-3d0d7549bf4d',
                                'image_display_url': 'https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png',
                                'image_url': 'https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png',
                                'is_organization': True,
                                'name': 'tib-iasis',
                                'num_followers': 0,
                                'state': 'active',
                                'title': 'TIB',
                                'type': 'organization',
                                'tags': []}


local_dataset_data = {'author': 'Autodesk',
                      'author_email': '',
                      'creator_user_id': '6114fb41-d314-4c35-b8c1-278c9f997579',
                      'id': '476cdf71-1048-4a6f-a28a-58fff547dae5',
                      'isopen': True,
                      'license_id': 'cc-by',
                      'license_title': 'Creative Commons Attribution',
                      'license_url': 'http://www.opendefinition.org/licenses/cc-by',
                      'maintainer': '',
                      'maintainer_email': '',
                      'metadata_created': '2021-07-26T06:19:07.491127',
                      'metadata_modified': '2021-07-26T06:19:07.491139',
                      'name': 'example-cad',
                      'notes': 'Example usage of CAD visualization in 2D and 3D using CKAN Views.',
                      'num_resources': 2,
                      'num_tags': 0,
                      'organization': {'id': '0c5362f5-b99e-41db-8256-3d0d7549bf4d',
                                       'name': 'tib-iasis',
                                       'title': 'TIB',
                                       'type': 'organization',
                                       'description': 'The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.',
                                       'image_url': 'https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png',
                                       'created': '2021-07-22T14:33:24.825599',
                                       'is_organization': True,
                                       'approval_status': 'approved',
                                       'state': 'active'},
                      'owner_org': '0c5362f5-b99e-41db-8256-3d0d7549bf4d',
                      'private': False,
                      'state': 'active',
                      'title': 'Example CAD',
                      'type': 'dataset',
                      'url': 'https://knowledge.autodesk.com/support/autocad/downloads/caas/downloads/content/autocad-sample-files.html',
                      'version': '',
                      'extras': [{'key': 'foobar', 'value': 'baz'}],
                      'resources': [{'cache_last_updated': None,
                                     'cache_url': None,
                                     'created': '2017-11-23T17:37:19.897441',
                                     'datastore_active': False,
                                     'description': '',
                                     'format': '',
                                     'hash': '',
                                     'id': '4ee0ec1c-c72b-4bad-be73-364a735cea5c',
                                     'last_modified': '2017-12-01T16:52:30.511835',
                                     'metadata_modified': '2021-07-26T05:23:45.398718',
                                     'mimetype': None,
                                     'mimetype_inner': None,
                                     'name': 'Example 2D .dwg file',
                                     'package_id': '476cdf71-1048-4a6f-a28a-58fff547dae5',
                                     'position': 0,
                                     'resource_type': None,
                                     'size': 169807,
                                     'state': 'active',
                                     'url': 'https://github.com/guillermobet/files/raw/master/Drive_shaft.dwg',
                                     'url_type': ''},
                                    {'cache_last_updated': None,
                                     'cache_url': None,
                                     'created': '2017-11-23T17:40:23.217872',
                                     'datastore_active': False,
                                     'description': '',
                                     'format': '',
                                     'hash': '',
                                     'id': '1342ec64-f18e-4860-93cc-f6dd194d56ec',
                                     'last_modified': '2017-12-01T16:53:23.693615',
                                     'metadata_modified': '2021-07-26T05:23:45.401967',
                                     'mimetype': None,
                                     'mimetype_inner': None,
                                     'name': 'Example 3D .dwg file',
                                     'package_id': '476cdf71-1048-4a6f-a28a-58fff547dae5',
                                     'position': 1,
                                     'resource_type': None,
                                     'size': 733036,
                                     'state': 'active',
                                     'url': 'https://github.com/guillermobet/files/raw/master/visualization_-_aerial.dwg',
                                     'url_type': ''}],
                      'tags': [],
                      'groups': [],
                      'relationships_as_subject': [],
                      'relationships_as_object': []}

# LEOPARD API DATA
# ***************


leopard_dataset_parsed_to_dict ={
    'header': {
        'identifier': 'oai:https://leopard.tu-braunschweig.de/:dbbs_mods_00078205',
        'datestamp': '2024-11-28'
    },
    'metadata': {
        'leoPARDDataset': {
            'identifier': '10.24355/dbbs.084-202411180831-0',
            'identifierType': 'DOI',
            'creators': [
                {
                    'creator': {
                        'creatorName': {
                            'creatorName': 'Pucker, Boas',
                            'nameType': 'Personal'
                        },
                        'givenName': 'Boas',
                        'familyName': 'Pucker',
                        'nameIdentifier': {
                            'nameIdentifier': '1191400093',
                            'nameIdentifierScheme': 'GND'
                        }
                    }
                }
            ],
            'titles': [
                {
                    'title': {
                        'title': 'Gene Expression of Theobroma cacao'
                    },
                    '{http://www.w3.org/XML/1998/namespace}lang': 'de'
                }
            ],
            'publisher': 'Universitätsbibliothek Braunschweig',
            'publicationYear': '2024',
            'subjectAreas': [
                {
                    'subject': {
                        'subject': 'Plant genetics'
                    }
                },
                {
                    'subject': {
                        'subject': 'RNA-Sequence'
                    }
                },
                {
                    'subject': {
                        'subject': 'Gene expression'
                    }
                },
                {
                    'subject': {
                        'subject': '58'
                    },
                    'subjectScheme': 'ddc'
                }
            ],
            'resourceType': {
                'resourceType': 'research_data',
                'resourceTypeGeneral': 'Dataset'
            },
            'rightsList': [
                {
                    'rights': {
                        'rights': {
                            'rights': 'Attribution 4.0',
                            'rightsIdentifier': 'CC-BY-4.0',
                            'rightsURI': 'https://creativecommons.org/licenses/by/4.0/',
                            '{http://www.w3.org/XML/1998/namespace}lang': 'en'
                        }
                    }
                }
            ],
            'descriptions': [
                {
                    'description': {
                        'description': 'Gene expression of Theobroma cacao was analyzed based on various reference sequences. All available paired-end RNA-seq datasets were downloaded from the Sequence Read Archive and processed with kallisto. Final count tables were generated with customized Python scripts.'
                    },
                    'descriptionType': 'Abstract',
                    '{http://www.w3.org/XML/1998/namespace}lang': 'en'
                }
            ],
            'keywords': [],
            'contributors': [
                {
                    'contributor': {
                        'contributorName': 'Universitätsbibliothek Braunschweig'
                    }
                }
            ],
            'language': 'en',
            'alternateIdentifiers': [
                {
                    'alternateIdentifier': {
                        'alternateIdentifier': 'https://leopard.tu-braunschweig.de/receive/dbbs_mods_00078205'
                    },
                    'alternateIdentifierType': 'URL'
                },
                {
                    'alternateIdentifier': {
                        'alternateIdentifier': 'dbbs_mods_00078205'
                    },
                    'alternateIdentifierType': 'MyCoRe'
                }
            ],
            'relatedIdentifiers': [
                {
                    'relatedIdentifier': {
                        'relatedIdentifier': 'https://leopard.tu-braunschweig.de/receive/dbbs_mods_00078205?XSL.Transformer=mods'
                    },
                    'relatedIdentifierType': 'URL',
                    'relatedMetadataScheme': 'mods',
                    'relationType': 'HasMetadata',
                    'schemeURI': 'https://www.loc.gov/standards/mods/v3/mods-3-7.xsd'
                }
            ]
        }
    }
}

leopard_dataset_parsed_to_ckan_dict = {
    'repository_name': 'LeoPARD (TU Braunschweig Publications And Research Data)',
    'type': 'vdataset',
    'source_metadata_created': '2024',
    'source_metadata_modified': '',
    'owner_org': 'leopard',
    'author': 'Pucker, Boas',
    'author_email': '',
    'doi': '10.24355/dbbs.084-202411180831-0',
    'doi_date_published': '2024',
    'doi_publisher': '',
    'doi_status': 'True',
    'license_id': 'CC-BY-4.0',
    'license_title': 'Attribution 4.0',
    'name': 'leo-doi-10-24355-dbbs-084-202411180831-0',
    'notes': 'Abstract: Gene expression of Theobroma cacao was analyzed based on various reference sequences. All available paired-end RNA-seq datasets were downloaded from the Sequence Read Archive and processed with kallisto. Final count tables were generated with customized Python scripts.',
    'organization': {
        'approval_status': 'approved',
        'description': 'Technische Universität Braunschweig - Universitätsbibliothek Braunschweig.',
        'display_name': 'leoPARD (TU Braunschweig Publications And Research Data)',
        'image_display_url': 'logo-leopard-white.png',
        'image_url': 'logo-leopard-white.png',
        'is_organization': True,
        'name': 'leopard',
        'state': 'active',
        'title': 'leoPARD (TU Braunschweig Publications And Research Data)',
        'type': 'organization'
    },
    'title': 'Gene expression of theobroma cacao',
    'url': 'https://doi.org/10.24355/dbbs.084-202411180831-0',
    'citation': [],
    'givenName': 'Boas',
    'familyName': 'Pucker',
    'orcid': '',
    'publication_year': '2024',
    'subject_areas': [
        {
            'subject_area_additional': '',
            'subject_area_name': 'Plant genetics'
        },
        {
            'subject_area_additional': '',
            'subject_area_name': 'RNA-Sequence'
        },
        {
            'subject_area_additional': '',
            'subject_area_name': 'Gene expression'
        },
        {
            'subject_area_additional': '',
            'subject_area_name': '58'
        }
    ],
    'resource_type': 'Dataset - research_data',
    'related_identifiers': [
        {
            'identifier': 'https://leopard.tu-braunschweig.de/receive/dbbs_mods_00078205?XSL.Transformer=mods',
            'identifier_type': 'URL',
            'relation_type': 'HasMetadata'
        }
    ]
}

LDM_imported_dataset = {
        "author": "Clemens Huebler",
        "author_email": "c.huebler@isd.uni-hannover.de",
        "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700",
        "doi": "10.25835/0078042",
        "doi_date_published": "2020-06-29",
        "doi_publisher": "LUIS",
        "doi_status": "True",
        "domain": "https://data.uni-hannover.de",
        "have_copyright": "Yes",
        "id": "7e6929b4-0aa0-44b4-9a1c-29d42bb78aa3",
        "isopen": False,
        "license_id": "CC-BY-3.0",
        "license_title": "CC-BY-3.0",
        "maintainer": "Clemens Huebler",
        "maintainer_email": "c.huebler@isd.uni-hannover.de",
        "metadata_created": "2021-10-07T09:58:55.243407",
        "metadata_modified": "2021-10-07T09:58:55.243416",
        "name": "luh-windturbine-simulation-for-meta-modelling",
        "notes": "This data set correlates environmental conditions acting on an offshore wind turbine (inputs) with fatigue loads of the turbine (outputs).\r\nThe investigated wind turbine is the NREL 5MW reference turbine and the OC3 monopile.\r\nEnvironmental conditions are based on FINO3 data (https://www.fino3.de/en/).\r\nTime series of bending moments and shear forces at mudline and blade root bending moments are computed using the FASTv8 simulation code by the NREL.\r\n10.000 simulations for varying environmental conditions (and varying random seeds) were conducted.\r\nShort-term damage equivalent loads (DELs) representing fatigue were calculated for several relevant positions (at mudline and at the blade root).\r\nFor further information, it is referred to \"Huebler, C., & Rolfes, R. (2020). Analysis of the influence of climate change on the fatigue lifetime of offshore wind turbines using imprecise probabilities. Wind Energy. 2020;1–15.\"",
        "num_resources": 2,
        "num_tags": 3,
        "organization": {
            "id": "3d4e7da1-a0ef-4af1-9c07-56cf5e35084d",
            "name": "institut-fur-statik-und-dynamik",
            "title": "Institut für Statik und Dynamik",
            "type": "organization",
            "description": "(Institute of Structural Analysis) \r\nAppelstraße 9A \r\n__30167 Hannover (Germany)__\r\n\r\nhttps://www.isd.uni-hannover.de/en/institute/",
            "image_url": "",
            "created": "2021-10-07T11:46:15.762388",
            "is_organization": True,
            "approval_status": "approved",
            "state": "active"
        },
        "owner_org": "3d4e7da1-a0ef-4af1-9c07-56cf5e35084d",
        "private": False,
        "repository_name": "Leibniz University Hannover",
        "services_used_list": "",
        "source_metadata_created": "2020-06-29T13:56:20.726566",
        "source_metadata_modified": "2021-07-06T09:21:41.322946",
        "state": "active",
        "terms_of_usage": "Yes",
        "title": "Wind Turbine Simulation Data for Meta-Modelling",
        "type": "vdataset",
        "url": "https://data.uni-hannover.de/dataset/windturbine-simulation-for-meta-modelling",
        "version": "",
        "resources": [
            {
                "cache_last_updated": None,
                "cache_url": None,
                "created": "2020-06-29T13:56:24.253776",
                "datastore_active": False,
                "description": "",
                "downloadall_datapackage_hash": "98b5bd1da7a98e0a79ab9dae7e68f8cd",
                "downloadall_metadata_modified": "2021-07-06T09:21:25.079814",
                "format": "ZIP",
                "hash": "",
                "id": "da3a4b40-c6b3-42de-87a4-4ea60c441910",
                "last_modified": "2021-07-06T09:21:36.339262",
                "metadata_modified": "2021-10-07T09:58:55.231269",
                "mimetype": "application/zip",
                "mimetype_inner": None,
                "name": "All resource data",
                "package_id": "7e6929b4-0aa0-44b4-9a1c-29d42bb78aa3",
                "position": 0,
                "resource_type": None,
                "revision_id": "5b858701-baff-4dff-86a8-06cb0c01f224",
                "size": 875,
                "state": "active",
                "url": "https://data.uni-hannover.de/dataset/7e6929b4-0aa0-44b4-9a1c-29d42bb78aa3/resource/da3a4b40-c6b3-42de-87a4-4ea60c441910/download/windturbine-simulation-for-meta-modelling-otpq81.zip",
                "url_type": ""
            },
            {
                "cache_last_updated": None,
                "cache_url": None,
                "created": "2020-06-29T13:59:45.579275",
                "datastore_active": False,
                "description": "This data set correlates environmental conditions acting on an offshore wind turbine (inputs) with fatigue loads of the turbine (outputs).\r\nThe investigated wind turbine is the NREL 5MW reference turbine and the OC3 monopile.\r\nEnvironmental conditions are based on FINO3 data (https://www.fino3.de/en/).\r\nTime series of bending moments and shear forces at mudline and blade root bending moments are computed using the FASTv8 simulation code by the NREL.\r\n10.000 simulations for varying environmental conditions (and varying random seeds) were conducted.\r\nShort-term damage equivalent loads (DELs) representing fatigue were calculated for several relevant positions (at mudline and at the blade root).",
                "format": "TXT",
                "hash": "",
                "id": "0f24dea1-53b3-4cb9-afa4-16b342524aa8",
                "last_modified": "2020-06-29T13:59:45.533215",
                "metadata_modified": "2021-10-07T09:58:55.233372",
                "mimetype": "text/plain",
                "mimetype_inner": None,
                "name": "Metamodeldata.txt",
                "package_id": "7e6929b4-0aa0-44b4-9a1c-29d42bb78aa3",
                "position": 1,
                "resource_type": None,
                "revision_id": "f5dad358-82bc-44cd-84a8-5f68f14a774e",
                "size": 1142901,
                "state": "active",
                "url": "https://data.uni-hannover.de/dataset/7e6929b4-0aa0-44b4-9a1c-29d42bb78aa3/resource/0f24dea1-53b3-4cb9-afa4-16b342524aa8/download/metamodeldata.txt",
                "url_type": ""
            }
        ],
        "tags": [
            {
                "display_name": "FAST",
                "id": "235ed4d9-3def-4174-bb4d-51950abe8813",
                "name": "FAST",
                "state": "active",
                "vocabulary_id": None
            },
            {
                "display_name": "meta-model",
                "id": "2c83feeb-a00e-4821-91b1-c42fb828a3ad",
                "name": "meta-model",
                "state": "active",
                "vocabulary_id": None
            },
            {
                "display_name": "wind energy",
                "id": "81223f1d-955d-4ff4-8be0-1fda56b540ba",
                "name": "wind energy",
                "state": "active",
                "vocabulary_id": None
            }
        ],
        "groups": [],
        "relationships_as_subject": [],
        "relationships_as_object": []
    }

resumption_token_ok = {'resumptionToken': 'rows=100@@searchMark=10.22000/72@@from=0001-01-01T00:00:00Z@@total=179@@until=9999-12-31T23:59:59Z@@metadataPrefix=radar', 'completeListSize': '179'}

resumption_token_empty = {'resumptionToken': ''}

expected_list_of_dict_from_leopard = [{'header': {'identifier': 'oai:https://leopard.tu-braunschweig.de/:dbbs_mods_00078205', 'datestamp': '2024-11-28'}, 'metadata': {'leoPARDDataset': {'identifier': '10.24355/dbbs.084-202411180831-0', 'identifierType': 'DOI', 'creators': [{'creator': {'creatorName': {'creatorName': 'Pucker, Boas', 'nameType': 'Personal'}, 'givenName': 'Boas', 'familyName': 'Pucker', 'nameIdentifier': {'nameIdentifier': '1191400093', 'nameIdentifierScheme': 'GND'}}}], 'titles': [{'title': {'title': 'Gene Expression of Theobroma cacao'}, '{http://www.w3.org/XML/1998/namespace}lang': 'de'}], 'publisher': 'Universitätsbibliothek Braunschweig', 'publicationYear': '2024', 'subjectAreas': [{'subject': {'subject': 'Plant genetics'}}, {'subject': {'subject': 'RNA-Sequence'}}, {'subject': {'subject': 'Gene expression'}}, {'subject': {'subject': '58'}, 'subjectScheme': 'ddc'}], 'resourceType': {'resourceType': 'research_data', 'resourceTypeGeneral': 'Dataset'}, 'rightsList': [{'rights': {'rights': {'rights': 'Attribution 4.0', 'rightsIdentifier': 'CC-BY-4.0', 'rightsURI': 'https://creativecommons.org/licenses/by/4.0/', '{http://www.w3.org/XML/1998/namespace}lang': 'en'}}}], 'descriptions': [{'description': {'description': 'Gene expression of Theobroma cacao was analyzed based on various reference sequences. All available paired-end RNA-seq datasets were downloaded from the Sequence Read Archive and processed with kallisto. Final count tables were generated with customized Python scripts.'}, 'descriptionType': 'Abstract', '{http://www.w3.org/XML/1998/namespace}lang': 'en'}], 'keywords': [], 'contributors': [{'contributor': {'contributorName': 'Universitätsbibliothek Braunschweig'}}], 'language': 'en', 'alternateIdentifiers': [{'alternateIdentifier': {'alternateIdentifier': 'https://leopard.tu-braunschweig.de/receive/dbbs_mods_00078205'}, 'alternateIdentifierType': 'URL'}, {'alternateIdentifier': {'alternateIdentifier': 'dbbs_mods_00078205'}, 'alternateIdentifierType': 'MyCoRe'}], 'relatedIdentifiers': [{'relatedIdentifier': {'relatedIdentifier': 'https://leopard.tu-braunschweig.de/receive/dbbs_mods_00078205?XSL.Transformer=mods'}, 'relatedIdentifierType': 'URL', 'relatedMetadataScheme': 'mods', 'relationType': 'HasMetadata', 'schemeURI': 'https://www.loc.gov/standards/mods/v3/mods-3-7.xsd'}]}}}, {'header': {'identifier': 'oai:https://leopard.tu-braunschweig.de/:dbbs_mods_00078186', 'datestamp': '2024-11-28'}, 'metadata': {'leoPARDDataset': {'identifier': '10.24355/dbbs.084-202411140638-0', 'identifierType': 'DOI', 'creators': [{'creator': {'creatorName': {'creatorName': 'Pucker, Boas', 'nameType': 'Personal'}, 'givenName': 'Boas', 'familyName': 'Pucker', 'nameIdentifier': {'nameIdentifier': '0000-0002-3321-7471', 'nameIdentifierScheme': 'ORCID', 'schemeURI': 'http://orcid.org/'}}}, {'creator': {'creatorName': {'creatorName': 'Marín Recinos, María Fernanda', 'nameType': 'Personal'}, 'givenName': 'María', 'familyName': 'Marín Recinos', 'nameIdentifier': {'nameIdentifier': '0000-0001-5575-1264', 'nameIdentifierScheme': 'ORCID', 'schemeURI': 'http://orcid.org/'}}}, {'creator': {'creatorName': {'creatorName': 'Winnier, Sarah', 'nameType': 'Personal'}, 'givenName': 'Sarah', 'familyName': 'Winnier'}}, {'creator': {'creatorName': {'creatorName': 'Lagerhausen, Kiersten', 'nameType': 'Personal'}, 'givenName': 'Kiersten', 'familyName': 'Lagerhausen'}}, {'creator': {'creatorName': {'creatorName': 'Ajavi, Blessing', 'nameType': 'Personal'}, 'givenName': 'Blessing', 'familyName': 'Ajavi'}}, {'creator': {'creatorName': {'creatorName': 'Wolff, Katharina', 'nameType': 'Personal'}, 'givenName': 'Katharina', 'familyName': 'Wolff', 'nameIdentifier': {'nameIdentifier': '0009-0009-9180-3549', 'nameIdentifierScheme': 'ORCID', 'schemeURI': 'http://orcid.org/'}}}, {'creator': {'creatorName': {'creatorName': 'Friedhoff, Ronja', 'nameType': 'Personal'}, 'givenName': 'Ronja', 'familyName': 'Friedhoff', 'nameIdentifier': {'nameIdentifier': '0009-0002-0270-4661', 'nameIdentifierScheme': 'ORCID', 'schemeURI': 'http://orcid.org/'}}}, {'creator': {'creatorName': {'creatorName': 'Dassow, Chiara Marie', 'nameType': 'Personal'}, 'givenName': 'Chiara', 'familyName': 'Dassow', 'nameIdentifier': {'nameIdentifier': '0009-0002-9413-2460', 'nameIdentifierScheme': 'ORCID', 'schemeURI': 'http://orcid.org/'}}}, {'creator': {'creatorName': {'creatorName': 'Choudhary, Nancy', 'nameType': 'Personal'}, 'givenName': 'Nancy', 'familyName': 'Choudhary', 'nameIdentifier': {'nameIdentifier': '0000-0002-2562-7905', 'nameIdentifierScheme': 'ORCID', 'schemeURI': 'http://orcid.org/'}}}], 'titles': [{'title': {'title': 'Genome sequence and annotation of Theobroma cacao'}, '{http://www.w3.org/XML/1998/namespace}lang': 'de'}], 'publisher': 'Universitätsbibliothek Braunschweig', 'publicationYear': '2024', 'subjectAreas': [{'subject': {'subject': '58'}, 'subjectScheme': 'ddc'}], 'resourceType': {'resourceType': 'research_data', 'resourceTypeGeneral': 'Dataset'}, 'rightsList': [{'rights': {'rights': {'rights': 'Attribution 4.0', 'rightsIdentifier': 'CC-BY-4.0', 'rightsURI': 'https://creativecommons.org/licenses/by/4.0/', '{http://www.w3.org/XML/1998/namespace}lang': 'en'}}}], 'descriptions': [{'description': {'description': 'A high quality genome sequence of Theobroma cacao is presented together with predicted polypeptide sequences and a functional annoation. The genome sequence was assembled based on ONT long reads using NextDenvo. BRAKER3 was used for the annotation of protein encoding genes.'}, 'descriptionType': 'Abstract', '{http://www.w3.org/XML/1998/namespace}lang': 'de'}], 'keywords': [], 'contributors': [{'contributor': {'contributorName': 'Universitätsbibliothek Braunschweig'}}], 'language': 'en', 'alternateIdentifiers': [{'alternateIdentifier': {'alternateIdentifier': 'https://leopard.tu-braunschweig.de/receive/dbbs_mods_00078186'}, 'alternateIdentifierType': 'URL'}, {'alternateIdentifier': {'alternateIdentifier': 'dbbs_mods_00078186'}, 'alternateIdentifierType': 'MyCoRe'}], 'relatedIdentifiers': [{'relatedIdentifier': {'relatedIdentifier': 'https://leopard.tu-braunschweig.de/receive/dbbs_mods_00078186?XSL.Transformer=mods'}, 'relatedIdentifierType': 'URL', 'relatedMetadataScheme': 'mods', 'relationType': 'HasMetadata', 'schemeURI': 'https://www.loc.gov/standards/mods/v3/mods-3-7.xsd'}]}}}, {'header': {'identifier': 'oai:https://leopard.tu-braunschweig.de/:dbbs_mods_00078118', 'datestamp': '2024-11-19'}, 'metadata': {'leoPARDDataset': {'identifier': '10.24355/dbbs.084-202411011459-0', 'identifierType': 'DOI', 'creators': [{'creator': {'creatorName': {'creatorName': 'Elsner, Carsten', 'nameType': 'Personal'}, 'givenName': 'Carsten', 'familyName': 'Elsner', 'nameIdentifier': {'nameIdentifier': '0000-0002-8204-8117', 'nameIdentifierScheme': 'ORCID', 'schemeURI': 'http://orcid.org/'}}}], 'titles': [{'title': {'title': 'Projekt ADoRe-OA: Umfrage zur Ermittlung von Bedarfen zur Be- und Verarbeitung publikationsbezogener Daten im Rahmen von Open-Access-Förderungen'}, '{http://www.w3.org/XML/1998/namespace}lang': 'de'}, {'title': {'title': 'Project ADoRe-OA: Survey to determine requirements for the processing of publication-related data in the context of Open Access funding'}, 'titleType': 'TranslatedTitle', '{http://www.w3.org/XML/1998/namespace}lang': 'en'}], 'publisher': 'Universitätsbibliothek Braunschweig', 'publicationYear': '2024', 'subjectAreas': [{'subject': {'subject': 'Open Access'}}, {'subject': {'subject': '025'}, 'subjectScheme': 'ddc'}], 'resourceType': {'resourceType': 'research_data', 'resourceTypeGeneral': 'Dataset'}, 'rightsList': [{'rights': {'rights': {'rights': 'Attribution 4.0', 'rightsIdentifier': 'CC-BY-4.0', 'rightsURI': 'https://creativecommons.org/licenses/by/4.0/', '{http://www.w3.org/XML/1998/namespace}lang': 'en'}}}], 'descriptions': [{'description': {'description': 'Die im Rahmen des BMBF-geförderten Projekts ADoRe-OA und der damit verbundenen Weiterentwicklung von CODA (Customizable Open Access Database Application) durchgeführten Umfrage wurde ermittelt, welche Daten zur Publikationsförderung wie erhoben und im weiteren Prozess be- und verarbeitet werden. Welche Anforderungen werden z.B. bezüglich Schnittstellen, Funktionalitäten und Metadaten werden an ein Tool gestellt, das die damit verbundenen Prozesse ideal abbildet und somit den Arbeitsaufwand minimiert. Vor diesem Hintergrund richtete sich diese Umfrage besonders an Mitarbeiter und Mitarbeiterinnen an Bibliotheken und/oder Verwaltungseinrichtungen, die in Ihrem Arbeitsalltag mit der Be- bzw. Verarbeitung dieser Daten, der Prüfung und/oder der Bewirtschaftung von Anträgen zur Förderung von Open-Access-Publikationen betraut sind.'}, 'descriptionType': 'Abstract', '{http://www.w3.org/XML/1998/namespace}lang': 'de'}, {'description': {'description': 'The survey carried out as part of the BMBF-funded ADoRe-OA project and the associated further development of CODA (Customizable Open Access Database Application) determined which data is collected for publication funding and how it is handled and processed in the further process. What requirements are placed on a tool, e.g. with regard to interfaces, functionalities and metadata, that ideally maps the associated processes and thus minimizes the workload? Against this background, this survey was aimed in particular at employees of libraries and/or administrative institutions who are entrusted with the processing of this data, the review and/or management of applications for the funding of open access publications in their everyday work.'}, 'descriptionType': 'Abstract', '{http://www.w3.org/XML/1998/namespace}lang': 'en'}], 'keywords': [], 'contributors': [{'contributor': {'contributorName': 'Universitätsbibliothek Braunschweig'}}], 'language': 'de', 'alternateIdentifiers': [{'alternateIdentifier': {'alternateIdentifier': 'urn:nbn:de:gbv:084-2024110115170'}, 'alternateIdentifierType': 'URN'}, {'alternateIdentifier': {'alternateIdentifier': 'https://leopard.tu-braunschweig.de/receive/dbbs_mods_00078118'}, 'alternateIdentifierType': 'URL'}, {'alternateIdentifier': {'alternateIdentifier': 'dbbs_mods_00078118'}, 'alternateIdentifierType': 'MyCoRe'}], 'relatedIdentifiers': [{'relatedIdentifier': {'relatedIdentifier': 'https://leopard.tu-braunschweig.de/receive/dbbs_mods_00078118?XSL.Transformer=mods'}, 'relatedIdentifierType': 'URL', 'relatedMetadataScheme': 'mods', 'relationType': 'HasMetadata', 'schemeURI': 'https://www.loc.gov/standards/mods/v3/mods-3-7.xsd'}]}}}]

leopard_all_datasets_list_response = [{'repository_name': 'LeoPARD (TU Braunschweig Publications And Research Data)', 'type': 'vdataset', 'source_metadata_created': '2024', 'source_metadata_modified': '', 'owner_org': 'leopard', 'author': 'Pucker, Boas', 'author_email': '', 'doi': '10.24355/dbbs.084-202411180831-0', 'doi_date_published': '2024', 'doi_publisher': '', 'doi_status': 'True', 'license_id': 'CC-BY-4.0', 'license_title': 'Attribution 4.0', 'name': 'leo-doi-10-24355-dbbs-084-202411180831-0', 'notes': 'Abstract: Gene expression of Theobroma cacao was analyzed based on various reference sequences. All available paired-end RNA-seq datasets were downloaded from the Sequence Read Archive and processed with kallisto. Final count tables were generated with customized Python scripts.', 'organization': {'approval_status': 'approved', 'description': 'Technische Universität Braunschweig - Universitätsbibliothek Braunschweig.', 'display_name': 'leoPARD (TU Braunschweig Publications And Research Data)', 'image_display_url': 'logo-leopard-white.png', 'image_url': 'logo-leopard-white.png', 'is_organization': True, 'name': 'leopard', 'state': 'active', 'title': 'leoPARD (TU Braunschweig Publications And Research Data)', 'type': 'organization'}, 'title': 'Gene expression of theobroma cacao', 'url': 'https://doi.org/10.24355/dbbs.084-202411180831-0', 'citation': [], 'givenName': 'Boas', 'familyName': 'Pucker', 'orcid': '', 'publication_year': '2024', 'subject_areas': [{'subject_area_additional': '', 'subject_area_name': 'Plant genetics'}, {'subject_area_additional': '', 'subject_area_name': 'RNA-Sequence'}, {'subject_area_additional': '', 'subject_area_name': 'Gene expression'}, {'subject_area_additional': '', 'subject_area_name': '58'}], 'resource_type': 'Dataset - research_data', 'related_identifiers': [{'identifier': 'https://leopard.tu-braunschweig.de/receive/dbbs_mods_00078205?XSL.Transformer=mods', 'identifier_type': 'URL', 'relation_type': 'HasMetadata'}]}, {'repository_name': 'LeoPARD (TU Braunschweig Publications And Research Data)', 'type': 'vdataset', 'source_metadata_created': '2024', 'source_metadata_modified': '', 'owner_org': 'leopard', 'author': 'Pucker, Boas', 'author_email': '', 'doi': '10.24355/dbbs.084-202411140638-0', 'doi_date_published': '2024', 'doi_publisher': '', 'doi_status': 'True', 'license_id': 'CC-BY-4.0', 'license_title': 'Attribution 4.0', 'name': 'leo-doi-10-24355-dbbs-084-202411140638-0', 'notes': 'Abstract: A high quality genome sequence of Theobroma cacao is presented together with predicted polypeptide sequences and a functional annoation. The genome sequence was assembled based on ONT long reads using NextDenvo. BRAKER3 was used for the annotation of protein encoding genes.', 'organization': {'approval_status': 'approved', 'description': 'Technische Universität Braunschweig - Universitätsbibliothek Braunschweig.', 'display_name': 'leoPARD (TU Braunschweig Publications And Research Data)', 'image_display_url': 'logo-leopard-white.png', 'image_url': 'logo-leopard-white.png', 'is_organization': True, 'name': 'leopard', 'state': 'active', 'title': 'leoPARD (TU Braunschweig Publications And Research Data)', 'type': 'organization'}, 'title': 'Genome sequence and annotation of theobroma cacao', 'url': 'https://doi.org/10.24355/dbbs.084-202411140638-0', 'citation': [], 'givenName': 'Boas', 'familyName': 'Pucker', 'orcid': '0000-0002-3321-7471', 'extra_authors': [{'extra_author': 'Marín Recinos, María Fernanda', 'givenName': 'María', 'familyName': 'Marín Recinos', 'orcid': '0000-0001-5575-1264'}, {'extra_author': 'Winnier, Sarah', 'givenName': 'Sarah', 'familyName': 'Winnier', 'orcid': ''}, {'extra_author': 'Lagerhausen, Kiersten', 'givenName': 'Kiersten', 'familyName': 'Lagerhausen', 'orcid': ''}, {'extra_author': 'Ajavi, Blessing', 'givenName': 'Blessing', 'familyName': 'Ajavi', 'orcid': ''}, {'extra_author': 'Wolff, Katharina', 'givenName': 'Katharina', 'familyName': 'Wolff', 'orcid': '0009-0009-9180-3549'}, {'extra_author': 'Friedhoff, Ronja', 'givenName': 'Ronja', 'familyName': 'Friedhoff', 'orcid': '0009-0002-0270-4661'}, {'extra_author': 'Dassow, Chiara Marie', 'givenName': 'Chiara', 'familyName': 'Dassow', 'orcid': '0009-0002-9413-2460'}, {'extra_author': 'Choudhary, Nancy', 'givenName': 'Nancy', 'familyName': 'Choudhary', 'orcid': '0000-0002-2562-7905'}], 'publication_year': '2024', 'subject_areas': [{'subject_area_additional': '', 'subject_area_name': '58'}], 'resource_type': 'Dataset - research_data', 'related_identifiers': [{'identifier': 'https://leopard.tu-braunschweig.de/receive/dbbs_mods_00078186?XSL.Transformer=mods', 'identifier_type': 'URL', 'relation_type': 'HasMetadata'}]}, {'repository_name': 'LeoPARD (TU Braunschweig Publications And Research Data)', 'type': 'vdataset', 'source_metadata_created': '2024', 'source_metadata_modified': '', 'owner_org': 'leopard', 'author': 'Elsner, Carsten', 'author_email': '', 'doi': '10.24355/dbbs.084-202411011459-0', 'doi_date_published': '2024', 'doi_publisher': '', 'doi_status': 'True', 'license_id': 'CC-BY-4.0', 'license_title': 'Attribution 4.0', 'name': 'leo-doi-10-24355-dbbs-084-202411011459-0', 'notes': 'Abstract: Die im Rahmen des BMBF-geförderten Projekts ADoRe-OA und der damit verbundenen Weiterentwicklung von CODA (Customizable Open Access Database Application) durchgeführten Umfrage wurde ermittelt, welche Daten zur Publikationsförderung wie erhoben und im weiteren Prozess be- und verarbeitet werden. Welche Anforderungen werden z.B. bezüglich Schnittstellen, Funktionalitäten und Metadaten werden an ein Tool gestellt, das die damit verbundenen Prozesse ideal abbildet und somit den Arbeitsaufwand minimiert. Vor diesem Hintergrund richtete sich diese Umfrage besonders an Mitarbeiter und Mitarbeiterinnen an Bibliotheken und/oder Verwaltungseinrichtungen, die in Ihrem Arbeitsalltag mit der Be- bzw. Verarbeitung dieser Daten, der Prüfung und/oder der Bewirtschaftung von Anträgen zur Förderung von Open-Access-Publikationen betraut sind.\r\nAbstract: The survey carried out as part of the BMBF-funded ADoRe-OA project and the associated further development of CODA (Customizable Open Access Database Application) determined which data is collected for publication funding and how it is handled and processed in the further process. What requirements are placed on a tool, e.g. with regard to interfaces, functionalities and metadata, that ideally maps the associated processes and thus minimizes the workload? Against this background, this survey was aimed in particular at employees of libraries and/or administrative institutions who are entrusted with the processing of this data, the review and/or management of applications for the funding of open access publications in their everyday work.', 'organization': {'approval_status': 'approved', 'description': 'Technische Universität Braunschweig - Universitätsbibliothek Braunschweig.', 'display_name': 'leoPARD (TU Braunschweig Publications And Research Data)', 'image_display_url': 'logo-leopard-white.png', 'image_url': 'logo-leopard-white.png', 'is_organization': True, 'name': 'leopard', 'state': 'active', 'title': 'leoPARD (TU Braunschweig Publications And Research Data)', 'type': 'organization'}, 'title': 'Projekt adore-oa: umfrage zur ermittlung von bedarfen zur be- und verarbeitung publikationsbezogener daten im rahmen von open-access-förderungen', 'url': 'https://doi.org/10.24355/dbbs.084-202411011459-0', 'citation': [], 'givenName': 'Carsten', 'familyName': 'Elsner', 'orcid': '0000-0002-8204-8117', 'publication_year': '2024', 'subject_areas': [{'subject_area_additional': '', 'subject_area_name': 'Open Access'}, {'subject_area_additional': '', 'subject_area_name': '025'}], 'resource_type': 'Dataset - research_data', 'related_identifiers': [{'identifier': 'https://leopard.tu-braunschweig.de/receive/dbbs_mods_00078118?XSL.Transformer=mods', 'identifier_type': 'URL', 'relation_type': 'HasMetadata'}]}]


ckan_dict_of_imported_dataset = {
        "author": "Pucker, Boas",
        "author_email": "",
        "citation": [],
        "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700",
        "doi": "10.24355/dbbs.084-202411180831-0",
        "doi_date_published": "2024",
        "doi_publisher": "",
        "doi_status": "True",
        "familyName": "Pucker",
        "givenName": "Boas",
        "id": "eced5975-25c9-41ab-915b-2b44a1113be2",
        "isopen": False,
        "license_id": "CC-BY-4.0",
        "license_title": "CC-BY-4.0",
        "metadata_created": "2024-12-11T08:27:10.515464",
        "metadata_modified": "2024-12-11T08:27:10.515479",
        "name": "leo-doi-10-24355-dbbs-084-202411180831-0",
        "notes": "Abstract: Gene expression of Theobroma cacao was analyzed based on various reference sequences. All available paired-end RNA-seq datasets were downloaded from the Sequence Read Archive and processed with kallisto. Final count tables were generated with customized Python scripts.",
        "num_resources": 0,
        "num_tags": 0,
        "orcid": "",
        "organization": {
            "id": "f1f77723-fee9-4de9-bd27-7d66c39916e2",
            "name": "leopard",
            "title": "leoPARD (TU Braunschweig Publications And Research Data)",
            "type": "organization",
            "description": "Technische Universität Braunschweig - Universitätsbibliothek Braunschweig.",
            "image_url": "logo-leopard-white.png",
            "created": "2024-12-11T09:25:08.680077",
            "is_organization": True,
            "approval_status": "approved",
            "state": "active"
        },
        "owner_org": "f1f77723-fee9-4de9-bd27-7d66c39916e2",
        "private": False,
        "publication_year": "2024",
        "repository_name": "LeoPARD (TU Braunschweig Publications And Research Data)",
        "resource_type": "Dataset - research_data",
        "services_used_list": "",
        "source_metadata_created": "2024",
        "source_metadata_modified": "",
        "state": "active",
        "title": "Gene expression of theobroma cacao",
        "type": "vdataset",
        "url": "https://doi.org/10.24355/dbbs.084-202411180831-0",
        "related_identifiers": [
            {
                "identifier": "https://leopard.tu-braunschweig.de/receive/dbbs_mods_00078205?XSL.Transformer=mods",
                "identifier_type": "URL",
                "relation_type": "HasMetadata"
            }
        ],
        'subject_areas': [{'subject_area_additional': '', 'subject_area_name': 'Plant genetics'}, {'subject_area_additional': '', 'subject_area_name': 'RNA-Sequence'}, {'subject_area_additional': '', 'subject_area_name': 'Gene expression'}, {'subject_area_additional': '', 'subject_area_name': '58'}],
        "resources": [],
        "tags": [],
        "groups": [],
        "relationships_as_subject": [],
        "relationships_as_object": []
    }




leopard_dict_of_imported_dataset = leopard_all_datasets_list_response[0]