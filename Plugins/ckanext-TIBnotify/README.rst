.. You should enable this project on travis-ci.org and coveralls.io to make
   these badges work. The necessary Travis and Coverage config files have been
   generated for you.

.. image:: https://travis-ci.org/TIB/ckanext-TIBnotify.svg?branch=master
    :target: https://travis-ci.org/TIB/ckanext-TIBnotify

.. image:: https://coveralls.io/repos/TIB/ckanext-TIBnotify/badge.svg
  :target: https://coveralls.io/r/TIB/ckanext-TIBnotify

.. image:: https://img.shields.io/pypi/v/ckanext-TIBnotify.svg
    :target: https://pypi.org/project/ckanext-TIBnotify/
    :alt: Latest Version

.. image:: https://img.shields.io/pypi/pyversions/ckanext-TIBnotify.svg
    :target: https://pypi.org/project/ckanext-TIBnotify/
    :alt: Supported Python versions

.. image:: https://img.shields.io/pypi/status/ckanext-TIBnotify.svg
    :target: https://pypi.org/project/ckanext-TIBnotify/
    :alt: Development Status

.. image:: https://img.shields.io/pypi/l/ckanext-TIBnotify.svg
    :target: https://pypi.org/project/ckanext-TIBnotify/
    :alt: License

=============
ckanext-TIBnotify
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

To install ckanext-TIBnotify:

1. Activate your CKAN virtual environment, for example::

     . /usr/lib/ckan/default/bin/activate

2. Install the ckanext-TIBnotify Python package into your virtual environment::

     pip install ckanext-TIBnotify

3. Add ``TIBnotify`` to the ``ckan.plugins`` setting in your CKAN
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
   ckanext.tibnotify.some_setting = some_default_value


----------------------
Developer installation
----------------------

To install ckanext-TIBnotify for development, activate your CKAN virtualenv and
do::

    git clone https://github.com/TIB/ckanext-TIBnotify.git
    cd ckanext-TIBnotify
    python setup.py develop
    pip install -r dev-requirements.txt


-----
Tests
-----

To run the tests, do::

    pytest --ckan-ini=test.ini

To run the tests and produce a coverage report, first make sure you have
``pytest-cov`` installed in your virtualenv (``pip install pytest-cov``) then run::

    pytest --ckan-ini=test.ini  --cov=ckanext.tibnotify


----------------------------------------
Releasing a new version of ckanext-TIBnotify
----------------------------------------

ckanext-TIBnotify should be available on PyPI as https://pypi.org/project/ckanext-TIBnotify.
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
