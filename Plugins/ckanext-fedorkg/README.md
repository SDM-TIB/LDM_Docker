[![Latest Release](http://img.shields.io/github/release/SDM-TIB/ckanext-fedorkg.svg?logo=github)](https://github.com/SDM-TIB/ckanext-fedorkg/releases)
[![License: GPL v3](https://img.shields.io/github/license/SDM-TIB/ckanext-fedorkg?color=blue)](LICENSE.md)

[![CKAN](https://img.shields.io/badge/ckan-2.10-orange.svg?style=flat-square)](https://github.com/ckan/ckan/tree/2.10) [![CKAN](https://img.shields.io/badge/ckan-2.9-orange.svg?style=flat-square)](https://github.com/ckan/ckan/tree/2.9)

# FedORKG

`ckanext-fedorkg` is a CKAN plugin that adds support to query open research knowledge graphs via SPARQL queries.
FedORKG uses [DeTrusty](https://github.com/SDM-TIB/DeTrusty/) as federated query engine.
The visual query editor connecting the frontend and DeTrusty is implemented using the JavaScript library [YASGUI](https://github.com/TriplyDB/yasgui).

## Installation

As usual for CKAN extensions, you can install `ckanext-fedorkg` as follows:

```bash
git clone git@github.com:SDM-TIB/ckanext-fedorkg.git
pip install -e ./ckanext-fedorkg
pip install -r ./ckanext-fedorkg/requirements.txt
```

The path for the source description file of DeTrusty is:

```
$CKAN_STORAGE_PATH$/fedorkg/rdfmts.ttl
```

`$CKAN_STORAGE_PATH$` defaults to `/var/lib/ckan`.

Then add `fedorkg` to the plugins in your `ckan.ini`.

> [!NOTE]
> If you have `ckanext-scheming` installed, you have to mention `fedorkg` before the scheming extension in your `ckan.ini`.
> Otherwise the scheming extension overrides the changes of the FedORKG plugin.

### LLM-based Question Answering

> [!NOTE]
> This feature is experimental.

Powered by the LLM `o1-mini`, FedORKG is able to answer natural language questions over the federation by relying on the LLM to translate the question into a SPARQL query.
The file containing the instructions to be included in the prompt has to be located in:

```
$CKAN_STORAGE_PATH$/fedorkg/prompt.txt
```

Please, also provide your API token in an environment variable called `OPENAI_API_KEY`.

## Configuration Options

- `ckanext.fedorkg.query` the default query shown to the users
  - Default: SELECT DISTINCT ?c WHERE { ?s a ?c }
- `ckanext.fedorkg.query.name` a human-readable name for the default query
  - Default: Covered Concepts 
- `ckanext.fedorkg.timeout` query execution timeout in seconds
  - Default: 60

## Changelog

If you are interested in what has changed, check out the [changelog](CHANGELOG.md).

## License

`ckanext-fedorkg` is licensed under GPL-3.0, see the [license file](LICENSE).

## Publications

1. Philipp D. Rohde, Enrique Iglesias, Maria-Esther Vidal: _FedORKG: Accessing Federations of Open Research Knowledge Graphs_. In: 1. NFDI4Energy Conference. DOI [10.5281/zenodo.10591442](https://doi.org/10.5281/zenodo.10591442)