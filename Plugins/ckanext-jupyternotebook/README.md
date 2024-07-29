# ckanext-jupyternotebook Plugin

This plugin integrates JupyterHub with CKAN, allowing users to execute and temporarily edit interactive Jupyter notebooks within the CKAN environment. The plugin makes data exploration and analysis more accessible and integrated.

## Features

- Seamless integration of Jupyter Notebooks within CKAN
- Temporary notebook editing and execution
- Automatic reversion of changes after a defined 
- Utilize DockerSpawner to create isolated Docker containers for each user, ensuring a secure and personalized computational environment.
- Guest user access without login
- Admin-configurable maximum number of concurrent guest users

### How it works

1. Users access Jupyter notebooks through the CKAN interface.
2. Each user is provided with a temporary, isolated Docker container.
3. Users can edit notebook cells and install libraries during their session.
4. After a predefined timeout, all changes are automatically reverted.
5. Guest users can access notebooks without logging in, subject to availability.

## License

`ckanext-jupyternotebook` is licensed under GPL-3.0, see the [license file](LICENSE).