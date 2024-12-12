
import os

import requests
from DeTrusty import __version__ as detrusty_version
from DeTrusty import run_query
from ckan.common import request, config
from ckan.plugins import toolkit
from ckanext.fedorkg import __version__ as fedorkg_version
from ckanext.fedorkg.controller import FedORKGController, DEFAULT_QUERY_KEY, DEFAULT_QUERY_NAME_KEY, QUERY_TIMEOUT, DETRUSTY_CONFIG
from ckanext.fedorkg import FEDORKG_PATH
from flask import Blueprint, jsonify, request

fedorkg = Blueprint('fedorkg', __name__, url_prefix='/fedorkg')
admin_bp = Blueprint('fedorkg_admin', __name__ + '_admin', url_prefix='/ckan-admin')


def init_prompt():
    with open(os.path.join(FEDORKG_PATH, 'prompt.txt'), 'r', encoding='utf-8') as prompt_file:
        return prompt_file.read()


prompt = init_prompt()


def query_editor():
    if toolkit.check_ckan_version(min_version='2.10'):
        margin = '-0.75rem'
    else:
        margin = '-15px'
    return toolkit.render('sparql.jinja2',
                          extra_vars={
                              'detrusty_version': detrusty_version,
                              'fedorkg_version': fedorkg_version,
                              'default_query': config.get(DEFAULT_QUERY_KEY, ''),
                              'default_query_name': config.get(DEFAULT_QUERY_NAME_KEY, ''),
                              'margin': margin,
                              'timeout': config.get(QUERY_TIMEOUT)
                          })


def sparql():
    query = request.values.get('query', None)
    if query is None:
        return jsonify({"result": [], "error": "No query passed."})
    yasqe = request.values.get('yasqe', False)
    return jsonify(
        run_query(
            query=query,
            config=DETRUSTY_CONFIG,
            join_stars_locally=False,
            yasqe=yasqe,
            timeout=int(config.get(QUERY_TIMEOUT))
        )
    )


def llm():
    question = request.values.get('question', None)
    if question is None:
        raise ValueError('ERROR: No question passed.')
    elif len(question) > 128:
        raise ValueError('ERROR: Your question exceeds 128 characters.')
    else:
        api_key = os.environ.get('OPENAI_API_KEY', None)
        if api_key is None:
            raise ValueError('ERROR: Missing OpenAI API key.')

        headers = {
            'Content-Type': 'application/json',
            'Authorization': f'Bearer {api_key}'
        }

        data = {
            "model": "o1-mini",
            "messages": [
                {"role": "user", "content": f"{prompt}\n{question}"}
            ]
        }

        try:
            response = requests.post('https://api.openai.com/v1/chat/completions', headers=headers, json=data)
            response.raise_for_status()  # Raise an error for bad status codes

            content = response.json()['choices'][0]['message']['content']
            return content

        except requests.exceptions.HTTPError as http_err:
            raise RuntimeError(f"HTTP error occurred: {http_err}")
        except Exception as err:
            raise RuntimeError(f"An error occurred: {err}")


fedorkg.add_url_rule('/sparql', view_func=query_editor, methods=['GET'])
fedorkg.add_url_rule('/sparql', view_func=sparql, methods=['POST'])
fedorkg.add_url_rule('/llm', view_func=llm, methods=['POST'])
admin_bp.add_url_rule('/fedorkg', view_func=FedORKGController.admin, methods=['GET', 'POST'])


def get_blueprints():
    return [fedorkg, admin_bp]
