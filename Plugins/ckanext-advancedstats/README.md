[![CKAN](https://img.shields.io/badge/ckan-2.10-orange.svg?style=flat-square)](https://github.com/ckan/ckan/tree/2.10) [![CKAN](https://img.shields.io/badge/ckan-2.9-orange.svg?style=flat-square)](https://github.com/ckan/ckan/tree/2.9)

# Advanced Stats

`ckanext-advancedstats` is a CKAN plugin that adds support to query open research knowledge graphs via SPARQL queries.
FedORKG uses [DeTrusty](https://github.com/SDM-TIB/DeTrusty/) as federated query engine.
The visual query editor connecting the frontend and DeTrusty is implemented using the JavaScript library [YASGUI](https://github.com/TriplyDB/yasgui).

## Installation

As usual for CKAN extensions, you can install `ckanext-fedorkg` as follows:

```bash
git clone git@github.com:SDM-TIB/ckanext-advancedstats.git
pip install -e ./ckanext-advancedstats
pip install -r ./ckanext-advancedstats/requirements.txt
```

After installing the plugin, add `advancedstats` to the plugins in your `ckan.ini`.


## Changelog

If you are interested in what has changed, check out the [changelog](CHANGELOG.md).

## License

`ckanext-advancedstats` is licensed under GPL-3.0, see the [license file](LICENSE).
