#!/bin/sh
set -e

. /usr/lib/ckan/default/bin/activate
jupyter notebook </dev/null &>/dev/null &

exec "$@"
