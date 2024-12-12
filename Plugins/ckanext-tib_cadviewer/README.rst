.. You should enable this project on travis-ci.org and coveralls.io to make
   these badges work. The necessary Travis and Coverage config files have been
   generated for you.

.. image:: https://travis-ci.org/TIB/ckanext-tib_cadviewer.svg?branch=master
    :target: https://travis-ci.org/TIB/ckanext-tib_cadviewer

.. image:: https://coveralls.io/repos/TIB/ckanext-tib_cadviewer/badge.svg
  :target: https://coveralls.io/r/TIB/ckanext-tib_cadviewer

.. image:: https://img.shields.io/pypi/v/ckanext-tib_cadviewer.svg
    :target: https://pypi.org/project/ckanext-tib_cadviewer/
    :alt: Latest Version

.. image:: https://img.shields.io/pypi/pyversions/ckanext-tib_cadviewer.svg
    :target: https://pypi.org/project/ckanext-tib_cadviewer/
    :alt: Supported Python versions

.. image:: https://img.shields.io/pypi/status/ckanext-tib_cadviewer.svg
    :target: https://pypi.org/project/ckanext-tib_cadviewer/
    :alt: Development Status

.. image:: https://img.shields.io/pypi/l/ckanext-tib_cadviewer.svg
    :target: https://pypi.org/project/ckanext-tib_cadviewer/
    :alt: License

=============
ckanext-tib_cadviewer
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

To install ckanext-tib_cadviewer:

1. Activate your CKAN virtual environment, for example::

     . /usr/lib/ckan/default/bin/activate

2. Install the ckanext-tib_cadviewer Python package into your virtual environment::

     pip install ckanext-tib_cadviewer

3. Add ``tib_cadviewer`` to the ``ckan.plugins`` setting in your CKAN
   config file (by default the config file is located at
   ``/etc/ckan/default/ckan.ini``).

4. Restart CKAN. For example if you've deployed CKAN with Apache on Ubuntu::

     sudo service apache2 reload


---------------
Config settings
---------------

None at present

.. Document any optional config settings here. For example::

.. # The minimum number of hours to wait before re-checking a resource
   # (optional, default: 24).
   ckanext.tib_cadviewer.some_setting = some_default_value


----------------------
Developer installation
----------------------

To install ckanext-tib_cadviewer for development, activate your CKAN virtualenv and
do::

    git clone https://github.com/TIB/ckanext-tib_cadviewer.git
    cd ckanext-tib_cadviewer
    python setup.py develop
    pip install -r dev-requirements.txt


-----
Tests
-----

To run the tests, do::

    pytest --ckan-ini=test.ini

To run the tests and produce a coverage report, first make sure you have
``pytest-cov`` installed in your virtualenv (``pip install pytest-cov``) then run::

    pytest --ckan-ini=test.ini  --cov=ckanext.tib_cadviewer


----------------------------------------
Releasing a new version of ckanext-tib_cadviewer
----------------------------------------

ckanext-tib_cadviewer should be available on PyPI as https://pypi.org/project/ckanext-tib_cadviewer.
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
