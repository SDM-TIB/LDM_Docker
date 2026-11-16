#!/bin/bash
set -a && source .env && set +a

if [ "$1" == "--all" ]; then
  CACHE_FLAG="--no-cache"
else
  CACHE_FLAG="--no-cache-filter final"
fi

docker build \
  $CACHE_FLAG \
  --target final \
  --build-arg CKAN_VER=$CKAN_VERSION \
  --build-arg CKAN_HOME_L=$CKAN_HOME \
  --build-arg CKAN_STORAGE_PATH_L=$CKAN_STORAGE_PATH \
  --build-arg CKAN_CONFIG_L=$CKAN_CONFIG \
  --build-arg CKAN_DEBUG_L=$CKAN_DEBUG \
  -t ckan:latest .

