ld_dir('/data/rdf-dump', '*.nt', 'http://localhost:8891/');
rdf_loader_run();
exec('checkpoint');
WAIT_FOR_CHILDREN;
