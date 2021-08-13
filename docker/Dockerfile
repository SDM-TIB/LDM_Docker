

# See CKAN docs on installation from Docker Compose on usage
FROM ubuntu
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
    && apt-get -q clean \
    && rm -rf /var/lib/apt/lists/*


# Build-time variables specified by docker-compose.yml / .env
ARG CKAN_SITE_URL
ARG CKAN_HOME_L
ARG CKAN_CONFIG_L
ARG CKAN_VER



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
    ln -s /usr/lib/ckan/default/bin/ckan /usr/local/bin/ckan

#Install the recommended setuptools version and up-to-date pip:
RUN ckan-pip install -U pip
RUN ckan-pip install --upgrade pip
RUN ckan-pip install setuptools==44.1.0


#Install the CKAN source code into your virtualenv.
#RUN ckan-pip install -e 'git+https://github.com/ckan/ckan.git@$CKAN_VER#egg=ckan[requirements]'
RUN git clone --branch $CKAN_VER https://github.com/ckan/ckan.git $CKAN_HOME_L/src/ckan
RUN ckan-pip install -e $CKAN_HOME_L/src/ckan/
RUN ckan-pip install --upgrade -r $CKAN_HOME_L/src/ckan/requirements.txt

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
	mkdir -p $CKAN_CONFIG_L 
RUN	chmod +x /ckan-entrypoint.sh && \
    chown -R `whoami` $CKAN_HOME_L $CKAN_CONFIG_L &&\ 
	chown -R `whoami` /etc/ckan


# Link to who.ini
# who.ini (the Repoze.who configuration file) needs to be accessible in the same directory as 
# your CKAN config file, so create a symlink to it:
RUN ln -s /usr/lib/ckan/default/src/ckan/ckan/config/who.ini $CKAN_CONFIG_L/who.ini

# Note: config file ($CKAN_CONFIG_L/ckan.ini) is generated in ./ckan-entrypoint.sh

# SetUp custom plugins
ADD ./Plugins/ckanext-videoviewer $CKAN_HOME_L/src/ckanext-videoviewer
RUN ckan-pip install -e $CKAN_HOME_L/src/ckanext-videoviewer

ADD ./Plugins/ckanext-TIBtheme $CKAN_HOME_L/src/ckanext-TIBtheme
RUN ckan-pip install -e $CKAN_HOME_L/src/ckanext-TIBtheme

# Note: ckanext-dcat from: https://github.com/ckan/ckanext-dcat.git
ADD ./Plugins/ckanext-dcat-master $CKAN_HOME_L/src/ckanext-dcat
RUN ckan-pip install -e $CKAN_HOME_L/src/ckanext-dcat
RUN ckan-pip install -r $CKAN_HOME_L/src/ckanext-dcat/requirements.txt
RUN ckan-pip install -r $CKAN_HOME_L/src/ckanext-dcat/dev-requirements.txt

# PDF viewer Plugin:
ADD ./Plugins/ckanext-pdfview $CKAN_HOME_L/src/ckanext-pdfview
RUN ckan-pip install -e $CKAN_HOME_L/src/ckanext-pdfview

# MS and OpenOffice docs viewer 
ADD ./Plugins/ckanext-officedocs $CKAN_HOME_L/src/ckanext-officedocs
RUN ckan-pip install -e $CKAN_HOME_L/src/ckanext-officedocs


# Add script file for fixing bug if necessary (Consult User Manual)
ADD ./reload_database.sh /reload_database.sh

# Add script file for cleaning the Databases (Consult User Manual)
ADD ./clean_database.sh /clean_database.sh

# Define entry point file
ENTRYPOINT ["sh", "/ckan-entrypoint.sh"]

# Expose port for ckan
EXPOSE 5000

# Run command for running CKAN 
CMD ["ckan","-c","/etc/ckan/default/ckan.ini", "run", "--host", "0.0.0.0"]