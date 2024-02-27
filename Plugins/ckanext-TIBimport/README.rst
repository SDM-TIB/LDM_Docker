.. You should enable this project on travis-ci.org and coveralls.io to make
   these badges work. The necessary Travis and Coverage config files have been
   generated for you.

.. image:: https://travis-ci.org/Rmbruno11/ckanext-TIBimport.svg?branch=master
    :target: https://travis-ci.org/Rmbruno11/ckanext-TIBimport

.. image:: https://coveralls.io/repos/Rmbruno11/ckanext-TIBimport/badge.svg
  :target: https://coveralls.io/r/Rmbruno11/ckanext-TIBimport

.. image:: https://img.shields.io/pypi/v/ckanext-TIBimport.svg
    :target: https://pypi.org/project/ckanext-TIBimport/
    :alt: Latest Version

.. image:: https://img.shields.io/pypi/pyversions/ckanext-TIBimport.svg
    :target: https://pypi.org/project/ckanext-TIBimport/
    :alt: Supported Python versions

.. image:: https://img.shields.io/pypi/status/ckanext-TIBimport.svg
    :target: https://pypi.org/project/ckanext-TIBimport/
    :alt: Development Status

.. image:: https://img.shields.io/pypi/l/ckanext-TIBimport.svg
    :target: https://pypi.org/project/ckanext-TIBimport/
    :alt: License

=============
ckanext-TIBimport
=============

.. Put a description of your extension here:
   What does it do? What features does it have?
   Consider including some screenshots or embedding a video!


------------
Requirements
------------

For example, you might want to mention here which versions of CKAN this
extension works with.


------------
Installation
------------

.. Add any additional install steps to the list below.
   For example installing any non-Python dependencies or adding any required
   config settings.

To install ckanext-TIBimport:

1. Activate your CKAN virtual environment, for example::

     . /usr/lib/ckan/default/bin/activate

2. Install the ckanext-TIBimport Python package into your virtual environment::

     pip install ckanext-TIBimport

3. Add ``TIBimport`` to the ``ckan.plugins`` setting in your CKAN
   config file (by default the config file is located at
   ``/etc/ckan/default/ckan.ini``).

4. Restart CKAN. For example if you've deployed CKAN with Apache on Ubuntu::

     sudo service apache2 reload


---------------
Config settings
---------------

You can set in CKAN's config file (ckan.ini) the following values:


     tibimport.log_file_path = '/home/johndoe/logs/'

The path should end in "/". The default value is:
'/usr/lib/ckan/default/src/ckanext-TIBimport/ckanext/tibimport/logs/'

     tibimport.show_vdatasets_virtual_ribbon = true

The value enables and disables the 'virtual' ribbon in virtual dataset's list pages.
The default value is: false

     tibimport.show_vdatasets_virtual_source_ribbon = true

The value enables and disables the 'source' ribbon in virtual dataset's list pages.
The default value is: false


.. Document any optional config settings here. For example::

.. # The minimum number of hours to wait before re-checking a resource
   # (optional, default: 24).
   ckanext.tibimport.some_setting = some_default_value


----------------------
Developer installation
----------------------

To install ckanext-TIBimport for development, activate your CKAN virtualenv and
do::

    git clone https://github.com/Rmbruno11/ckanext-TIBimport.git
    cd ckanext-TIBimport
    python setup.py develop
    pip install -r dev-requirements.txt


-----
Tests
-----

To run the tests, do::

    pytest --ckan-ini=test.ini

To run the tests and produce a coverage report, first make sure you have
``pytest-cov`` installed in your virtualenv (``pip install pytest-cov``) then run::

    pytest --ckan-ini=test.ini  --cov=ckanext.tibimport


----------------------------------------
Releasing a new version of ckanext-TIBimport
----------------------------------------

ckanext-TIBimport should be available on PyPI as https://pypi.org/project/ckanext-TIBimport.
To publish a new version to PyPI follow these steps:

1. Update the version number in the ``setup.py`` file.
   See `PEP 440 <http://legacy.python.org/dev/peps/pep-0440/#public-version-identifiers>`_
   for how to choose version numbers.

2. Make sure you have the latest version of necessary packages::

    pip install --upgrade setuptools wheel twine

3. Create a source and binary distributions of the new version::

       python setup.py sdist bdist_wheel && twine check dist/*

   Fix any errors you get.

4. Upload the source distribution to PyPI::

       twine upload dist/*

5. Commit any outstanding changes::

       git commit -a
       git push

6. Tag the new release of the project on GitHub with the version number from
   the ``setup.py`` file. For example if the version number in ``setup.py`` is
   0.0.1 then do::

       git tag 0.0.1
       git push --tags
