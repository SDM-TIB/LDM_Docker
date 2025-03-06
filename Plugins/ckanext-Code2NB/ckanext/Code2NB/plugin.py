from ckan.plugins import SingletonPlugin, implements
from ckan.plugins.interfaces import IResourceController
import subprocess
import os
import logging
import ckan.logic as logic
import ckan.model as model
from datetime import datetime
import glob

log = logging.getLogger(__name__)


class Code2NBPlugin(SingletonPlugin):
    implements(IResourceController, inherit=True)

    def target_format(self, format):
        format_extensions = {
            'r': '.r',
            'py': '.py'
        }
        if format is None:
            return None
        normalized_format = format.lower()
        return format_extensions.get(normalized_format)

    def get_latest_notebook_path(self, notebook_dir, resource_id):
        """
        Find the latest file for a given resource_id.
        """
        pattern = os.path.join(notebook_dir, f"{resource_id}_*.ipynb")
        files = glob.glob(pattern)
        if not files:
            return None
        # Sort by date of modification and take the most recent one
        return max(files, key=os.path.getmtime)

    def process_r_file(self, context, resource):
        """Handles conversion of R files to Jupyter notebooks for both new and updated resources"""
        resource_id = resource.get("id")  # Unique resource ID
        base_name = resource.get("name", "")  # Extract file name
        format = resource.get("format")
        package_id = resource.get("package_id")  # Get the dataset ID
        log.info(f"Processing file: {base_name} for resource {resource_id}")
        extension = self.target_format(format)
        if extension:
            try:
                # Search for a related notebook
                package = logic.get_action("package_show")(
                    context, {"id": package_id}
                )
                related_notebook = None
                for res in package.get('resources', []):
                    if (res.get('format', '').lower() == 'ipynb' and
                            res.get('r_source_id') == resource_id):
                        related_notebook = res
                        break

                # Convert resource_id into CKAN's storage path format
                folder1 = resource_id[:3]  # First 3 characters
                folder2 = resource_id[3:6]  # Next 3 characters
                structured_resource_path = f"{folder1}/{folder2}/{resource_id[6:]}"
                # Get the complete resource path
                storage_path = os.getenv("CKAN_STORAGE_PATH", "/var/lib/ckan")
                resource_path = os.path.join(storage_path, "resources", structured_resource_path)
                log.info(f"Checking file: {resource_path}")

                # Adding (temporally) the extension .r to the resource_id
                new_r_path = resource_path + extension
                os.rename(resource_path, new_r_path)
                resource_path = new_r_path

                notebook_dir = os.path.join(storage_path, "notebook")
                if related_notebook:
                    log.info(f"Updating existing notebook: {related_notebook['id']}")

                    # Find current notebook file
                    current_notebook_path = self.get_latest_notebook_path(notebook_dir, related_notebook['id'])

                    if current_notebook_path:
                        try:
                            # Convert R file and overwrite existing notebook
                            subprocess.run(["jupytext", "--to", "notebook", resource_path,
                                            "--output", current_notebook_path], check=True)
                            log.info(f"Updated existing notebook at {current_notebook_path}")

                            # Update the resource keeping the same URL
                            updated_data = {
                                "id": related_notebook['id'],
                                "name": base_name + ' (Notebook)',
                                "r_source_id": resource_id  # Keeping the reference
                            }
                            logic.get_action("resource_update")(context, updated_data)

                        except subprocess.CalledProcessError as e:
                            log.error(f"Jupytext conversion failed: {e}")
                    else:
                        log.error(f"Could not find existing notebook file for resource {related_notebook['id']}")

                else:
                    log.info("Creating new notebook resource")
                    # Register the new .ipynb file as a new resource in CKAN
                    notebook_filename = resource_id[6:] + ".ipynb"
                    new_resource_data = {
                        "package_id": package_id,  # Dataset ID
                        "url": f"/notebook/{notebook_filename}",  # Path to new notebook
                        "format": "ipynb",
                        "name": base_name + ' (Notebook)',
                        "r_source_id": resource_id  # Add reference to R file
                    }

                    model.Session.remove()  # Ensure no old session interferes
                    model.Session.configure(bind=model.meta.engine)

                    new_resource = logic.get_action("resource_create")(context, new_resource_data)
                    hashed_notebook_filename = new_resource["id"]  # Get the hashed ID CKAN assigns to notebooks
                    log.info(f"New notebook resource created with ID: {hashed_notebook_filename}")
                    # new_resource = logic.get_action("resource_update")(context, {'last_modified':new_resource["created"]})
                    # Define the new notebook storage directory and filename
                    notebook_dir = os.path.join(storage_path, "notebook")
                    log.info(new_resource)
                    # Convert string to datetime object
                    dt_obj = datetime.strptime(new_resource["created"], "%Y-%m-%dT%H:%M:%S.%f")
                    # Format into the desired output
                    formatted_date = dt_obj.strftime("%Y-%m-%dt%H%M%S%f")
                    full_ipynb_path = os.path.join(notebook_dir, hashed_notebook_filename+'_'+formatted_date+'.ipynb')

                    # Convert R script to Jupyter Notebook
                    try:
                        subprocess.run(["jupytext", "--to", "notebook", resource_path,
                                        "--output", full_ipynb_path], check=True)
                        log.info(f"Converted {resource_path} to notebook format and saved in {full_ipynb_path}")
                        # Update the new notebook resource with the correct URL
                        name = new_resource['name'].replace(' ', '')
                        updated_data = {
                            "id": hashed_notebook_filename,
                            "url": f"https://ldm01.develop.service.tib.eu/ldmservice/dataset/{package_id}/resource/{hashed_notebook_filename}/download/{name}.{new_resource['format']}",
                            "r_source_id": resource_id,
                            "last_modified": new_resource["created"],
                            "name": new_resource['name']
                        }
                        log.info(updated_data)
                        logic.get_action("resource_update")(context, updated_data)

                    except subprocess.CalledProcessError as e:
                        log.error(f"Jupytext conversion failed: {e}")
                # Restore original R file name
                os.rename(resource_path, resource_path[:-len(extension)])

            except logic.NotFound:
                log.error(f"Package {package_id} not found")
            except Exception as e:
                log.error(f"Unexpected error during {extension} file processing: {e}")
                # Ensure that the R-file is restored in case of an error
                if resource_path.endswith(extension):
                    try:
                        os.rename(resource_path, resource_path[:-len(extension)])
                    except:
                        pass

    def find_related_notebook(self, context, resource_id, package_id):
        """
        Find the single notebook resource that is related to the given R/py resource.
        Returns the related notebook resource if found, None otherwise.
        """
        try:
            package = logic.get_action("package_show")(
                context, {"id": package_id}
            )
            for res in package.get('resources', []):
                if (res.get('format', '').lower() == 'ipynb' and
                        res.get('r_source_id') == resource_id):
                    # There is only one notebook related to each R/py file
                    return res
            # If we get here, no related notebook was found
            return None
        except logic.NotFound:
            log.error(f"Package {package_id} not found")
        except Exception as e:
            log.error(f"Error finding related notebook: {e}")

        return None

    def delete_notebook_files(self, notebook_resource_id):
        """
        Delete all the notebook files associated with a notebook resource.
        """
        storage_path = os.getenv("CKAN_STORAGE_PATH", "/var/lib/ckan")
        notebook_dir = os.path.join(storage_path, "notebook")

        # Find all notebook files for this resource
        pattern = os.path.join(notebook_dir, f"{notebook_resource_id}_*.ipynb")
        notebook_files = glob.glob(pattern)

        for file_path in notebook_files:
            try:
                os.remove(file_path)
                log.info(f"Deleted notebook file: {file_path}")
            except Exception as e:
                log.error(f"Failed to delete notebook file {file_path}: {e}")

    def before_delete(self, context, resource_dict, resources):
        """
        Triggered before a resource is deleted.
        If the resource is an R or Python file, find and delete the single associated notebook resource.
        """
        resource_id = resource_dict.get("id")
        package_id = None
        target_resource = None
        log.info(resource_dict)
        for res in resources:
            if res.get('id', '') == resource_id:
                target_resource = res
                package_id = res.get("package_id")
                break
        format = target_resource.get("format")

        # Check if this is an R or Python file that might have a related notebook
        extension = self.target_format(format)
        if not extension:
            # Not an R or Python file, so there's no need to look for related notebooks
            log.info(f"Resource {resource_id} is not an R or Python file - no notebook to delete")
            return

        log.info(f"Checking for notebook to delete for resource: {resource_id} with format: {format}")

        try:
            # Find the single related notebook resource
            related_notebook = self.find_related_notebook(context, resource_id, package_id)

            if related_notebook:
                notebook_id = related_notebook['id']
                log.info(f"Found related notebook with ID: {notebook_id} - will delete")

                # Delete all associated notebook files
                self.delete_notebook_files(notebook_id)

                # Delete the notebook resource from CKAN
                try:
                    logic.get_action("resource_delete")(
                        context, {"id": notebook_id}
                    )
                    log.info(f"Successfully deleted related notebook resource: {notebook_id}")
                except Exception as e:
                    log.error(f"Failed to delete related notebook resource {notebook_id}: {e}")
            else:
                log.info(f"No related notebook found for resource {resource_id}")

        except Exception as e:
            log.error(f"Error in before_delete hook: {e}")

    def after_update(self, context, resource):
        """Triggered after a resource is updated"""
        self.process_r_file(context, resource)

    def after_create(self, context, resource):
        """Triggered after a new resource is added"""
        self.process_r_file(context, resource)
