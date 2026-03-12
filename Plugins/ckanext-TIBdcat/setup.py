from setuptools import setup, find_packages

setup(
    name='TIBdcat',
    version='0.0.1',
    description="create different file formats to export",
    classifiers=[
        # How mature is this project? Common values are
        # 3 - Alpha
        # 4 - Beta
        # 5 - Production/Stable
        'Development Status :: 3 - Alpha',

        # Pick your license as you wish (should match "license" above)
        'License :: OSI Approved :: GNU Affero General Public License v3 or'\
        'later (AGPLv3+)',

        # Specify the Python versions you support here. In particular, ensure
        # that you indicate whether you support Python 2, Python 3 or both.
        'Programming Language :: Python :: 3',
    ],
    keywords='',
    author='Wolfgang Schröder',
    author_email='wolfgang.schroeder@stud.uni-hannover.de',
    url='',
    license='AGPL',
    packages=find_packages(exclude=['contrib', 'docs', 'tests*']),
    include_package_data=True,
    zip_safe=False,
    install_requires=[],
    entry_points='''
        [ckan.plugins]
        TIBdcat = ckanext.TIBdcat.plugin:TIBdcatPlugin
    ''',
)
