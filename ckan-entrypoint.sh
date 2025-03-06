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
    "ckan.views.default_views = image_view text_view videoviewer officedocs_view pdf_view tib_cadviewer" \
    "smtp.mail_from = admin@datahub.com" \
    "ckan.plugins = fedorkg advancedstats stats text_view image_view recline_view resource_proxy officedocs_view webpage_view videoviewer TIBtheme dcat dcat_json_interface pdf_view scheming_datasets tibimport jupyternotebook doi tibvocparser scheming_tibupdateresources tib_cadviewer ldm_sparql falcon tib_matomo tibnotify Code2NB" \
    "ckan.datapusher.formats = csv xls xlsx tsv application/csv application/vnd.ms-excel application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" \
    "ckan.max_resource_size = CKAN_MAX_RESOURCE_SIZE" \
	"ckan.site_title = LDM" \
	"ckan.site_logo = /images/TIB_logo.png" \
	"ckan.favicon = /images/TIB_logo.png"

  echo "CONFIG tibimport vars"
  ckan config-tool -s app:main $CONFIG \
	"tibimport.show_vdatasets_virtual_ribbon = true" \
	"tibimport.show_vdatasets_virtual_source_ribbon = true" \
    "tibimport.updatedatasets_enabled = false" \
	"tibimport.updatedatasets_crontab_user = root"
	
  echo "CONFIG tibimport vars DONE"

  echo "CONFIG scheming vars"
  ckan config-tool -s app:main $CONFIG "scheming.dataset_schemas = ckanext.scheming:ckan_dataset.yaml ckanext.scheming:ckan_vdataset.yaml ckanext.scheming:service.yaml"
  echo "CONFIG scheming vars DONE"

  echo "CONFIG DOI plugin"
  ckan config-tool -s app:main $CONFIG \
    "ckanext.doi.account_name = ${DOI_Account_Name}" \
    "ckanext.doi.account_password = ${DOI_Account_Password}" \
    "ckanext.doi.prefix = ${DOI_Prefix}" \
    "ckanext.doi.publisher = ${DOI_Publisher}" \
    "ckanext.doi.test_mode = false"
  echo "CONFIG DOI plugin DONE"

  echo "CONFIG AutoUpdate Resources plugin"
  ckan config-tool -s app:main $CONFIG \
    "scheming_tibupdateresources_enabled = true" \
    "scheming_tibupdateresources_crontab_user = root" \
    "ckan.extra_resource_fields = auto_update"
  echo "CONFIG AutoUpdate Resources plugin DONE"


  echo "CONFIG TIBtheme plugin"
  ckan config-tool -s app:main $CONFIG \
	"tibtheme.legal_notices_enabled = true" \
	"tibtheme.show_cookies_alert = true" \
	"tibtheme.legal_notices_TIB_terms_use_enabled = true" \
	"tibtheme.special_conditions_LDM_enabled = true" \
	"tibtheme.special_conditions_label = Special conditions TIB LDM" \
	"tibtheme.data_privacy_enabled = true" \
	"tibtheme.imprint_enabled = true" \
	"tibtheme.accessibility_statement_enabled = true"
  echo "CONFIG TIBtheme plugin DONE"

  echo "CONFIG GERMAN TRANSLATIONS"
  ckan config-tool -s app:main $CONFIG \
	"ckan.i18n_directory = ${CKAN_HOME}/src/ckanext-TIBtheme/ckanext/TIBtheme/i18n/" \
	"ckan.i18n.extra_locales = de"
  echo "CONFIG GERMAN TRANLATIONS DONE"

  # echo "CONFIG jupyternotebook vars"
  # ckan config-tool -s app:main $CONFIG "ckan.jupyternotebooks_url = https://service.tib.eu/ldmjupyter/notebooks/"
  # echo "CONFIG jupyternotebook vars DONE"

  echo "CONFIG Matomo plugin"
  ckan config-tool -s app:main $CONFIG \
  "tib_matomo.enabled = true" \
  "tib_matomo.url = https://support.tib.eu/piwik/" \
  "tib_matomo.id = 39"
  echo "CONFIG Matomo plugin DONE"

#  echo "CONFIG root_path"
#  ckan config-tool -s app:main $CONFIG "ckan.root_path = /{{LANG}}"
#  echo "CONFIG root_path DONE"

#     "ckan.views.default_views = image_view text_view recline_view videoviewer" \
#     "ckan.plugins = stats text_view image_view recline_view resource_proxy datastore datapusher webpage_view videoviewer TIBtheme dcat dcat_json_interface" \

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
#  ckan -c $CONFIG db init  
   
  echo "CREATE DOI TABLE IN DB"
#  ckan -c $CONFIG doi initdb
  
  echo "CREATE Services TABLE IN DB"
#  ckan -c $CONFIG scheming initdb
  
  echo "REBUILD SEARCH-INDEX"
  ckan -c $CONFIG search-index rebuild
  
  echo "DONE"  
fi

# Restart supervisor (CKAN WORKER)
  echo "RESTART SUPERVISOR SERVICE - CKAN WORKER"
#  . /usr/lib/ckan/default/bin/activate
#  supervisord
#  supervisorctl restart ckan-worker:*
#  service cron start

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
