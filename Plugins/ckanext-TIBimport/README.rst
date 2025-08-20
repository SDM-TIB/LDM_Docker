=============
ckanext-TIBimport
=============

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

Overview
--------

**ckanext-TIBimport** is a comprehensive CKAN extension that enables seamless integration and automated import of research datasets from multiple academic and scientific data repositories. This plugin facilitates the aggregation of research data from various sources into a unified CKAN-based data management system.

Key Features
------------

* **Multi-Repository Integration**: Supports data import from multiple research repositories including:
  
  * **LUH** (Leibniz University Hannover) - CKAN API integration
  * **Leuphana** University Lüneburg - OAI-PMH + DataCite hybrid approach
  * **Göttingen** Research Online - Dataverse API integration
  * **OSNADATA** (University of Osnabrück) - OAI-PMH DataCite
  * **LEOPARD** (TU Braunschweig) - OAI-PMH with research data filtering
  * **RADAR** - Research data repository
  * **PANGAEA** - Earth & Environmental Science data repository (with topic-based filtering)

* **Automated Import Workflows**: Scheduled and on-demand dataset imports with comprehensive logging and error handling

* **Flexible Parser Profiles**: Modular architecture with specialized parser profiles for each repository type

* **Background Job Processing**: Utilizes CKAN's background job system for efficient large-scale data imports

* **Virtual Dataset Management**: Support for virtual datasets with configurable ribbon displays

* **Notification System**: Integration with TIBnotify plugin for import status notifications

* **Comprehensive Logging**: Detailed import summaries and error tracking

Technical Architecture
----------------------

The plugin implements a modular parser-based architecture where each supported repository has its own specialized parser profile. The system supports various data exchange protocols including:

* OAI-PMH (Open Archives Initiative Protocol for Metadata Harvesting)
* DataCite API
* Dataverse API
* Direct CKAN API integration

Documentation
-------------

📚 **Complete Documentation**: `documentation/README.md <documentation/README.md>`_

The documentation directory contains comprehensive guides covering:

* **System Documentation** - Technical specifications, architecture, and API details
* **User Documentation** - User guides and operational procedures  
* **Lower Saxony Repositories Documentation** - Specialized documentation for academic repository integrations

Requirements
------------

* CKAN 2.9+
* Python 3.6+
* Required Python packages (see requirements.txt)

Installation
------------

1. Activate your CKAN virtual environment::

     . /usr/lib/ckan/default/bin/activate

2. Install the ckanext-TIBimport Python package::

     pip install ckanext-TIBimport

3. Add ``TIBimport`` to the ``ckan.plugins`` setting in your CKAN config file::

     ckan.plugins = ... TIBimport

4. Restart CKAN::

     sudo service apache2 reload

Configuration
-------------

Add the following settings to your CKAN config file (ckan.ini):

**Log File Path**::

    tibimport.log_file_path = /path/to/logs/
    # Default: /usr/lib/ckan/default/src/ckanext-TIBimport/ckanext/tibimport/logs/



Testing
-------

Run tests with::

    pytest --ckan-ini=test.ini

Generate coverage report::

    pytest --ckan-ini=test.ini --cov=ckanext.tibimport


Support
-------

For technical documentation, usage guides, and integration details, please refer to the comprehensive documentation in the `documentation/ <documentation/>`_ directory.
