#!/bin/sh
set -e

# URL for the primary database, in the format expected by sqlalchemy (required
# unless linked to a container called 'db')
: ${CKAN_SQLALCHEMY_URL:=}
# URL for solr (required unless linked to a container called 'solr')
: ${CKAN_SOLR_URL:=}
# URL for redis (required unless linked to a container called 'redis')
: ${CKAN_REDIS_URL:=}
# URL for datapusher (required unless linked to a container called 'datapusher')
: ${CKAN_DATAPUSHER_URL:=}

CONFIG="${CKAN_CONFIG}/ckan.ini"

abort () {
  echo "$@" >&2
  exit 1
}

set_environment () {
  export CKAN_SITE_ID=${CKAN_SITE_ID}
  export CKAN_SITE_URL=${CKAN_SITE_URL}
  export CKAN_SQLALCHEMY_URL=${CKAN_SQLALCHEMY_URL}
  export CKAN_SOLR_URL=${CKAN_SOLR_URL}
  export CKAN_REDIS_URL=${CKAN_REDIS_URL}
  export CKAN_STORAGE_PATH=/var/lib/ckan
  export CKAN_DATAPUSHER_URL=${CKAN_DATAPUSHER_URL}
  export CKAN_DATASTORE_WRITE_URL=${CKAN_DATASTORE_WRITE_URL}
  export CKAN_DATASTORE_READ_URL=${CKAN_DATASTORE_READ_URL}
  export CKAN_SMTP_SERVER=${CKAN_SMTP_SERVER}
  export CKAN_SMTP_STARTTLS=${CKAN_SMTP_STARTTLS}
  export CKAN_SMTP_USER=${CKAN_SMTP_USER}
  export CKAN_SMTP_PASSWORD=${CKAN_SMTP_PASSWORD}
  export CKAN_SMTP_MAIL_FROM=${CKAN_SMTP_MAIL_FROM}
  export CKAN_MAX_UPLOAD_SIZE_MB=${CKAN_MAX_UPLOAD_SIZE_MB}
  export CKAN_MAX_RESOURCE_SIZE=${CKAN_MAX_RESOURCE_SIZE}
}

  
write_config () {

  echo "GENERATE CONFIG"
  ckan generate config "$CONFIG"
  
  echo "CONFIG GENEREATED"
  ckan config-tool "$CONFIG" -s DEFAULT -e "debug = false"
  
  # The variables above will be used by CKAN, but
  # in case want to use the config from ckan.ini use this
  echo "CONFIG PLUGINS"
  ckan config-tool -e $CONFIG \
    "sqlalchemy.url = CKAN_SQLALCHEMY_URL" \
    "solr_url = CKAN_SOLR_URL" \
    "ckan.redis.url = CKAN_REDIS_URL" \
    "ckan.storage_path = CKAN_STORAGE_PATH" \
    "ckan.site_url = CKAN_SITE_URL" \
    "ckan.datapusher.url = CKAN_DATAPUSHER_URL" \
    "ckan.datastore.write_url = CKAN_DATASTORE_WRITE_URL" \
    "ckan.datastore.read_url = CKAN_DATASTORE_READ_URL" \
	"smtp.server = postfix" \
    "ckan.views.default_views = image_view text_view recline_view videoviewer" \
    "smtp.mail_from = admin@datahub.com" \
    "ckan.plugins = stats text_view image_view recline_view resource_proxy officedocs_view datastore datapusher webpage_view videoviewer TIBtheme dcat dcat_json_interface pdf_view jupyternotebook" \
    "ckan.datapusher.formats = csv xls xlsx tsv application/csv application/vnd.ms-excel application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" \
    "ckan.max_resource_size = CKAN_MAX_RESOURCE_SIZE"
#	"ckan.root_path = /ldmservice/{{LANG}}/foo"

#     "ckan.views.default_views = image_view text_view recline_view videoviewer" \
#     "ckan.plugins = stats text_view image_view recline_view resource_proxy datastore datapusher webpage_view videoviewer TIBtheme dcat dcat_json_interface" \
  
#  ckan config-tool -s app:main $CONFIG "ckan.root_path = /ldmservice/{{LANG}}"

  
  echo "CONFIG PLUGINS DONE"
}

set_environment

# Wait for PostgreSQL
while ! pg_isready -h db -U ckan; do
  sleep 3;
done

# If we don't already have a config file (first time execution), bootstrap
if [ ! -e "$CONFIG" ]; then
  . /usr/lib/ckan/default/bin/activate
  
  write_config
  echo "INITIALIZE DB"  
  ckan -c "$CONFIG" db init  
  echo "REBILD INDEX"  

  # Rebuild index 
  ckan search-index rebuild -c $CONFIG
  
  echo "DONE"  
fi

# Get or create CKAN_SQLALCHEMY_URL
if [ -z "$CKAN_SQLALCHEMY_URL" ]; then
  abort "ERROR: no CKAN_SQLALCHEMY_URL specified in docker-compose.yml"
fi

if [ -z "$CKAN_SOLR_URL" ]; then
    abort "ERROR: no CKAN_SOLR_URL specified in docker-compose.yml"
fi

if [ -z "$CKAN_REDIS_URL" ]; then
    abort "ERROR: no CKAN_REDIS_URL specified in docker-compose.yml"
fi

if [ -z "$CKAN_DATAPUSHER_URL" ]; then
    abort "ERROR: no CKAN_DATAPUSHER_URL specified in docker-compose.yml"
fi

exec "$@"