# Stage 1: Stable CKAN base installation
FROM ubuntu:focal AS base

# Set non-interactive mode
ENV DEBIAN_FRONTEND noninteractive

# Install required system packages (Ubuntu 20.04 and libraries required by CKAN)
RUN echo 'Install required system packages' && \
    apt-get -q -y update && \
    apt-get -q -y upgrade && \
    apt-get -q -y install \
        python3-dev \
        postgresql \
        libpq-dev \
        python3-pip \
        python3-venv \
        git-core \
        solr-jetty \
        openjdk-8-jdk \
        redis-server \
        unixodbc-dev && \
    apt-get -q clean && \
    rm -rf /var/lib/apt/lists/*

# Build-time variables specified by docker-compose.yml / .env
ARG CKAN_HOME_L
ARG CKAN_CONFIG_L
ARG CKAN_STORAGE_PATH_L
ARG CKAN_VER

# Symlink CKAN lib and etc directories to root's home directory
RUN mkdir -p ~/ckan/lib && \
    ln -s ~/ckan/lib /usr/lib/ckan && \
    mkdir -p ~/ckan/etc && \
    ln -s ~/ckan/etc /etc/ckan

# Create a Python virtual environment (virtualenv) to install CKAN into, and activate it
RUN mkdir -p /usr/lib/ckan/default && \
    chown `whoami` /usr/lib/ckan/default && \
    python3 -m venv /usr/lib/ckan/default && \
    . /usr/lib/ckan/default/bin/activate

# Create links to the CKAN and pip commands inside the virtual environment
RUN ln -s /usr/lib/ckan/default/bin/pip /usr/local/bin/ckan-pip && \
    ln -s /usr/lib/ckan/default/bin/ckan /usr/local/bin/ckan

# Install the recommended setuptools version and up-to-date pip:
RUN ckan-pip install --no-cache-dir --upgrade pip && \
    ckan-pip install --no-cache-dir setuptools==44.1.0

# Install the CKAN source code into your virtualenv.
COPY requirements.txt $CKAN_HOME_L/requirements.txt
RUN git clone --branch $CKAN_VER https://github.com/ckan/ckan.git $CKAN_HOME_L/src/ckan && \
    ckan-pip install -e $CKAN_HOME_L/src/ckan/ && \
    ckan-pip install --no-cache-dir --upgrade -r $CKAN_HOME_L/requirements.txt

# Add customized TIB requirements files
# ONLY FOR PRODUCTION MODE: "Only for Development/Debug mode" area in this document must be commented
# and in ./ckan-entrypoint.sh SET "debug" to false: 
# Line: ckan config-tool "$CONFIG" -s DEFAULT -e "debug = false"
# ***********************************************************************************************
#COPY ./TIB-requirements.txt $CKAN_HOME_L/src/ckan/TIB-requirements.txt
#RUN ckan-pip install --no-cache-dir --upgrade -r $CKAN_HOME_L/src/ckan/TIB-requirements.txt
# ***********************************************************************************************

# ONLY FOR DEVELOPMENT/DEBUG MODE: "Only for Production mode" area in this document must be commented
# and in ./ckan-entrypoint.sh SET "debug" to true 
# Line: ckan config-tool "$CONFIG" -s DEFAULT -e "debug = true"
# ***********************************************************************************************
COPY ./TIB-dev-requirements.txt $CKAN_HOME_L/src/ckan/TIB-dev-requirements.txt
COPY ./TIB-requirements.txt $CKAN_HOME_L/src/ckan/TIB-requirements.txt
RUN ckan-pip install --no-cache-dir --upgrade -r $CKAN_HOME_L/src/ckan/dev-requirements.txt
RUN ckan-pip install --no-cache-dir --upgrade -r $CKAN_HOME_L/src/ckan/TIB-dev-requirements.txt
# ***********************************************************************************************

# Reactivate your virtualenv to ensure taking changes
RUN . /usr/lib/ckan/default/bin/activate

# Replace distribution ckan-entrypoint.sh with a custom one.
COPY ./ckan-entrypoint.sh /ckan-entrypoint.sh

# Create a directory to contain the site's config files and set access permission to them.
# Also we give current user permission to access and execute files and folders
RUN mkdir -p /etc/ckan &&\
    mkdir -p $CKAN_CONFIG_L &&\
    mkdir -p $CKAN_STORAGE_PATH_L &&\
    mkdir -p $CKAN_STORAGE_PATH_L/resources
	
RUN chmod +x /ckan-entrypoint.sh &&\
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
COPY ./user_img_bug/create.py $CKAN_HOME_L/src/ckan/ckan/logic/action/create.py
COPY ./user_img_bug/update.py $CKAN_HOME_L/src/ckan/ckan/logic/action/update.py

# *****************************************************************
# Add script file for fixing bug if necessary (Consult User Manual)
COPY ./reload_database.sh /reload_database.sh

# Add script file for cleaning the Databases (Consult User Manual)
COPY ./clean_database.sh /clean_database.sh

# Define entry point file
ENTRYPOINT ["sh", "/ckan-entrypoint.sh"]
# ******************************************************************

# Setup examples
COPY ./LDM_examples_files/RESOURCES/resources/resources $CKAN_STORAGE_PATH_L/resources
COPY ./LDM_examples_files/RESOURCES/jupyternotebooks/notebook $CKAN_STORAGE_PATH_L/notebook
COPY ./LDM_examples_files/RESOURCES/storage $CKAN_STORAGE_PATH_L/storage

# Install Resources Updates Plugin requirements
# *********************************************
RUN ckan-pip install python-crontab==2.6.0 && \
    pip install python-crontab==2.6.0
RUN apt-get update && \
    apt-get install supervisor && \
    apt-get -q clean && \
    rm -rf /var/lib/apt/lists/*
RUN mkdir -p /var/log/ckan && \
    chown -R `whoami` /var/log/ckan

# Expose port for ckan
EXPOSE 5000

# Run command for running CKAN 
CMD ["ckan","-c","/etc/ckan/default/ckan.ini", "run", "--host", "0.0.0.0"]

# Stage 2: Install plugins
FROM base AS final

ARG CKAN_HOME_L

ARG VER_CKANEXT_DATACOMPARISON="0.6.2"
ARG VER_CKANEXT_FEDORKG="0.8.2"
ARG VER_CKANEXT_ADVANCEDSTATS="0.7.0"
ARG VER_CKANEXT_FALCON="2cb86e0"
ARG VER_CKANEXT_KGCREATION="11cd45c"
ARG VER_CKANEXT_JUPYTERNOTEBOOK="5794bed"
ARG VER_CKANEXT_CODE2NB="7a217a9"

# TEXTVIEW
# ********
# Patch for message in case of big files error
COPY ./Plugins/ckanext-textview/text_view_patched.js $CKAN_HOME_L/src/ckan/ckanext/textview/theme/public/text_view.js

# VIDEOVIEWER
# ***********
COPY ./Plugins/ckanext-videoviewer $CKAN_HOME_L/src/ckanext-videoviewer
RUN ckan-pip install -e $CKAN_HOME_L/src/ckanext-videoviewer

# CADVIEWER
# ***********
COPY ./Plugins/ckanext-tib_cadviewer $CKAN_HOME_L/src/ckanext-tib_cadviewer
RUN ckan-pip install -e $CKAN_HOME_L/src/ckanext-tib_cadviewer

# ckanext-tib_matomo
# ***********
COPY ./Plugins/ckanext-tib_matomo $CKAN_HOME_L/src/ckanext-tib_matomo
RUN ckan-pip install -e $CKAN_HOME_L/src/ckanext-tib_matomo

# TIBtheme
# ********
COPY ./Plugins/ckanext-TIBtheme $CKAN_HOME_L/src/ckanext-TIBtheme
RUN ckan-pip install -e $CKAN_HOME_L/src/ckanext-TIBtheme

# TIB dcat
# ****
COPY ./Plugins/ckanext-TIBdcat $CKAN_HOME_L/src/ckanext-TIBdcat
RUN ckan-pip install -e $CKAN_HOME_L/src/ckanext-TIBdcat
RUN ckan-pip install -r $CKAN_HOME_L/src/ckanext-TIBdcat/requirements.txt

# PDF viewer Plugin:
# ******************
COPY ./Plugins/ckanext-pdfview $CKAN_HOME_L/src/ckanext-pdfview
RUN ckan-pip install -e $CKAN_HOME_L/src/ckanext-pdfview

# Falcon Plugin:
# ******************
RUN ckan-pip install -e git+https://github.com/SDM-TIB/ckanext-falcon@${VER_CKANEXT_FALCON}#egg=ckanext-falcon --src $CKAN_HOME_L/src/ &&\
    ckan-pip install -r https://raw.githubusercontent.com/SDM-TIB/ckanext-falcon/${VER_CKANEXT_FALCON}/requirements.txt

# advancedstats Plugin:
# ******************
RUN ckan-pip install -e git+https://github.com/SDM-TIB/ckanext-advancedstats@v${VER_CKANEXT_ADVANCEDSTATS}#egg=ckanext-advancedstats --src $CKAN_HOME_L/src/ &&\
    ckan-pip install -r https://raw.githubusercontent.com/SDM-TIB/ckanext-advancedstats/refs/tags/v${VER_CKANEXT_ADVANCEDSTATS}/requirements.txt

# datacomparison Plugin:
# ******************
RUN ckan-pip install -e git+https://github.com/SDM-TIB/ckanext-datacomparison@v${VER_CKANEXT_DATACOMPARISON}#egg=ckanext-datacomparison --src $CKAN_HOME_L/src/ &&\
    ckan-pip install -r https://raw.githubusercontent.com/SDM-TIB/ckanext-datacomparison/refs/tags/v${VER_CKANEXT_DATACOMPARISON}/requirements.txt

# Dwgviewer Plugin:
# ******************
COPY ./Plugins/ckanext-dwgviewer $CKAN_HOME_L/src/ckanext-dwgviewer
RUN ckan-pip install -e $CKAN_HOME_L/src/ckanext-dwgviewer
RUN ckan-pip install -r $CKAN_HOME_L/src/ckanext-dwgviewer/requirements.txt

# FedORKG Plugin:
# ******************
COPY ./fedorkg $CKAN_STORAGE_PATH_L/fedorkg
RUN ckan-pip install -e git+https://github.com/SDM-TIB/ckanext-fedorkg@v${VER_CKANEXT_FEDORKG}#egg=ckanext-fedorkg --src $CKAN_HOME_L/src/ &&\
    ckan-pip install -r https://raw.githubusercontent.com/SDM-TIB/ckanext-fedorkg/refs/tags/v${VER_CKANEXT_FEDORKG}/requirements.txt

# Showcase Plugin:
# ******************
COPY ./Plugins/ckanext-showcase $CKAN_HOME_L/src/ckanext-showcase
RUN ckan-pip install -e $CKAN_HOME_L/src/ckanext-showcase
RUN ckan-pip install -r $CKAN_HOME_L/src/ckanext-showcase/requirements.txt

# LDMoAuth Plugin:
# ******************
COPY ./Plugins/ckanext-LDMoauth2 $CKAN_HOME_L/src/ckanext-LDMoauth2
RUN ckan-pip install -e $CKAN_HOME_L/src/ckanext-LDMoauth2
RUN ckan-pip install -r $CKAN_HOME_L/src/ckanext-LDMoauth2/requirements.txt

# MS and OpenOffice docs viewer
# ***************************** 
COPY ./Plugins/ckanext-officedocs $CKAN_HOME_L/src/ckanext-officedocs
RUN ckan-pip install -e $CKAN_HOME_L/src/ckanext-officedocs

# KG Creation Plugin:
# ******************
COPY ./Plugins/ckanext-LDM_SPARQL $CKAN_HOME_L/src/ckanext-LDM_SPARQL
RUN ckan-pip install -e $CKAN_HOME_L/src/ckanext-LDM_SPARQL
RUN ckan-pip install -r $CKAN_HOME_L/src/ckanext-LDM_SPARQL/requirements.txt
#RUN ckan-pip install -e git+https://github.com/SDM-TIB/ckanext-kgcreation@${VER_CKANEXT_KGCREATION}#egg=ckanext-kgcreation --src $CKAN_HOME_L/src/ &&\
#    ckan-pip install -r https://raw.githubusercontent.com/SDM-TIB/ckanext-kgcreation/${VER_CKANEXT_KGCREATION}/requirements.txt

# Install Jupyternotebooks Plugin requirements
# ********************************************
RUN ckan-pip install -e git+https://github.com/SDM-TIB/ckanext-jupyternotebook@${VER_CKANEXT_JUPYTERNOTEBOOK}#egg=ckanext-jupyternotebook --src $CKAN_HOME_L/src/ &&\
    ckan-pip install -r https://raw.githubusercontent.com/SDM-TIB/ckanext-jupyternotebook/${VER_CKANEXT_JUPYTERNOTEBOOK}/requirements.txt

# Scheming Plugin:
# ****************
COPY ./Plugins/ckanext-scheming $CKAN_HOME_L/src/ckanext-scheming
RUN ckan-pip install -e $CKAN_HOME_L/src/ckanext-scheming
RUN cp $CKAN_HOME_L/src/ckanext-scheming/ckanext/scheming/supervisor-ckan-worker.conf /etc/supervisor/conf.d

# TIBimport Plugin:
# *****************
COPY ./Plugins/ckanext-TIBimport $CKAN_HOME_L/src/ckanext-TIBimport
RUN ckan-pip install -e $CKAN_HOME_L/src/ckanext-TIBimport

# ckanext-TIBnotify Plugin:
# *****************
COPY ./Plugins/ckanext-TIBnotify $CKAN_HOME_L/src/ckanext-TIBnotify
RUN ckan-pip install -e $CKAN_HOME_L/src/ckanext-TIBnotify

# DOI Plugin:
# ***********
COPY ./Plugins/ckanext-doi $CKAN_HOME_L/src/ckanext-doi
RUN ckan-pip install -e $CKAN_HOME_L/src/ckanext-doi
RUN ckan-pip install -r $CKAN_HOME_L/src/ckanext-doi/requirements.txt

# TIBvocparser Plugin:
# ********************
COPY ./Plugins/ckanext-tibvocparser $CKAN_HOME_L/src/ckanext-tibvocparser
RUN ckan-pip install -e $CKAN_HOME_L/src/ckanext-tibvocparser
RUN ckan-pip install -r $CKAN_HOME_L/src/ckanext-tibvocparser/requirements.txt

# RDF Graph Visualisation Plugin:
# ********************
COPY ./Plugins/ckanext-graphviewer $CKAN_HOME_L/src/ckanext-graphviewer
COPY ./rdf_metadata $CKAN_STORAGE_PATH_L/rdf_metadata
RUN ckan-pip install -e $CKAN_HOME_L/src/ckanext-graphviewer

# Code2NB Plugin (R and Py to Notebook Converter)
# ********************************************
RUN ckan-pip install -e git+https://github.com/SDM-TIB/ckanext-Code2NB@${VER_CKANEXT_CODE2NB}#egg=ckanext-Code2NB --src $CKAN_HOME_L/src/ &&\
    ckan-pip install -r https://raw.githubusercontent.com/SDM-TIB/ckanext-Code2NB/${VER_CKANEXT_CODE2NB}/requirements.txt

