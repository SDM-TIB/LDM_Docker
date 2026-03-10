# Rust WASM RDF Graph Visualizer for CKAN

this extention for ckan enables the visiualisation of a ttl file

the wasm file create a get response to the ttl file of a called dataset and builds a graph from it

the build js and wasm files are located in ckanext/graphviewer/public/graph_viewer/

# how to build

``` bash
$ trunk build --release --dist ckanext/graphviewer/public/graph_viewer/ --filehash false
$ rm ckanext/graphviewer/public/graph_viewer/index.html
```
