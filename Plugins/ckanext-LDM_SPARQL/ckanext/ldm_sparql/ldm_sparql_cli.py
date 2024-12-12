import click
# from ckan import model
from ckan.model import Session
from ckan.plugins import toolkit

from ckanext.ldm_sparql.RDFizer_Util import RDFizer_Util
from ckanext.ldm_sparql.Virtuoso_Util import Virtuoso_Util

def get_commands():
    return [ldmsparql]


@click.group()
def ldmsparql():
    pass


@ldmsparql.command(name='generate-dcat-rdf')
@click.option('-d', '--dataset_id', 'dataset_ids', multiple=True, help='Dataset id(s)/name(s) to generate DCAT files')
@click.option('-s', '--start_at', 'start_at', multiple=False, help='Number of Dataset (position in the list starting at 0) set as starting point to process and generate DCAT files')
def generate_dcat_rdf(dataset_ids, start_at):
    # USAGE: ldmsparql generate-dcat-rdf
    # ===========================
    # Options:
    # - d datasetName1 -d datasetName2
    #
    # Ex: ckan -c /etc/ckan/default/ckan.ini ldmsparql generate-dcat-rdf -d example-cad-2 -d s2
    # --------------------------------------------------------------------------------------
    # Options:
    # Without -d process all
    #
    # Ex: ckan -c /etc/ckan/default/ckan.ini ldmsparql generate-dcat-rdf
    # --------------------------------------------------------------------------------------
    # Options:
    # - s Number
    # start processing in 'Number'of datasets in the list
    #
    # Ex: ckan -c /etc/ckan/default/ckan.ini ldmsparql generate-dcat-rdf -s 10"
    #

    obj = RDFizer_Util()

    if start_at is None:
        start_at = 0
    else:
        start_at = int(start_at)
    print("IDS:", dataset_ids)
    if not dataset_ids:
        # Process all
        dataset_list = obj.get_LDM_local_datasets_list()
    else:
        # Process list of ids
        dataset_list = dataset_ids

    res = ''
    for ds_id in dataset_list[start_at:]:
        dataset_dict = obj.get_LDM_local_dataset(ds_id)
        obj.convert_dataset_dict_to_DCAT(dataset_dict)
        res += 'File: ' + obj.RDFizer_output_folder + '/' + ds_id + ".nt created.\n"
    if res:
        click.secho(res, fg='green')
    else:
        click.secho('ERROR: No file was created.', fg='red')


@ldmsparql.command(name='push-dcat-rdf-to-virtuoso')
@click.option('-d', '--dataset_id', 'dataset_ids', multiple=True, help='Dataset id(s)/name(s) to push')
def push_dcat_rdf_to_virtuoso(dataset_ids):
    # USAGE: ldmsparql push-dcat-rdf-to-virtuoso
    # ===========================
    # Options:
    # - d datasetName1 -d datasetName2
    #
    # Ex: ckan -c /etc/ckan/default/ckan.ini ldmsparql push-dcat-rdf-to-virtuoso -d example-cad-2 -d s2
    # --------------------------------------------------------------------------------------
    # Options:
    # Without -d process all files in exchange folder
    #
    # Ex: ckan -c /etc/ckan/default/ckan.ini ldmsparql push-dcat-rdf-to-virtuoso
    # --------------------------------------------------------------------------------------
    #

    rdfizer_obj = RDFizer_Util()
    virtuoso_obj = Virtuoso_Util()

    print("IDS:", dataset_ids)
    dataset_list = []

    if not dataset_ids:
        # Process all
        dataset_list = rdfizer_obj.get_LDM_local_datasets_list()
    else:
        # Process list of ids
        dataset_list = dataset_ids

    res = ''
    for ds_id in dataset_list:
        res = virtuoso_obj.copy_Dataset_RDFfile_to_virtuoso_RDFsink_folder(ds_id)
        if "ERROR" in res:
            click.secho(res, fg='red')
        else:
            click.secho(res, fg='green')

    # push data to virtuoso
    virtuoso_obj.load_to_virtuoso()

    click.secho("Done loading files.", fg='green')

@ldmsparql.command(name='push-dcat-rdf-to-virtuoso-remote')
@click.option('-d', '--dataset_id', 'dataset_ids', multiple=True, help='Dataset id(s)/name(s) to push')
def push_dcat_rdf_to_virtuoso_remote(dataset_ids):
    # USAGE: ldmsparql push-dcat-rdf-to-virtuoso-remote
    # ===========================
    # Options:
    # - d datasetName1 -d datasetName2
    #
    # Ex: ckan -c /etc/ckan/default/ckan.ini ldmsparql push-dcat-rdf-to-virtuoso-remote -d example-cad-2 -d s2
    # --------------------------------------------------------------------------------------
    # Options:
    # Without -d process all files
    #
    # Ex: ckan -c /etc/ckan/default/ckan.ini ldmsparql push-dcat-rdf-to-virtuoso-remote
    # --------------------------------------------------------------------------------------
    #

    rdfizer_obj = RDFizer_Util()
    virtuoso_obj = Virtuoso_Util()

    print("IDS:", dataset_ids)
    dataset_list = []

    if not dataset_ids:
        # Process all
        dataset_list = rdfizer_obj.get_LDM_local_datasets_list()
    else:
        # Process list of ids
        dataset_list = dataset_ids

    ds_ok = 0
    ds_error = 0
    ds_list = ""
    ds_error_list = ""
    for ds_id in dataset_list:
        # Check dataset exists
        ds_dict = virtuoso_obj.get_LDM_local_dataset(ds_id)

        if ds_dict:
            ds_ok = ds_ok+1
            ds_list += ds_id + "\n"
            # Generate DCAT RDF nt
            virtuoso_obj.update_dataset_in_LDM(ds_id)

            # check if dataset is active and public and PUSH DCAT RDF to Virtuoso
            # Is this active and public?
            if virtuoso_obj.dataset_should_be_included_in_graph(ds_dict):
                virtuoso_obj.update_dataset_in_graph(ds_id)
            click.secho("Processed Dataset with id: " + ds_id, fg='green')
        else:
            ds_error = ds_error+1
            ds_error_list += ds_id + "\n"
            click.secho("ERROR: Dataset with id " + ds_id + "Not Found", fg='red')

    click.secho("Done pushing Datasets to KG.", fg='green')
    click.secho("Pocessed: "+str(ds_ok), fg='green')
    click.secho("Pocessed ids:\n"+ds_list, fg='green')
    click.secho("Errors: "+str(ds_error), fg='red')
    click.secho("Errors ids:\n"+ds_error_list, fg='red')


# @doi.command(name='update-doi')
# @click.option('-p', '--package_id', 'package_ids', multiple=True, help='Package id(s) to update')
# def update_doi(package_ids):
#     '''
#     Update either all DOIs in the system or the ones associated with the given packages.
#     '''
#     if not package_ids:
#         dois_to_update = Session.query(DOI).all()
#     else:
#         dois_to_update = list(filter(None, map(DOIQuery.read_package, package_ids)))
#
#     if len(dois_to_update) == 0:
#         click.secho('No DOIs found to update', fg='green')
#         return
#
#     for record in dois_to_update:
#         pkg_dict = toolkit.get_action('package_show')({}, {
#             'id': record.package_id
#         })
#         title = pkg_dict.get('title', record.package_id)
#
#         if record.published is None:
#             click.secho(f'"{title}" does not have a published DOI; ignoring', fg='yellow')
#             continue
#         if pkg_dict.get('state', 'active') != 'active' or pkg_dict.get('private', False):
#             click.secho(f'"{title}" is inactive or private; ignoring', fg='yellow')
#             continue
#
#         metadata_dict = build_metadata_dict(pkg_dict)
#         xml_dict = build_xml_dict(metadata_dict)
#
#         client = DataciteClient()
#
#         same = client.check_for_update(record.identifier, xml_dict)
#         if not same:
#             try:
#                 client.set_metadata(record.identifier, xml_dict)
#                 click.secho(f'Updated "{title}"', fg='green')
#             except DataCiteError as e:
#                 click.secho(f'Error while updating "{title}" (DOI {record.identifier}): {e})',
#                             fg='red')
#         else:
#             click.secho(f'"{title}" is already up to date', fg='green')
