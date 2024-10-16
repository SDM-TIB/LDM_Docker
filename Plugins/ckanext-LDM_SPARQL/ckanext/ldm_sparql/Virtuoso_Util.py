
from ckan.common import config
import ckan.plugins.toolkit as toolkit
from ckanext.ldm_sparql.RDFizer_Util import RDFizer_Util
from subprocess import check_output
#from ckanext.ldm_sparql.RDFizer.semantify import semantify
# from rdfizer import semantify
# import ckan.logic as logic
# import ckan.model as model
# from ckan.plugins import toolkit
# from ckan.common import config

import os
import requests
import logging
log = logging.getLogger(__name__)

from SPARQLWrapper import SPARQLWrapper, POST, DIGEST, JSON

class Virtuoso_Util:

    def __init__(self):

        # Plugin Configuration
        self.plugin_path = '/usr/lib/ckan/default/src/ckanext-LDM_SPARQL/ckanext/ldm_sparql'
        self.plugin_data_folder = config.get('ckan.storage_path', "/var/lib/ckan") 
        self.LDM_RDFfolder = config.get("LDMSPARQL_LDM_RDF_SINK_FOLDER_PATH",
                                        self.plugin_data_folder+"/rdf-sink")  # folder in LDM container+
        #self.LDM_RDF_LOADED_folder = config.get("LDMSPARQL_LDM_RDF_LOADED_FOLDER_PATH",
        #                                self.plugin_data_folder+'/rdf-loaded')  # folder in LDM container+
        self.VirtuosoUtil_temp_folder = self.plugin_data_folder + '/temp'
        self.load_data_tempfile = self.VirtuosoUtil_temp_folder + '/load_data.sql'

        # Virtuoso Configuration
        self.ViruosoEndpointEnabled = toolkit.asbool(config.get('LDMSPARQL_ENDPOINT_ENABLED', False))
        self.virtuosoIP = config.get('LDMSPARQL_ENDPOINT_IP', "0.0.0.0") # Docker container name
        self.dockerContainerName = config.get('LDMSPARQL_ENDPOINT_CONTAINER_NAME', "ldm_kg") # Docker container name
        self.virtuosoUser = config.get("LDMSPARQL_ENDPOINT_USER", 'dba')
        self.virtuosoPass = config.get("LDMSPARQL_ENDPOINT_PASSWD", 'dba')
        self.virtuosoPort = config.get("LDMSPARQL_ENDPOINT_PORT", '1111')
        self.virtuosoGraph = config.get("LDMSPARQL_ENDPOINT_GRAPH", 'http://ldm_kg:8890/')
        self.pubbyURL = config.get("LDMSPARQL_PUBBY_URL", 'http://localhost:8081/pubby/')
        self.FedQueryEngineURL = config.get("LDMSPARQL_DETRUSTY_URL", 'http://localhost:5002/sparql')

        self.virtuosoRDFfolder = config.get("LDMSPARQL_ENDPOINT_RDF_DUMP_FOLDER_PATH",  '/ldmsparql_data/rdf-sink') # folder in Virtuoso container+
        self.LDM_site_url = config.get('ckan.site_url', "http://localhost:5000")
        self.RDFfiletype = 'nt'

        if self.ViruosoEndpointEnabled:
            ldm_prefix = self.pubbyURL
        else:
            ldm_prefix = self.LDM_site_url + '/'
        self.PREFIX = {"rdf": "rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>",
                       "rdfs": "rdfs: <http://www.w3.org/2000/01/rdf-schema#>",
                       "dcat": "dcat: <http://www.w3.org/ns/dcat#>",
                       "vcard": "vcard: <http://www.w3.org/2006/vcard/ns#>",
                       "dct": "dct: <http://purl.org/dc/terms/>",
                       "schema": "schema: <http://schema.org/>",
                       "ldm": "ldm: <"+ldm_prefix+">" }
        # RDFizer_Util() instance
        self.rdfizer_obj = RDFizer_Util()

    def get_virtuoso_endpoint_URL(self):
        if self.ViruosoEndpointEnabled:
            return self.virtuosoGraph + "/sparql/"
        else:
            return ""

    def get_detrusty_endpoint_URL(self):
        return self.FedQueryEngineURL

    def get_pubby_URL_for_dataset(self, ds_dict):

        if self.ViruosoEndpointEnabled:
            fake_ds_dict = {'id': ds_dict['id']}
            url = self.rdfizer_obj._get_dataset_url_from(fake_ds_dict)
            return url
        else:
            return ""

    def load_to_virtuoso(self):

        sql_sentence = self._get_load_one_folder_sql_command()

        # create sql temp file
        self._create_load_data_tempfile(sql_sentence)

        isql_command = self._get_isql_load_to_virtuoso_command()

        # Run command
        os.system(isql_command)
        from subprocess import check_output

        log.info("Pushing RDF data to Virtuoso.\n")
        log.info("COMMAND: " + isql_command)
        #isql_command = "ls"
        out = check_output(isql_command, shell=True)

        log.info("RESPONSE:\n" + str(out))
        log.info("Done loading files.")

        # remove files from sink folder
        if os.path.exists(self.LDM_RDFfolder):
            os.system('rm ' + self.LDM_RDFfolder + '/* ')


    def _get_isql_load_to_virtuoso_command(self):
        #isql_command = f"isql {self.virtuosoIP}:{self.virtuosoPort} {self.virtuosoUser} {self.virtuosoPass} < {self.load_data_tempfile}"
        isql_command = f"docker exec -i {self.dockerContainerName} isql -U {self.virtuosoUser} -P {self.virtuosoPass} < {self.load_data_tempfile}"
        # isql-v -U dba -P mysecret < /load_data.sql
        return isql_command
    # Version: 06.01.3127
    # Build: Mar 4 2018

    def _get_load_one_folder_sql_command(self):
        # Examples isql*
        # isql WebDB MyID MyPWD -w < My.sql *
        #
        # Each line in My.sql must contain exactly 1 SQL command except for the
        # last line which must be blank(unless -n option specified).
        sql_sentence = f"ld_dir('{self.virtuosoRDFfolder}', '*.{self.RDFfiletype}', '{self.virtuosoGraph}');\n"
        sql_sentence += "rdf_loader_run();\n"
        sql_sentence += "exec('checkpoint');\n"
        sql_sentence += "WAIT_FOR_CHILDREN;\n"
        return sql_sentence

    def _get_load_all_folders_sql_command(self):
        sql_sentence = f"ld_dir_all('{self.virtuosoRDFfolder}', '*.{self.RDFfiletype}', '{self.virtuosoGraph}');\n"
        sql_sentence += "rdf_loader_run();\n"
        sql_sentence += "exec('checkpoint');\n"
        sql_sentence += "WAIT_FOR_CHILDREN;\n"
        return sql_sentence

    def _create_load_data_tempfile(self, sql_data):
        # delete temporal file
        if os.path.exists(self.load_data_tempfile):
            os.remove(self.load_data_tempfile)

        # write file
        with open(self.load_data_tempfile, 'w') as fp:
            fp.write(sql_data)

    def copy_Dataset_RDFfile_to_virtuoso_RDFsink_folder(self, dataset_id):

        # Create destination folder
        os.makedirs(self.LDM_RDFfolder, mode = 0o777, exist_ok=True)

        return self.rdfizer_obj.copy_Dataset_RDFfile_to_folder(dataset_id, self.LDM_RDFfolder)

    
    def create_dataset_in_LDM(self, ds_name):

        # Generate DCAT RDF nt
        dataset_dict = self.rdfizer_obj.get_LDM_local_dataset(ds_name)
        self.rdfizer_obj.convert_dataset_dict_to_DCAT(dataset_dict)
        # Delete parsed files (are generated later on demand)
        self.rdfizer_obj.delete_RDF_parsed_files_for_dataset(ds_name)

        # Insert New Dataset (local version) into graph
        res = self.insert_dataset_into_graph(ds_name)
        if not res:
            res['ERROR'] += 'ERROR INSERTING NEW DATASET FOR UPDATE.'
            return res
        else:
            return self._update_dataset_in_graph_OK(f"None. Dataset (name:{ds_name} updated in the graph.")

    def update_dataset_in_LDM(self, ds_name):

        # Generate DCAT RDF nt
        dataset_dict = self.rdfizer_obj.get_LDM_local_dataset(ds_name)
        self.rdfizer_obj.convert_dataset_dict_to_DCAT(dataset_dict)
        # Delete parsed files (are generated later on demand)
        self.rdfizer_obj.delete_RDF_parsed_files_for_dataset(ds_name)

        # Delete the Dataset from graph
        res = self.delete_dataset_from_graph(ds_name)
        if not res['OK']:
            res['ERROR'] += 'ERROR DELETING DATASET FOR UPDATE.'
            return res
        # Insert New Dataset (local version) into graph
        res = self.insert_dataset_into_graph(ds_name)
        if not res:
            res['ERROR'] += 'ERROR INSERTING NEW DATASET FOR UPDATE.'
            return res
        else:
            return self._update_dataset_in_graph_OK(f"None. Dataset (name:{ds_name} updated in the graph.")

    def get_LDM_local_organization(self, org_id):

        org_dict = self.rdfizer_obj.get_LDM_local_organization(org_id)
        org_dict = self.rdfizer_obj.preprocess_organization_dict(org_dict)
        return org_dict

    def get_LDM_local_dataset(self, ds_name):
        dataset_dict = self.rdfizer_obj.get_LDM_local_dataset(ds_name)
        return dataset_dict

    # SPARSQL INTERACTION WITH VIRTUOSO TRIPPLE STORE
    # ***********************************************
    def execute_sparql_sentence(self, sql, authorize=False):

        if authorize:
            sparql = SPARQLWrapper(f"{self.virtuosoGraph}sparql-auth", defaultGraph=self.virtuosoGraph)
            sparql.setHTTPAuth(DIGEST)
            sparql.setCredentials(self.virtuosoUser, self.virtuosoPass)
            sparql.setMethod(POST)
        else:
            sparql = SPARQLWrapper(f"{self.virtuosoGraph}sparql", defaultGraph=self.virtuosoGraph)

        sparql.setReturnFormat(JSON)

        sparql.setQuery(sql)

        results = sparql.query()

        try:
            results = sparql.query()
        except:
            log.info("ERROR EXECUTING SPARQL QUERY: "+sql)
            return {}
        #return results.response.read()
        res = results.convert()
        res["SUCCESS"] = True

        if 'results' in res and 'bindings' in res['results']:
            if not res['results']['bindings']:
                log.info("ERROR EXECUTING SPARQL QUERY: " + sql)
                return {}
        return res

    def insert_dataset_into_graph(self, ds_name):

        data = self.rdfizer_obj.get_DCAT_RDF_raw_data(ds_name)

        sql = f"INSERT " + "{" + data + "}"
        #log.info(sql)
        res = self.execute_sparql_sentence(sql, True)
        if not res:
            log.error("ERROR inserting dataset: "+ ds_name)
        return res

    def delete_dataset_from_graph(self, ds_name):

        # get dataset id
        dataset_id = self._get_dataset_id(ds_name)
        if not dataset_id:
            error_msg = f"ERROR: Deleting Dataset from Graph. Dataset name or id: {ds_name} is not valid."
            return self._delete_dataset_from_graph_error(error_msg)

        # Fix prefix and id for Endpoint disable
        if not self.ViruosoEndpointEnabled:
            aux = dataset_id.split('/')
            ds_type = aux[-2]
            dataset_id = aux[-1]
        ldm_prefix = "ldm: <" + os.environ.get('CKAN_KG_DOMAIN') + ">"

        # Delete Dataset's Resources
        sql = (f"PREFIX {ldm_prefix}\
                        PREFIX {self.PREFIX['dcat']}\
                        PREFIX {self.PREFIX['dct']}\
                        PREFIX {self.PREFIX['rdf']}\
                        PREFIX {self.PREFIX['vcard']}\
                        DELETE {{ ?s ?p ?o. \
                                  ldm:{dataset_id} ?p ?o. \
                                  ?s ?p ldm:{dataset_id}. \
                                  ?res ?p ?o. \
                                  ?s vcard:fn ?res. }} \
                        WHERE {{ {{ldm:{dataset_id} ?p ?o.}} \
                                UNION \
                                 {{?s ?p ldm:{dataset_id}.}}\
                                UNION \
                                 {{ldm:{dataset_id} dcat:distribution ?res. \
                                    ?res ?p ?o. }} \
                                UNION \
                                 {{ldm:{dataset_id} dcat:keyword ?res. \
                                    ?res ?p ?o. }} \
                                UNION \
                                {{ ?s ?p ?o. \
                                {{ SELECT (?sub AS ?s) WHERE {{ \
                                    ?sub ?p ?o. ldm:{dataset_id} ?p ?o. \
                                    FILTER isBLANK(?sub) }} \
                                    }} }} \
                                    }}")
        res = self.execute_sparql_sentence(sql, True)
        if "SUCCESS" not in res:
            error_msg = f"ERROR: Deleting Dataset's Triples from Graph. Dataset id: {dataset_id}."
            return self._delete_dataset_from_graph_error(error_msg)
        else:
            return self._delete_dataset_from_graph_OK(f"None. Triples from Dataset id: {dataset_id} deleted.")

    def delete_dataset_from_graph_old(self, ds_name):

        # get dataset id
        dataset_id = self._get_dataset_id(ds_name)
        if not dataset_id:
            error_msg = f"ERROR: Deleting Dataset from Graph. Dataset name: {ds_name} is not valid."
            return self._delete_dataset_from_graph_error(error_msg)

        # get resources from graph
        #resources_id = self._get_resources_from_graph(dataset_id)

        # Delete Resources
        # for id in resources_id:
        #     res = self.delete_resource_from_graph(id)
        #     if not res['OK']:
        #         return res
        res = self.delete_resources_from_graph(dataset_id)
        if not res['OK']:
            return res

        # Delete Dataset Properties
        res = self.delete_dataset_properties_from_graph(dataset_id)
        if not res['OK']:
            return res

        return self._delete_dataset_from_graph_OK(f"None. Dataset (id:{dataset_id} deleted from graph.")

    def create_dataset_in_graph(self, ds_name):

        # Insert New Dataset (local version) into graph
        res = self.insert_dataset_into_graph(ds_name)
        if not res:
            res['ERROR'] += 'ERROR INSERTING NEW DATASET FOR UPDATE.'
            return res
        else:
            return self._update_dataset_in_graph_OK(f"None. Dataset (name:{ds_name} updated in the graph.")

    def update_dataset_in_graph(self, ds_name):

        # Delete the Dataset from graph
        res = self.delete_dataset_from_graph(ds_name)
        if not res['OK']:
            res['ERROR'] += 'ERROR DELETING DATASET FOR UPDATE.'
            return res
        # Insert New Dataset (local version) into graph
        res = self.insert_dataset_into_graph(ds_name)
        if not res:
            res['ERROR'] += 'ERROR INSERTING NEW DATASET FOR UPDATE.'
            return res
        else:
            return self._update_dataset_in_graph_OK(f"None. Dataset (name:{ds_name} updated in the graph.")

    def insert_organization_into_graph(self, org_name):

        data = self.rdfizer_obj.get_DCAT_RDF_raw_data_org(org_name)
        log.info(data)
        sql = f"INSERT " + "{" + data + "}"
        log.info(sql)
        res = self.execute_sparql_sentence(sql, True)
        #print("\n\nSQL INSERT: ", sql)
        if not res:
            log.error("ERROR inserting dataset: "+ org_name)
        return res

    def create_organization_in_graph(self, org_id):

        # get org_dictionary
        org_dict = self.get_LDM_local_organization(org_id)
        org_dict["domain"] = os.environ.get('CKAN_SITE_URL')
        # get organization id
        org_id = self._get_organization_id_from_org_dict(org_dict)
        #print("\n\nORG URL: ", org_id)
        if not org_id:
            error_msg = f"ERROR: Updating Organization. Orgnaization name: {org_dict.get('name', 'Unknown')} is not valid."
            return self._update_organization_from_graph_error(error_msg)

        self.insert_organization_into_graph(org_dict["name"])
        return self._update_organization_from_graph_OK(f"None. Triples from Dataset id: {org_dict.get('name', 'Unknown')} deleted.")

    def update_organization_in_graph(self, org_id):

        # get org_dictionary
        org_dict = self.get_LDM_local_organization(org_id)
        # get organization id
        org_id = self._get_organization_id_from_org_dict(org_dict)
        #print("\n\nORG URL: ", org_id)
        if not org_id:
            error_msg = f"ERROR: Updating Organization. Orgnaization name: {org_dict.get('name', 'Unknown')} is not valid."
            return self._update_organization_from_graph_error(error_msg)

        # Fix prefix and id for Endpoint disable
        if not self.ViruosoEndpointEnabled:
            aux = org_id.split('/')
            org_id = aux[-1]
        ldm_prefix = "ldm: <https://research.tib.eu/ldm/>"

        # Update Organization
        sql = f"PREFIX {ldm_prefix}\
                               PREFIX {self.PREFIX['dct']}\
                               PREFIX {self.PREFIX['rdfs']}\
                               PREFIX {self.PREFIX['vcard']}\
                               DELETE {{ ldm:{org_id} dct:description ?value.\
                                         ldm:{org_id} rdfs:label ?value.\
                                         ldm:{org_id} dct:title ?value}} \
                               WHERE {{ ldm:{org_id} ?p ?value. }}"

        #print("\n\nSQL ORG:", sql)
        log.info(org_dict)
        res = self.execute_sparql_sentence(sql, True)
        if not res:
            error_msg = f"ERROR: Updating Organization's Triples from Graph. Organization name: {org_dict.get('name', 'Unknown')}."
            return self._update_organization_from_graph_error(error_msg)
        else:
            self.insert_organization_into_graph(org_dict["name"])
            return self._update_organization_from_graph_OK(f"None. Triples from Dataset id: {org_dict.get('name', 'Unknown')} deleted.")

    def dataset_should_be_included_in_graph(self, ds_dict):
        return ds_dict.get('state', 'active') == 'active' and not ds_dict.get('private', False)


    def _get_dataset_id(self, ds_name):

        dataset_dict = self.rdfizer_obj.get_LDM_local_dataset(ds_name)
        if not dataset_dict:
            return 0
        else:
            dataset_url = self.rdfizer_obj._get_dataset_url_from(dataset_dict)
            dataset_url = dataset_url.split('/')
            if dataset_url:
                if self.ViruosoEndpointEnabled:
                    return dataset_url[-1]
                else:

                    return dataset_url[-2] + '/' + dataset_url[-1]
            else:
                return 0

    def _get_organization_id_from_org_dict(self, org_dict):

        org_id = self.rdfizer_obj._get_organization_url_from_org_dict(org_dict)
        org_id = org_id.split('/')
        if self.ViruosoEndpointEnabled:
            return org_id[-1]
        else:
            return org_id[-2] + '/' + org_id[-1]

    def _delete_dataset_from_graph_error(self, msg):

        result = {"OK": False, "ERROR": ""}
        result["ERROR"] = msg
        log.error(result["ERROR"])
        return result

    def _update_organization_from_graph_error(self, msg):

        result = {"OK": False, "ERROR": ""}
        result["ERROR"] = msg
        log.error(result["ERROR"])
        return result

    def _delete_dataset_from_graph_OK(self, msg):
        return {"OK": True, "ERROR": msg}

    def _update_dataset_in_graph_OK(self, msg):
        return {"OK": True, "ERROR": msg}

    def _update_organization_from_graph_OK(self, msg):
        return {"OK": True, "ERROR": msg}

    def _get_resources_from_graph(self, ds_id):

        # get resources from graph
        sql = f"PREFIX {self.PREFIX['rdf']}\
                PREFIX {self.PREFIX['dcat']}\
                PREFIX {self.PREFIX['ldm']}\
                SELECT ?resource_id WHERE {{ldm:{ds_id} dcat:distribution ?resource_id}}"
        res = self.execute_sparql_sentence(sql)
        resources_id = []
        if 'results' in res and 'bindings' in res['results']:
            for r in res['results']['bindings']:
                resources_id.append(r['resource_id']['value'])
        return resources_id

    def delete_resources_from_graph(self, dataset_id):


        # Delete Dataset's Resources
        sql = (f"PREFIX {self.PREFIX['ldm']}\
                PREFIX {self.PREFIX['dcat']}\
                WITH <{self.virtuosoGraph}>\
                DELETE {{ ?resource ?p ?o }} \
                WHERE {{ ldm:{dataset_id} dcat:distribution ?resource. \
                ?resource ?p ?o }}")
        #print("\n\nSQL:", sql)
        res = self.execute_sparql_sentence(sql, True)
        if not res:
            error_msg = f"ERROR: Deleting Dataset's Resource from Graph. Dataset id: {dataset_id}."
            return self._delete_dataset_from_graph_error(error_msg)
        else:
            return self._delete_dataset_from_graph_OK(f"None. Resources from Dataset id: {dataset_id} deleted.")

    def delete_resource_from_graph(self, resource_id_label):

        # resource_id_label = complete label en graph. Ex. http://localhost:8890/resource-0ce74f0d-bf35-4627-9f69-92d5c1150dff

        aux = resource_id_label.split('/')
        prefix = '/'.join(aux[:-1])+'/'
        r_id = aux[-1]
        sql = (f"PREFIX ldm: <{prefix}>\
                        WITH <{self.virtuosoGraph}>\
                        DELETE {{ ldm:{r_id} ?p ?o }} \
                        WHERE {{ ldm:{r_id} ?p ?o . }}")

        res = self.execute_sparql_sentence(sql, True)
        if not res:
            error_msg = f"ERROR: Deleting Dataset's Resource from Graph. Resource id: {r_id} is not valid."
            return self._delete_dataset_from_graph_error(error_msg)
        else:
            return self._delete_dataset_from_graph_OK(f"None. Resource id: {r_id} deleted.")

    def delete_dataset_properties_from_graph(self, dataset_id):

        # Delete Dataset Properties - dataset as subject
        sql = (f"PREFIX {self.PREFIX['ldm']}\
                        WITH <{self.virtuosoGraph}>\
                        DELETE {{ ldm:{dataset_id} ?p ?o }} \
                        WHERE {{ ldm:{dataset_id} ?p ?o . }}")
        res = self.execute_sparql_sentence(sql, True)
        if not res:
            error_msg = f"ERROR: Deleting Dataset's Properties from Graph(step-1). Dataset id: {dataset_id}."
            return self._delete_dataset_from_graph_error(error_msg)

        # Delete Dataset Properties - dataset as object
        sql = (f"PREFIX {self.PREFIX['ldm']}\
                        WITH <{self.virtuosoGraph}>\
                        DELETE {{ ?s ?p ldm:{dataset_id} }} \
                        WHERE {{ ?s ?p ldm:{dataset_id} . }}")
        res = self.execute_sparql_sentence(sql, True)
        if not res:
            error_msg = f"ERROR: Deleting Dataset's Properties from Graph(step-2). Dataset id: {dataset_id}."
            return self._delete_dataset_from_graph_error(error_msg)
        else:
            return self._delete_dataset_from_graph_OK(f"None. Dataset (id:{dataset_id}) properties deleted.")

