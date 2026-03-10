#! /bin/bash -e

trunk build --release --dist ckanext/graphviewer/public/graph_viewer/ --filehash false
rm ckanext/graphviewer/public/graph_viewer/index.html
