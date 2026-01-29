

# See CKAN docs on installation from Docker Compose on usage
FROM ubuntu:focal
MAINTAINER Open Knowledge

# Define environment variables
# Environment variable to avoid Ubuntu installation to stop asking Regional questions
ENV DEBIAN_FRONTEND noninteractive

# Install required system packages (Ubuntu 20.04 and libraries required by ckan)
RUN echo 'Install required system packages'

# Install Ubuntu core
RUN apt-get -q -y update \
    && apt-get -q -y upgrade \
    && apt-get -q -y install \
		python3-dev \
		postgresql \
		libpq-dev \
		python3-pip \
		python3-venv \
		git-core \
		solr-jetty \
		openjdk-8-jdk \
		redis-server \
		unixodbc-dev \
    && apt-get -q clean \
    && rm -rf /var/lib/apt/lists/*

# Build-time variables specified by docker-compose.yml / .env
ARG CKAN_SITE_URL
ARG CKAN_HOME_L
ARG CKAN_CONFIG_L
ARG CKAN_STORAGE_PATH_L
ARG CKAN_VER

ARG VER_CKANEXT_DATACOMPARISON="0.6.2"
ARG VER_CKANEXT_FEDORKG="0.8.2"
ARG VER_CKANEXT_FALCON="2cb86e0"



#Install CKAN into a Python virtual environment
#**********************************************
 
#symlink the directories used in this documentation to your home directory
RUN mkdir -p ~/ckan/lib &&\
	ln -s ~/ckan/lib /usr/lib/ckan &&\
	mkdir -p ~/ckan/etc &&\
	ln -s ~/ckan/etc /etc/ckan

#Create a Python virtual environment (virtualenv) to install CKAN into, and activate it
RUN mkdir -p /usr/lib/ckan/default &&\
	chown `whoami` /usr/lib/ckan/default &&\
	python3 -m venv /usr/lib/ckan/default &&\
	. /usr/lib/ckan/default/bin/activate

# Create links to the ckan and pip commands inside the virtual environment
RUN ln -s /usr/lib/ckan/default/bin/pip /usr/local/bin/ckan-pip && \
    ln -s /usr/lib/ckan/default/bin/ckan /usr/local/bin/ckan && \
	ln -s /usr/lib/ckan/default/bin/jupyter /usr/local/bin/jupyter

#Install the recommended setuptools version and up-to-date pip:
RUN ckan-pip install -U pip
RUN ckan-pip install --upgrade pip
RUN ckan-pip install setuptools==44.1.0
#RUN ckan-pip update
RUN apt update
#RUN ckan-pip install --upgrade setuptools
#RUN ckan-pip install zope.interface==4.7.2

#Install the CKAN source code into your virtualenv.
#RUN ckan-pip install -e 'git+https://github.com/ckan/ckan.git@$CKAN_VER#egg=ckan[requirements]'
ADD requirements.txt $CKAN_HOME_L/requirements.txt
#ADD TIB-dev-requirements.txt $CKAN_HOME_L/TIB-dev-requirements.txt
RUN git clone --branch $CKAN_VER https://github.com/ckan/ckan.git $CKAN_HOME_L/src/ckan
RUN ckan-pip install -e $CKAN_HOME_L/src/ckan/
RUN ckan-pip install --upgrade -r $CKAN_HOME_L/requirements.txt

# Add customized TIB requirements files
ADD ./TIB-dev-requirements.txt $CKAN_HOME_L/src/ckan/TIB-dev-requirements.txt
ADD ./TIB-requirements.txt $CKAN_HOME_L/src/ckan/TIB-requirements.txt

# ONLY FOR CLIENT MODE: "Only for Development/Debug mode" area in this document must be commented
# and in ./ckan-entrypoint.sh SET "debug" to false: 
# Line: ckan config-tool "$CONFIG" -s DEFAULT -e "debug = false"
# ***********************************************************************************************
#RUN ckan-pip install --upgrade -r $CKAN_HOME_L/src/ckan/TIB-requirements.txt
# ***********************************************************************************************

# ONLY FOR DEVELOPMENT/DEBUG MODE: "Only for Client mode" area in this document must be commented
# and in ./ckan-entrypoint.sh SET "debug" to true 
# Line: ckan config-tool "$CONFIG" -s DEFAULT -e "debug = true"
# ***********************************************************************************************
RUN ckan-pip install --upgrade -r $CKAN_HOME_L/src/ckan/dev-requirements.txt
RUN ckan-pip install --upgrade -r $CKAN_HOME_L/src/ckan/TIB-dev-requirements.txt
# ***********************************************************************************************


#Reactivate your virtualenv to ensure taking changes
RUN . /usr/lib/ckan/default/bin/activate

# Replace distribution ckan-entrypoint.sh with a custom one.
ADD ./ckan-entrypoint.sh /ckan-entrypoint.sh

#Create a directory to contain the site’s config files and set access permission to them.
# Also we give current user permission to access and execute files and folders
RUN mkdir -p /etc/ckan &&\
	mkdir -p $CKAN_CONFIG_L &&\
	mkdir -p $CKAN_STORAGE_PATH_L &&\
	mkdir -p $CKAN_STORAGE_PATH_L/resources
	
RUN	chmod +x /ckan-entrypoint.sh &&\
    chown -R `whoami` $CKAN_HOME_L $CKAN_CONFIG_L &&\ 
	chown -R `whoami` /etc/ckan &&\
    chown -R `whoami` $CKAN_STORAGE_PATH_L &&\
	chown -R `whoami` $CKAN_STORAGE_PATH_L/resources

# Link to who.ini
# who.ini (the Repoze.who configuration file) needs to be accessible in the same directory as 
# your CKAN config file, so create a symlink to it:
RUN ln -s /usr/lib/ckan/default/src/ckan/ckan/config/who.ini $CKAN_CONFIG_L/who.ini

# Note: config file ($CKAN_CONFIG_L/ckan.ini) is generated in ./ckan-entrypoint.sh

# Replace fixed files solving User images uploads bug
ADD ./user_img_bug/create.py $CKAN_HOME_L/src/ckan/ckan/logic/action/create.py
ADD ./user_img_bug/update.py $CKAN_HOME_L/src/ckan/ckan/logic/action/update.py


# SetUp custom plugins
# ********************
# TEXTVIEW
# ********
# Patch for message in case of big files error
ADD ./Plugins/ckanext-textview/text_view_patched.js $CKAN_HOME_L/src/ckan/ckanext/textview/theme/public/text_view.js

# VIDEOVIEWER
# ***********
ADD ./Plugins/ckanext-videoviewer $CKAN_HOME_L/src/ckanext-videoviewer
RUN ckan-pip install -e $CKAN_HOME_L/src/ckanext-videoviewer

# CADVIEWER
# ***********
ADD ./Plugins/ckanext-tib_cadviewer $CKAN_HOME_L/src/ckanext-tib_cadviewer
RUN ckan-pip install -e $CKAN_HOME_L/src/ckanext-tib_cadviewer

# ckanext-tib_matomo
# ***********
ADD ./Plugins/ckanext-tib_matomo $CKAN_HOME_L/src/ckanext-tib_matomo
RUN ckan-pip install -e $CKAN_HOME_L/src/ckanext-tib_matomo

# TIBtheme
# ********
ADD ./Plugins/ckanext-TIBtheme $CKAN_HOME_L/src/ckanext-TIBtheme
RUN ckan-pip install -e $CKAN_HOME_L/src/ckanext-TIBtheme


# DCAT
# ****
# Note: ckanext-dcat from: https://github.com/ckan/ckanext-dcat.git
ADD ./Plugins/ckanext-dcat $CKAN_HOME_L/src/ckanext-dcat
RUN ckan-pip install -e $CKAN_HOME_L/src/ckanext-dcat
RUN ckan-pip install -r $CKAN_HOME_L/src/ckanext-dcat/requirements.txt
RUN ckan-pip install -r $CKAN_HOME_L/src/ckanext-dcat/dev-requirements.txt

# PDF viewer Plugin:
# ******************
ADD ./Plugins/ckanext-pdfview $CKAN_HOME_L/src/ckanext-pdfview
RUN ckan-pip install -e $CKAN_HOME_L/src/ckanext-pdfview


# Falcon Plugin:
# ******************
RUN ckan-pip install -e git+https://github.com/SDM-TIB/ckanext-falcon@${VER_CKANEXT_FALCON}#egg=ckanext-falcon --src $CKAN_HOME_L/src/ &&\
    ckan-pip install -r https://raw.githubusercontent.com/SDM-TIB/ckanext-falcon/${VER_CKANEXT_FALCON}/requirements.txt

# advancedstats Plugin:
# ******************
ADD ./Plugins/ckanext-advancedstats $CKAN_HOME_L/src/ckanext-advancedstats
RUN ckan-pip install -e $CKAN_HOME_L/src/ckanext-advancedstats
RUN ckan-pip install -r $CKAN_HOME_L/src/ckanext-advancedstats/requirements.txt

# datacomparison Plugin:
# ******************
RUN ckan-pip install -e git+https://github.com/SDM-TIB/ckanext-datacomparison@v${VER_CKANEXT_DATACOMPARISON}#egg=ckanext-datacomparison --src $CKAN_HOME_L/src/ &&\
    ckan-pip install -r https://raw.githubusercontent.com/SDM-TIB/ckanext-datacomparison/refs/tags/v${VER_CKANEXT_DATACOMPARISON}/requirements.txt

# Dwgviewer Plugin:
# ******************
ADD ./Plugins/ckanext-dwgviewer $CKAN_HOME_L/src/ckanext-dwgviewer
RUN ckan-pip install -e $CKAN_HOME_L/src/ckanext-dwgviewer
RUN ckan-pip install -r $CKAN_HOME_L/src/ckanext-dwgviewer/requirements.txt

# FedORKG Plugin:
# ******************
ADD ./fedorkg $CKAN_STORAGE_PATH_L/fedorkg
RUN ckan-pip install -e git+https://github.com/SDM-TIB/ckanext-fedorkg@v${VER_CKANEXT_FEDORKG}#egg=ckanext-fedorkg --src $CKAN_HOME_L/src/ &&\
    ckan-pip install -r https://raw.githubusercontent.com/SDM-TIB/ckanext-fedorkg/refs/tags/v${VER_CKANEXT_FEDORKG}/requirements.txt


# Showcase Plugin:
# ******************
ADD ./Plugins/ckanext-showcase $CKAN_HOME_L/src/ckanext-showcase
RUN ckan-pip install -e $CKAN_HOME_L/src/ckanext-showcase
RUN ckan-pip install -r $CKAN_HOME_L/src/ckanext-showcase/requirements.txt


# LDMoAuth Plugin:
# ******************
ADD ./Plugins/ckanext-LDMoauth2 $CKAN_HOME_L/src/ckanext-LDMoauth2
RUN ckan-pip install -e $CKAN_HOME_L/src/ckanext-LDMoauth2
RUN ckan-pip install -r $CKAN_HOME_L/src/ckanext-LDMoauth2/requirements.txt

# MS and OpenOffice docs viewer
# ***************************** 
ADD ./Plugins/ckanext-officedocs $CKAN_HOME_L/src/ckanext-officedocs
RUN ckan-pip install -e $CKAN_HOME_L/src/ckanext-officedocs


# KG Creation Plugin:
# ******************
ADD ./Plugins/ckanext-LDM_SPARQL $CKAN_HOME_L/src/ckanext-LDM_SPARQL
RUN ckan-pip install -e $CKAN_HOME_L/src/ckanext-LDM_SPARQL
RUN ckan-pip install -r $CKAN_HOME_L/src/ckanext-LDM_SPARQL/requirements.txt

# *****************************************************************
# Add script file for fixing bug if necessary (Consult User Manual)
ADD ./reload_database.sh /reload_database.sh

# Add script file for cleaning the Databases (Consult User Manual)
ADD ./clean_database.sh /clean_database.sh

# Define entry point file
ENTRYPOINT ["sh", "/ckan-entrypoint.sh"]

# ******************************************************************

# Install Jupyternotebooks Plugin requirements
# ********************************************

ADD ./Plugins/ckanext-jupyternotebook $CKAN_HOME_L/src/ckanext-jupyternotebook

RUN ckan-pip install -e $CKAN_HOME_L/src/ckanext-jupyternotebook

# Setup examples
ADD ./LDM_examples_files/RESOURCES/resources/resources $CKAN_STORAGE_PATH_L/resources
ADD ./LDM_examples_files/RESOURCES/jupyternotebooks/notebook $CKAN_STORAGE_PATH_L/notebook
ADD ./LDM_examples_files/RESOURCES/storage $CKAN_STORAGE_PATH_L/storage


# Scheming Plugin:
# ****************
ADD ./Plugins/ckanext-scheming $CKAN_HOME_L/src/ckanext-scheming
RUN ckan-pip install -e $CKAN_HOME_L/src/ckanext-scheming

# Install Resources Updates Plugin requirements
# *********************************************
RUN ckan-pip install python-crontab==2.6.0
RUN pip install python-crontab==2.6.0
RUN apt-get update && apt-get install supervisor
RUN cp $CKAN_HOME_L/src/ckanext-scheming/ckanext/scheming/supervisor-ckan-worker.conf /etc/supervisor/conf.d
RUN mkdir -p /var/log/ckan
RUN chown -R `whoami` /var/log/ckan

# TIBimport Plugin:
# *****************
ADD ./Plugins/ckanext-TIBimport $CKAN_HOME_L/src/ckanext-TIBimport
RUN ckan-pip install -e $CKAN_HOME_L/src/ckanext-TIBimport


# ckanext-TIBnotify Plugin:
# *****************
ADD ./Plugins/ckanext-TIBnotify $CKAN_HOME_L/src/ckanext-TIBnotify
RUN ckan-pip install -e $CKAN_HOME_L/src/ckanext-TIBnotify

# DOI Plugin:
# ***********
ADD ./Plugins/ckanext-doi $CKAN_HOME_L/src/ckanext-doi
RUN ckan-pip install -e $CKAN_HOME_L/src/ckanext-doi
RUN ckan-pip install -r $CKAN_HOME_L/src/ckanext-doi/requirements.txt

# TIBvocparser Plugin:
# ********************
ADD ./Plugins/ckanext-tibvocparser $CKAN_HOME_L/src/ckanext-tibvocparser
RUN ckan-pip install -e $CKAN_HOME_L/src/ckanext-tibvocparser
RUN ckan-pip install -r $CKAN_HOME_L/src/ckanext-tibvocparser/requirements.txt

# Code2NB Plugin (R and Py to Notebook Converter)
# ********************************************
# Install Jupytext (Required for converting)
RUN pip install jupytext
ADD ./Plugins/ckanext-Code2NB $CKAN_HOME_L/src/ckanext-Code2NB
RUN ckan-pip install -e $CKAN_HOME_L/src/ckanext-Code2NB


# Expose port for ckan
EXPOSE 5000

# Run command for running CKAN 
CMD ["ckan","-c","/etc/ckan/default/ckan.ini", "run", "--host", "0.0.0.0"]
