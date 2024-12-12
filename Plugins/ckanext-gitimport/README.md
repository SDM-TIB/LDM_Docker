# ckanext-gitimport
The CKAN GitImport Plugin enables users to fetch and display GitHub repository metadata within a specialized "GitHub" template in the CKAN user interface. After the metadata is displayed, it can be stored within CKAN datasets. This plugin streamlines the process of linking GitHub repositories with CKAN datasets, making it more efficient and user-friendly.

## Features
- **Fetch GitHub Repository Metadata**: Automatically retrieves metadata from GitHub repositories by simply adding the repository name then pressing the "Fetch Metadata" button.
- **Dynamic Field Population**: Dynamically populates CKAN dataset fields with fetched GitHub metadata, such as contributors, topics, etc., as needed.
- **User-Friendly Interface**: Seamlessly integrates with CKAN's UI.

## Requirements
Compatibility with core CKAN versions:

| CKAN version    | Compatible?   |
| --------------- | ------------- |
| 2.10            | yes           |
| 2.9 and earlier | not tested    |

## Installation

To install ckanext-gitimport:

1. Activate your CKAN virtual environment, for example:

     . /usr/lib/ckan/default/bin/activate

2. Clone the source and install it on the virtualenv

    git clone https://github.com/Sakor99/ckanext-gitimport
    cd ckanext-gitimport
    pip install -e .
	pip install -r requirements.txt


3. Restart CKAN. For example if you've deployed CKAN with Apache on Ubuntu:

     sudo service apache2 reload

## Config settings

1. Add the plugin `gitimport` to the `ckan.plugins` list in the CKAN config file`ckan-entrypoint.sh`.
  
3. Add the yaml File `ckanext.scheming:ckan_github.yaml` to the `scheming.dataset_schemas` list in the CKAN config file `ckan-entrypoint.sh`.
  
4. The plugin requires a GitHub access token to fetch repository data. Please ensure that the token is valid as they usually expire after a certain time. You will need to regenerate a new token periodically to maintain functionality.

5. Add your GitHub access token to the CKAN config file(ckan-entrypoint.sh):

    ckanext.gitimport.github_access_token = YOUR_GITHUB_ACCESS_TOKEN 

    

## How it works?
To use the plugin:

1. In your CKAN instance, access the "GitHub Import" button in navigation bar.
2. Then click on "Add GitHub" where you will find the template.
3. Enter the GitHub repository name (e.g., Sakor99/ckanext-gitimport) in the provided template field then press the "Fetch Metadata" button.
4. The plugin will then fetch and display the repository metadata.

## Note
This plugin is designed to work with the "GitHub" template, which is created using the ckanext-scheming extension. The template consists of a YAML file that details the schema and the necessary HTML files. Ensure that ckanext-scheming is also installed and properly configured in your CKAN instance.
