# Changelog

# v0.7.3 - 2024-12-10
- Update `DeTrusty` to `v0.19.0`

# v0.7.2 - 2024-11-29
- Rename admin interface template to avoid conflicts with other extensions

# v0.7.1 - 2024-11-27
- Add bottom margin for the 'ask' button
- Fix width of natural language question input field
- Fix the size of the DeTrusty icon in the footer
- Fix the marker for the LLM feature drop down for CKAN 2.9
- Update `DeTrusty` to `v0.18.3`
- Update German translation

# v0.7.0 - 2024-10-17
- Add federation management to the admin interface
- Update `DeTrusty` to `v0.18.2`
- Update German translation

# v0.6.1 - 2024-10-10
- Fix reading query timeout from config

# v0.6.0 - 2024-10-07
- Update `DeTrusty` to `v0.17.0`
- Add query timeout feature
  - Default is 60 seconds
  - Timeout is shown in the query interface
  - Timeout can be changed from the admin interface
- Update German translation

# v0.5.1 - 2024-10-07
- Fix footer alignment issue in different versions of CKAN

# v0.5.0 - 2024-10-02
- Include the logo of `DeTrusty` in the footer
- Add experimental feature `LLM-based Question Answering`

# v0.4.2 - 2024-07-29
- Update `DeTrusty` to `v0.16.1`

# v0.4.1 - 2024-07-23
- Update `DeTrusty` to `v0.16.0`
- Use `toolkit.c.user` instead of `common.current_user.name`
- Fix setting of default values for the default query and its name

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