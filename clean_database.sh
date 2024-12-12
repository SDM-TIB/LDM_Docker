#!/bin/sh
set -e

. /usr/lib/ckan/default/bin/activate
ckan -c /etc/ckan/default/ckan.ini db clean
ckan -c /etc/ckan/default/ckan.ini db init
ckan -c /etc/ckan/default/ckan.ini doi initdb
ckan -c /etc/ckan/default/ckan.ini scheming initdb
ckan -c /etc/ckan/default/ckan.ini search-index rebuild

exec "$@"