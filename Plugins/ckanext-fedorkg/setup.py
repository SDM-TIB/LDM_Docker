# -*- coding: utf-8 -*-
from setuptools import setup

setup(
    # To provide executable scripts, use entry points in preference to the
    # "scripts" keyword. Entry points provide cross-platform support and allow
    # pip to create the appropriate form of executable for the target platform.
    entry_points='''
        [ckan.plugins]
        fedorkg=ckanext.fedorkg.plugin:FedORKG

        [babel.extractors]
        ckan=ckan.lib.extract:extract_ckan
    ''',

    # If you are changing from the default layout of your extension, you may
    # have to change the message extractors, you can read more about babel
    # message extraction at
    # http://babel.pocoo.org/docs/messages/#extraction-method-mapping-and-configuration
    message_extractors={
        'ckanext': [
            ('**.py', 'python', None),
            ('**.js', 'javascript', None),
            ('**/templates/**.jinja2', 'ckan', None),
            ('**/templates/**.html', 'ckan', None),
        ],
    }
)
