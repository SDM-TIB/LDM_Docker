#!/bin/sh
set -e

# If we don't already have a config file (first time execution), bootstrap
if [ -d "/var/solr/data/ckan/conf" ] 
then
  echo "file exists22"
#  solr-precreate-core ckan /var/solr/data/ckan-conf
  if [ -f "/var/solr/data/schema.xml" ]
  then
    mv -f /var/solr/data/schema.xml /var/solr/data/ckan/conf/
    mv -f /var/solr/data/solrconfig.xml /var/solr/data/ckan/conf/
  fi
fi

exec "$@"