from setuptools import setup, find_packages

setup(
    name='''ckanext-Code2NB''',
    version='0.1',
    description='''CKAN plugin to convert code files to Jupyter Notebooks''',
    # Author details
    author='''Ariam Rivas''',
    author_email='''ariam.rivas@tib.eu''',
    packages=find_packages(exclude=['contrib', 'docs', 'tests*']),
    namespace_packages=['ckanext'],
    install_requires=[],
    entry_points='''
        [ckan.plugins]
        Code2NB=ckanext.Code2NB.plugin:Code2NBPlugin
    ''',
)
