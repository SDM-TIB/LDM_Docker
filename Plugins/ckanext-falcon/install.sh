#!/bin/bash

# Exit if any command fails
set -e

# Activate the CKAN virtual environment
# Replace with the path to your CKAN virtual environment activation script
source /usr/lib/ckan/default/bin/activate

# Navigate to the CKAN extension directory
# Replace with the actual path to your ckanext-falcon directory
cd /usr/lib/ckan/default/src/ckanext-falcon

# Install the CKAN extension in development mode
pip install -e .

# Restart the CKAN Docker container
# Replace 'container_name' with the name of your CKAN Docker container
docker restart ckan

echo "CKAN plugin installed and Docker container restarted successfully."
