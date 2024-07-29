# Changelog

# v0.4.0 - 2024-06-13
- Add feature to set the default query via the admin interface
- Verify default query
  - Syntactically using the parser of `DeTrusty`
  - Semantically by decomposing the query with `DeTrusty`
- Update German translation

# v0.3.3 - 2024-06-07
- Update `DeTrusty` to `v0.15.6`

# v0.3.2 - 2024-06-04
- Add bottom margin to SPARQL interface

# v0.3.1 - 2024-05-24
- Fix overwrite of some styles

# v0.3.0 - 2024-04-19
- Add dummy interface for removing knowledge graphs from the federation
- Add dummy interface for adding knowledge graphs to the federation
- Update German translation
- Add hyperlinks for the knowledge graphs of the federation in the admin page
- Update style of the table in the admin page
- Fix admin page causing FedORKG being marked as active tab

# v0.2.2 - 2024-04-12
- Update `DeTrusty` to `v0.15.4`
- Add footer

# v0.2.1 - 2024-04-10
- Choose admin tab icon based on CKAN version

# v0.2.0 - 2024-04-09
- Add first simple version of an admin interface
- Add internationalization support
- Add German translation
- Update `DeTrusty` to `v0.15.3`
- Fix `SetuptoolsDeprecationWarning`
  - The `namespace_packages` parameter is deprecated.
  - Replace its usage with implicit namespaces (PEP 420).

# v0.1.2 - 2024-04-08
- Fix breadcrumb URL for systems using a proxy

# v0.1.1 - 2024-03-13
- Fix navbar URL for systems using a proxy
- Use `toolkit.render()`
- Include `static` and `templates` as `package_data`

# v0.1.0 - 2024-02-14
- Prototype version