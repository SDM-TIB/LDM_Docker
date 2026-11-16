# Stage 1: Stable CKAN base installation
FROM ubuntu:focal AS base

# Set non-interactive mode
ENV DEBIAN_FRONTEND=noninteractive

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
RUN ln -s /usr/lib/ckan/default/bin/ckan /usr/local/bin/ckan && \
    printf '#!/bin/sh\nexec env GIT_TERMINAL_PROMPT=0 /usr/lib/ckan/default/bin/pip "$@"\n' > /usr/local/bin/ckan-pip && \
    chmod +x /usr/local/bin/ckan-pip

# Install the recommended setuptools version and up-to-date pip:
RUN ckan-pip install --no-cache-dir --upgrade pip && \
    ckan-pip install --no-cache-dir setuptools==44.1.0

# Install the CKAN source code into your virtualenv.
COPY requirements.txt $CKAN_HOME_L/requirements.txt
COPY patch_and_install.py $CKAN_HOME_L/patch_and_install.py
RUN git clone --branch $CKAN_VER https://github.com/ckan/ckan.git $CKAN_HOME_L/src/ckan && \
    python3 $CKAN_HOME_L/patch_and_install.py -c $CKAN_HOME_L/requirements.txt -r $CKAN_HOME_L/src/ckan/requirements.txt && \
    ckan-pip install -e $CKAN_HOME_L/src/ckan/

# ONLY FOR DEVELOPMENT/DEBUG MODE: "Only for Production mode" area in this document must be commented
# and in ./ckan-entrypoint.sh SET "debug" to true 
# Line: ckan config-tool "$CONFIG" -s DEFAULT -e "debug = true"
# ***********************************************************************************************
# RUN ckan-pip install --no-cache-dir --upgrade -r $CKAN_HOME_L/src/ckan/dev-requirements.txt
# ***********************************************************************************************

# Reactivate your virtualenv to ensure taking changes
RUN . /usr/lib/ckan/default/bin/activate

# Create a directory to contain the site's config files and set access permission to them.
# Also we give current user permission to access and execute files and folders
RUN mkdir -p /etc/ckan &&\
    mkdir -p $CKAN_CONFIG_L &&\
    mkdir -p $CKAN_STORAGE_PATH_L &&\
    mkdir -p $CKAN_STORAGE_PATH_L/resources

RUN chown -R `whoami` $CKAN_HOME_L $CKAN_CONFIG_L &&\
    chown -R `whoami` /etc/ckan &&\
    chown -R `whoami` $CKAN_STORAGE_PATH_L &&\
    chown -R `whoami` $CKAN_STORAGE_PATH_L/resources

# Link to who.ini
# who.ini (the Repoze.who configuration file) needs to be accessible in the same directory as 
# your CKAN config file, so create a symlink to it:
RUN ln -s /usr/lib/ckan/default/src/ckan/ckan/config/who.ini $CKAN_CONFIG_L/who.ini

# Note: config file ($CKAN_CONFIG_L/ckan.ini) is generated in ./ckan-entrypoint.sh

# *****************************************************************
# Add script file for fixing bug if necessary (Consult User Manual)
COPY ./reload_database.sh /reload_database.sh

# Add script file for cleaning the Databases (Consult User Manual)
COPY ./clean_database.sh /clean_database.sh
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

# Stage 2: Install plugins
FROM base AS final

ARG CKAN_HOME_L

COPY ckan-plugins.txt ${CKAN_HOME_L}/ckan-plugins.txt
RUN <<'EOF'
#!/bin/bash
set -euo pipefail
while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%%#*}"
    line="$(echo "$line" | xargs)"
    [[ -z "$line" ]] && continue

    org_repo="${line%@*}"
    ref="${line##*@}"
    repo_name="${org_repo##*/}"

    dir_name="$(echo "$repo_name" | sed -E 's/[-_.]+/-/g' | tr '[:upper:]' '[:lower:]')"
    src_dir="$CKAN_HOME_L/src/${dir_name}"

    echo ">>> Installing ${repo_name}@${ref}"
    ckan-pip install -e \
        "git+https://github.com/${org_repo}@${ref}#egg=${repo_name}" \
        --src "$CKAN_HOME_L/src/"

    if [[ ! -d "$src_dir" ]]; then
        echo "ERROR: expected clone at ${src_dir} not found" >&2
        ls -1 "$CKAN_HOME_L/src/" >&2
        exit 1
    fi

    req_file="${src_dir}/requirements.txt"
    if [[ -s "$req_file" ]]; then
        ckan-pip install --no-cache-dir -r "$req_file"
    else
        echo "    (no requirements.txt, or file is empty; skipping)"
    fi
done < ${CKAN_HOME_L}/ckan-plugins.txt
EOF

# Copy federation metadata
COPY ./fedorkg $CKAN_STORAGE_PATH_L/fedorkg

# Copy metadata of datasets
COPY ./rdf_metadata $CKAN_STORAGE_PATH_L/rdf_metadata

# Copy CKAN worker config from LDM schema
RUN cp $CKAN_HOME_L/src/ckanext-ldm-schema/ckanext/ldm_schema/supervisor-ckan-worker.conf /etc/supervisor/conf.d

# Apply any patches
COPY patches ${CKAN_HOME_L}/patches
RUN . /usr/lib/ckan/default/bin/activate && \
    for d in $CKAN_HOME_L/patches/*; do \
      if [ -d $d ]; then \
        for f in $d/*.patch; do \
          if [ -f $f ]; then \
            cd $(python -c "import ${d##*/}; import os; print(os.path.dirname(os.path.dirname(${d##*/}.__file__)))") && \
            patch -p1 < $f ; \
          fi ; \
        done ; \
      fi ; \
    done

# Replace distribution ckan-entrypoint.sh with a custom one.
COPY ./ckan-entrypoint.sh /ckan-entrypoint.sh
RUN chmod +x /ckan-entrypoint.sh

# Define entry point file
ENTRYPOINT ["sh", "/ckan-entrypoint.sh"]

# Run command for running CKAN
# --threaded: one slow request (e.g. an LDM Assistant answer, 10-60 s) must not block the whole site
CMD ["ckan","-c","/etc/ckan/default/ckan.ini", "run", "--host", "0.0.0.0", "--threaded"]
