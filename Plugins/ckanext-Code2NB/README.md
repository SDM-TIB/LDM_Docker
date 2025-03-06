# ckanext-Code2NB

This CKAN extension automatically converts R and Python script files (.r and .py) uploaded to CKAN into interactive Jupyter notebooks (.ipynb). The plugin creates and maintains a relationship between the original script files and their notebook versions, making it easier for users to explore and work with code-based resources interactively.

## Features

- Automatic conversion of R and Python files to Jupyter notebooks when uploaded to CKAN
- Maintains linked relationships between source code files and their notebook versions
- Updates associated notebooks when source files are modified
- Automatic cleanup of notebook resources when source files are deleted
- Proper handling of file versioning with timestamps

## Requirements

- jupytext (for conversion between script formats and notebooks)
- Access to CKAN's file storage

## Installation

As usual for CKAN extensions, you can install `ckanext-Code2NB` as follows:

```bash
git clone git@github.com:SDM-TIB/ckanext-Code2NB.git
pip install -e ./ckanext-Code2NB
```


Add `Code2NB` to the `ckan.plugins` setting in your CKAN configuration file:
```
ckan.plugins = ... code2nb
```

## Configuration

The plugin requires the following environment variables to be set:

- `CKAN_STORAGE_PATH`: Path to CKAN's storage directory (default: `/var/lib/ckan`)

Example configuration in your `.env` file:
```
CKAN_STORAGE_PATH=/var/lib/ckan
```

## How it works

1. When a user uploads or updates an R (.r) or Python (.py) file to a CKAN dataset:
   - The plugin detects the file format
   - The file is temporarily renamed to include the appropriate extension
   - A Jupyter notebook is created from the code file using jupytext

2. For new files:
   - A new resource is created in the same dataset with format "ipynb"
   - The notebook includes a reference back to its source code file
   - The notebook file is stored in the CKAN storage with a timestamp

3. For updated files:
   - The plugin finds the associated notebook resource
   - The notebook file is updated with the new content from the source file
   - The resource metadata is updated accordingly

4. When a source code file is deleted:
   - The plugin identifies and deletes the associated notebook resource
   - All related notebook files are removed from storage

## License

`ckanext-Code2NB` is licensed under GPL-3.0, see the [license file](LICENSE).
