#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    CREATE ROLE datastore_ro NOSUPERUSER NOCREATEDB NOCREATEROLE LOGIN PASSWORD '$DS_RO_PASS';
	CREATE USER datastore_default PASSWORD 'datastore';
    CREATE DATABASE datastore_default;
    GRANT ALL PRIVILEGES ON DATABASE datastore_default TO $POSTGRES_USER;
EOSQL


# Load TIB data examples
echo "Executing scripts"
echo "Executing ckan.sql script"

psql -U "$POSTGRES_USER" -d ckan -f /etc/ckan_examples.sql

echo "Executing datastore.sql script"
psql -U "$POSTGRES_USER" -d datastore_default -f /etc/datastore.sql

echo "Done scripts"