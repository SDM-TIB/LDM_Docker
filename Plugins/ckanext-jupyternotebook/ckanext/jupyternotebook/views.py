import os

from ckan.common import request, config
from ckan.plugins import toolkit
from ckanext.jupyternotebook.controller import JupyterHubController
from flask import Blueprint, jsonify, request

admin_bp = Blueprint('jupyternotebook_admin', __name__ + '_admin', url_prefix='/ckan-admin')

jupyterhub_controller = JupyterHubController()
admin_bp.add_url_rule('/jupyternotebook', view_func=jupyterhub_controller.admin, methods=['GET', 'POST'])


def get_blueprints():
    return [admin_bp]
