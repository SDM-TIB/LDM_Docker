import ckan.plugins as plugins
import ckan.plugins.toolkit as toolkit
from ckanext.ldm_sparql import ldm_sparql_cli
from ckanext.ldm_sparql.RDFizer_Util import RDFizer_Util
from ckanext.ldm_sparql.Virtuoso_Util import Virtuoso_Util
from ckan.model.group import Group
from ckan.plugins.interfaces import IDomainObjectModification

import logging
log = logging.getLogger(__name__)
# HELPERS
# *******
def get_virtuoso_endpoint_URL():
    virtuoso_util = Virtuoso_Util()
    return virtuoso_util.get_virtuoso_endpoint_URL()

def get_detrusty_endpoint_URL():
    virtuoso_util = Virtuoso_Util()
    return virtuoso_util.get_detrusty_endpoint_URL()

def get_pubby_URL_for_dataset(ds_dict):
    virtuoso_util = Virtuoso_Util()
    return virtuoso_util.get_pubby_URL_for_dataset(ds_dict)


# ***************



class LdmSparqlPlugin(plugins.SingletonPlugin):
    plugins.implements(plugins.IConfigurer)
    plugins.implements(plugins.IClick)
    plugins.implements(plugins.IPackageController, inherit=True)
    plugins.implements(plugins.IOrganizationController, inherit=True)
    plugins.implements(plugins.ITemplateHelpers)

    ## IClick
    def get_commands(self):
        return ldm_sparql_cli.get_commands()

    # IConfigurer
    def update_config(self, config_):
        toolkit.add_template_directory(config_, 'templates')
        toolkit.add_public_directory(config_, 'public')
        toolkit.add_resource('fanstatic',
            'ldm_sparql')

    ## IPackageController
    def after_create(self, context, pkg_dict):
        virtuoso_util = Virtuoso_Util()
        dataset_name = pkg_dict['name']

        # check if dataset is active and public and PUSH DCAT RDF to Virtuoso
        # Is this active and public?
        if virtuoso_util.dataset_should_be_included_in_graph(pkg_dict):
            dataset_name = pkg_dict['id']
            virtuoso_util.create_dataset_in_LDM(dataset_name)

    ## IPackageController
    def after_update(self, context, pkg_dict):
        '''Dataset has been created/updated. Check status of the dataset to determine if we should
        publish DOI to datacite network.
        (Note that the create method will return a dataset domain object, which may not include all fields)
        '''

        # Generate DCAT RDF nt
        virtuoso_util = Virtuoso_Util()
        dataset_name = pkg_dict['name']

        # check if dataset is active and public and PUSH DCAT RDF to Virtuoso
        # Is this active and public?
        if virtuoso_util.dataset_should_be_included_in_graph(pkg_dict):
            dataset_name = pkg_dict['id']
            virtuoso_util.update_dataset_in_LDM(dataset_name)

        return pkg_dict

    ## IOrganizationController
    def edit(self, org):
        # This is called even in Dataset change and in that case
        # the organization metadata can't be changed
        try:
            organization = toolkit.get_action('organization_show')(data_dict={'id': org.id})
            virtuoso_util = Virtuoso_Util()
            virtuoso_util.update_organization_in_graph(org.id)
        except toolkit.ObjectNotFound:
            pass

    def create(self, org):

        # This is called even in Dataset change and in that case
        # the organization metadata can't be changed
        try:
            organization = toolkit.get_action('organization_show')(data_dict={'id': org.id})
            virtuoso_util = Virtuoso_Util()
            virtuoso_util.create_organization_in_graph(org.id)
        except toolkit.ObjectNotFound:
            pass

    def get_helpers(self):
        '''Register the show_object_icon_in_package_item() function above as a template
        helper function.

        '''
        # Template helper function names should begin with the name of the
        # extension they belong to, to avoid clashing with functions from
        # other extensions.
        return {'ldmsparql_get_virtuoso_endpoint_url': get_virtuoso_endpoint_URL,
                'ldmsparql_get_detrusty_endpoint_url': get_detrusty_endpoint_URL,
                'ldmsparql_get_pubby_URL_for_dataset': get_pubby_URL_for_dataset,
                }