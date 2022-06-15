# TIB – Leibniz Data Manager

The TIB Data Manager has been developed to support the aspect of better re-usability of research data.

 The prototype supports the management and access to heterogeneous research data publications and assists researchers in the selection of relevant data sets for their respective disciplines.

 The prototype currently offers the following functions for the visualization of research data:

 ● Supports data collections and publications with different formats

● Different views on the same data set (2D and 3D support)

● Visualization of Auto CAD files

● Jupyter Notebook(s) for demonstrating live code

● RDF Description of data collections

 

The file specific viewers were implemented using CKAN (Comprehensive Knowledge Archive

Network) plug-ins to render existing viewers for the datasets included in the CKAN instance.

 

#### Installation Requirements

In order to avoid having to manually install all services and dependencies (CKAN, PostgreSQL, SOLR, Postfix, DataPusher, JupyterNotebooks), the distribution package comes with dockerized instances of these dependencies, making it easy to get started with TIB Data Manager.

 

Pre-install requirements:

\-     **Docker:** To be able to install it, the user must download the docker packets from Docker official website (https://docs.docker.com/install/), and afterwards follow the installation steps established in the packets.

\-     **GIT:** In case the user is going to clone the TIB Data Manager code into your system is also needed to have GIT installed following the instructions in the GIT official website (https://gitforwindows.org).

 

For more detailed instructions installing the DM instance see “TIB Data Manager Manual.pdf” inside this repository.

 

 

#### Changelog:

 

###### \-    Initial version:

The prototype currently offers the following functions for the visualization of research data:

● Supports data collections and publications with different formats

● Different views on the same data set (2D and 3D support)

● Visualization of Auto CAD files

● Jupyter Notebook(s) for demonstrating live code

● RDF Description of data collections

 

The file specific viewers were implemented using CKAN (Comprehensive Knowledge Archive Network) plug-ins to render existing viewers for the datasets included in the CKAN instance.



###### \-    Version 1.0 (February 2021)

●  Fixed errors about incompatible dependencies.

●   Manual updated with more details and instructions

●   Resolved bugs and erorrs related to conflicting containers in docker.



###### \-  Version 2.0 (March 2021)

●  CKAN version upgraded to 2.9.1 running in python3.

●  Configuration settings placed in on single file (.env).

●  Libraries and dependencies fixed to become the installer stable against third party libraries upgrades.



###### \-  Version 2.1 (August 2021)

●  Plugins installed allowing more visualization formats: CSV, Excel, XML, JSON, TXT, PNG, JPEG, GIF, PDF and Open Office docs (ODT, ODS, ODP).

●  Fixed home page issues causing search bars not operable.

●  Some descriptive information added to "about" page.



###### \-  Version 2.2 (September 2021)

●  Jupyter Notebook visualization plugin full developed by TIB were installed allowing to see and execute notebooks resources in a secure and integrated with CKAN way.



###### \-  Version 2.3 (November 2021)

●  New "Services" schema was added to allow manage this kind of digital objects as descripted in DCAT specification.

●  DOI creation was implemented for the current managed objects: datasets, imported datasets (virtual) and services.

●  Adaptations in DCAT plugin for managing "Services".

●  Changes in Main menu and interfaces were made for showing the new features propertly.

●  New plugin was developed and implemented for adding new descriptions to objects using other vocabularies: DataCite, CSL, DublinCore and BibTex.



###### \-  Version 2.3.1 (February 2022)

●  The log4j security problem was solved updating "Solr" to the last available version 8.11.1.

●  Relationship between Datasets and Data-Services was added including the following:

​			●  Tools for stablish the relationship in add/edit datasets and add/edit Services pages.

​			●  The relationship was added to DCAT-RDF serializations.

​			●  The relationship was added to Datasets and Data-Services description pages in the 	"Additional info" area.

​			●  Console commands were created for creating the Data-Services tables and cleaning them.



###### \-  Version 2.4 (April 2022)

●  Solr was updated to the last version (8.11.1) solving the log4j security issue.

●  CKAN was upgraded to the last stable version (2.9.5) to work with updated Solr propertly.

●  Added translation of the tool to German language.

●  Added "auto-update resources" feature, allowing to set automatic updates to resources from an URL in regular time basis (daily, weekly or monthly).

●  Added "multiple authors" feature, allowing to set more than one author with ORCID data to datasets.

●  Added "Data-Service / Dataset relationship" feature, allowing to set relationship between Data-Services and Datasets ("Serves to" or "is served by").

●  Datasets descriptions using vocabularies (DCAT serializations, DataCite, DublinCore, CSL and BibTeX) were updated to include in the metadata the new features developed.

●  User Manual was updated with corrections.



###### \-  Version 2.4.1 (June 2022)

●  New configuration options were added to the user's interface allowing to set title, logo and enabling/disabling "Legal Notices" features and pages.

●  "Legal Notices" features and pages were added (links on the footer).

●  "Matomo tracking plugin" was developed for tracking visits to the LDM online service. This feature is not enabled by default in local installation because Matomo is a commercial tool that requires licence.

●  "CAD viewer plugin" was developed and implemented using ShareCAD.org free service for showing CAD 2D and 3D visualizations. 

●  Docker volumes were set making the data, source code and configuration files persistent.

●  Docker network was configured hiding services ports (solr, postgresdb, etc.) from external access.

●  Jupyter Notebooks plugin were re-factored and Jupyter Notebook server was isolated in a Docker container.

●  New examples, including resources in different formats, were added to the installer.

●  A "Demo page" was added pointing to resources explaining LDM (demo-paper published on ESWC 2022, motivation video, demo video, ESWC best demo award).

●  The installation manual was extended adding new procedures and explanations regarding the customization of LDM instances (CSS styles, legal notices pages content, title, logo, etc.).



