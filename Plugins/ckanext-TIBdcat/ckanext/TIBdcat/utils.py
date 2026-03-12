from ckan import model
import ckan.plugins.toolkit as toolkit
import flask
import io, os
from rdflib import Graph

CONTENT_TYPES = {
    'rdf': 'application/rdf+xml',
    'xml': 'application/rdf+xml',
    'n3': 'text/n3',
    'ttl': 'text/turtle',
    'jsonld': 'application/ld+json',
}

def read_content(_id):
    with open(os.environ.get('CKAN_STORAGE_PATH') + "/rdf_metadata/" + _id + ".nt", "r") as file:
        file_content = file.read()
        return file_content

def download_dataset_rdf (_id):
    file_content = read_content(_id)

    g = Graph()
    g.parse(data=file_content, format="n3")
    ttl_data = g.serialize(format="xml")

    file_buffer = io.BytesIO(ttl_data.encode("utf-8"))
    file_buffer.seek(0)

    return flask.send_file(
        file_buffer,
        mimetype=CONTENT_TYPES.get("rdf", "text/plain"),
        as_attachment=False,
        attachment_filename=f"{_id}.rdf"
    )

def download_dataset_xml (_id):
    file_content = read_content(_id)

    g = Graph()
    g.parse(data=file_content, format="n3")
    ttl_data = g.serialize(format="xml")

    file_buffer = io.BytesIO(ttl_data.encode("utf-8"))
    file_buffer.seek(0)

    return flask.send_file(
        file_buffer,
        mimetype=CONTENT_TYPES.get("xml", "text/plain"),
        as_attachment=False,
        attachment_filename=f"{_id}.xml"
    )

def download_dataset_n3 (_id):
    file_content = read_content(_id)

    # convert to bytes
    file_buffer = io.BytesIO(file_content.encode("utf-8"))
    file_buffer.seek(0)

    return flask.send_file(
        file_buffer,
        mimetype=CONTENT_TYPES.get("n3", "text/plain"),
        as_attachment=False,
        attachment_filename=f"{_id}.n3"
    )

def download_dataset_ttl (_id):
    file_content = read_content(_id)

    g = Graph()
    g.parse(data=file_content, format="n3")
    ttl_data = g.serialize(format="ttl")

    file_buffer = io.BytesIO(ttl_data.encode("utf-8"))
    file_buffer.seek(0)

    return flask.send_file(
        file_buffer,
        mimetype=CONTENT_TYPES.get("ttl", "text/plain"),
        as_attachment=False,
        attachment_filename=f"{_id}.ttl"
    )

def download_dataset_jsonld (_id):
    file_content = read_content(_id)

    g = Graph()
    g.parse(data=file_content, format="n3")
    ttl_data = g.serialize(format="json-ld")

    file_buffer = io.BytesIO(ttl_data.encode("utf-8"))
    file_buffer.seek(0)

    return flask.send_file(
        file_buffer,
        mimetype=CONTENT_TYPES.get("jsonld", "text/plain"),
        as_attachment=False,
        attachment_filename=f"{_id}.jsonld"
    )
