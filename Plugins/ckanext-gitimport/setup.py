from setuptools import setup

setup(
    entry_points='''
    [ckan.plugins]
    gitImport=ckanext.gitimport.plugin:GitimportPlugin
    ''',

    message_extractors={
        'ckanext': [
            ('**.py', 'python', None),
            ('**.js', 'javascript', None),
            ('**/templates/**.html', 'ckan', None),
        ],
    }
)
