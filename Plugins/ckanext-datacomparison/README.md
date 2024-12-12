[![Latest Release](http://img.shields.io/github/release/SDM-TIB/ckanext-datacomparison.svg?logo=github)](https://github.com/SDM-TIB/ckanext-datacomparison/releases)
[![License: AGPL v3](https://img.shields.io/github/license/SDM-TIB/ckanext-datacomparison?color=blue)](LICENSE.md)

[![CKAN](https://img.shields.io/badge/ckan-2.10-orange.svg?style=flat-square)](https://github.com/ckan/ckan/tree/2.10) [![CKAN](https://img.shields.io/badge/ckan-2.9-orange.svg?style=flat-square)](https://github.com/ckan/ckan/tree/2.9)

# Data Comparison

`ckanext-datacomparison` is a CKAN plugin replacing the original _Data Explorer_.
This extension is inspired by the _Data Explorer React_ ([https://github.com/datopian/ckanext-dataexplorer-react](https://github.com/datopian/ckanext-dataexplorer-react)).

The main feature of `ckanext-datacomparison` is the capability to compare data across resources.
The visualizations are powered by [plotly.js](https://github.com/plotly/plotly.js/).

The following view plugins are part of `ckanext-datacomparison`:
- `datacomparison_view` the view plugin providing the feature of comparing data across resources
- `datacomparison_explorer_view` a view plugin acting like the _Data Explorer_ using the same code basis as the comparison view

> [!NOTE]
> The current version of `datacomparison_explorer_view` uses the first column of each resource for merging the data.

## Installation

As usual for CKAN extensions, you can install `ckanext-fedorkg` as follows:

```bash
git clone git@github.com:SDM-TIB/ckanext-datacomparison.git
pip install -e ./ckanext-datacomparison
pip install -r ./ckanext-fedorkg/requirements.txt
```

Afterward, add `datacomparison_view` and/or `datacomparison_explorer_view` to the plugins in your `ckan.ini`.

## Changelog

If you are interested in what has changed, check out the [changelog](CHANGELOG.md).

## License

`ckanext-datacomparison` is licensed under AGPL-3.0, see the [license file](LICENSE.md).
