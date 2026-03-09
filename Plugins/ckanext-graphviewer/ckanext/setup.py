from setuptools import setup, find_packages

setup(
    name='ckanext-graphviewer',
    version='0.1',
    description="Rust WASM RDF Graph Visualizer for CKAN",
    classifiers=[],
    keywords='',
    author='Wolfgang Schröder',
    author_email='wolfgang.schroeder@stud.uni-hannover.de ',
    url='',
    license='AGPL',
    packages=find_packages(exclude=['ez_setup', 'examples', 'tests']),
    namespace_packages=['ckanext'],
    include_package_data=True,
    zip_safe=False,
    install_requires=[],
    entry_points='''
        [ckan.plugins]
        graph_viewer = ckanext.graphviewer.plugin:GraphViewerPlugin
    ''',
)
