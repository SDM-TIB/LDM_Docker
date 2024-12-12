import os

from .__version__ import __version__

STORAGE_PATH = os.environ.get('CKAN_STORAGE_PATH', '/var/lib/ckan')
FEDORKG_PATH = os.path.join(STORAGE_PATH, 'fedorkg')
SEMSD_PATH = os.path.join(FEDORKG_PATH, 'rdfmts.ttl')

QUERY_DELETE_PROPERTY_RANGE = '''
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX semsd: <https://research.tib.eu/semantic-source-description#>
DELETE {{
  ?pred semsd:propertyRange ?pr .
  ?pr ?p ?o .
}} WHERE {{
  ?pred a rdf:Property ;
    semsd:propertyRange ?pr .
  ?pr a semsd:PropertyRange ;
    semsd:hasSource <{url}> ;
    ?p ?o .
}}
'''

QUERY_DELETE_SOURCE_FROM_PROPERTY = '''
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX semsd: <https://research.tib.eu/semantic-source-description#>
DELETE {{
  ?pred semsd:hasSource <{url}> .
}} WHERE {{
  ?pred a rdf:Property ;
    semsd:hasSource <{url}> .
}}
'''

QUERY_DELETE_PROPERTY_NO_SOURCE = '''
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX semsd: <https://research.tib.eu/semantic-source-description#>
DELETE {
  ?c semsd:hasPredicate ?pred .
  ?pred ?p ?o .
} WHERE {
  ?pred a rdf:Property ;
    ?p ?o .
  FILTER NOT EXISTS { ?pred semsd:hasSource ?source }
  ?c a rdfs:Class ;
    semsd:hasProperty ?pred .
}
'''

QUERY_DELETE_SOURCE_FROM_CLASS = '''
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX semsd: <https://research.tib.eu/semantic-source-description#>
DELETE {{
  ?c semsd:hasSource <{url}> .
}} WHERE {{
  ?c a rdfs:Class ;
    semsd:hasSource <{url}> .
}}
'''

QUERY_DELETE_CLASS_NO_SOURCE = '''
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX semsd: <https://research.tib.eu/semantic-source-description#>
DELETE {
  ?c ?p ?o .
} WHERE {
  ?c a rdfs:Class ;
    ?p ?o .
  FILTER NOT EXISTS { ?c semsd:hasSource ?source }
}
'''

QUERY_DELETE_SOURCE = '''
PREFIX semsd: <https://research.tib.eu/semantic-source-description#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
DELETE {{
  ?source ?p ?o .
}} WHERE {{
  ?source a semsd:DataSource ;
    semsd:hasURL "{url}"^^xsd:anyURI ;
    ?p ?o .
}}
'''
