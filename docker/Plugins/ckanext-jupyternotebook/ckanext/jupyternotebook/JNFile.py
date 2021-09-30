import re
import requests
import os
import logging
from ckan.common import config

log = logging.getLogger(__name__)

# var/lib/ckan/resources/3primerosid/3segundosis/
class JNFile:

    def __init__(self, resource_url, resource_id, resource_date, jn_filepath, jn_url, url_type="", testing=False):

        self.log_enabled = True

        self.testing_env = testing
        self.log_info("starting")

        self.url_type = url_type
        self.resource_id = resource_id
        self.local_resource_files_path = config.get('ckan.storage_path', "/var/lib/ckan") + "/resources/"

        self.resource_url = self.build_resource_url(resource_url)
        self.resource_date = resource_date
        self.filepath = jn_filepath
        self.urlbase = jn_url

        self.filefullpath = ""
        self.generate_filename()

        # Check file exists
        if not self.file_exists():
            self.get_notebooks_file()
        self.jupyternotebook_url = self.urlbase+self.filename
        self.check_notebook_server_running()


    def enable_testing(self):
        self.testing_env = True

    def build_resource_url(self, url):
        if self.url_type == "upload":
            aux = self.resource_id
            resource_path = str(self.local_resource_files_path + aux[0:3] + "/" + aux[3:6] + "/" + aux[6:])
            self.log_info("build_resource_path", resource_path)
            return resource_path
        else:
            return url


    def generate_filename(self):
        self.filename = self.get_valid_filename(self.resource_id + "_" + self.resource_date) + ".ipynb"
        self.filefullpath = self.filepath + "/" + self.filename
        self.log_info("gen_filename", self.filefullpath)

    def get_valid_filename(self, s):
        return re.sub('[^\w_)( -]', '', s).lower()

    def get_notebooks_file(self):
        # Allow access to write files
        os.chmod(self.filepath, 0o755)
        self.log_info("accessing_local_folder", self.filepath)
        self.log_info("writing_to_local_file", self.filefullpath)

        if self.url_type == "upload":
            self.get_notebooks_file_upload()
        else:
            self.get_notebooks_file_url()

        # Deny access to write files
        if self.filefullpath != "ERROR":
            os.chmod(self.filefullpath, 0o555)
        os.chmod(self.filepath, 0o555)

    def get_notebooks_file_url(self):
        file_request = False
        try:
            # get file from url
            self.log_info("getting_file", self.resource_url)

            file_request = requests.get(self.resource_url, allow_redirects=True)
        except requests.exceptions.RequestException as e:  # This is the correct syntax
            self.log_error("e_getting_file", e)

        if file_request:
            # save  file in path
            try:
                open(self.filefullpath, 'wb').write(file_request.content)
                self.log_info("writing_file_from_url_to", self.filefullpath)
            except:
                self.log_error("writing_file_from_url_to", self.filefullpath)
                self.filefullpath = "ERROR"
        else:
            self.filefullpath = "ERROR"

    def get_notebooks_file_upload(self):
        reader = open(self.resource_url, 'r')
        try:
            open(self.filefullpath, 'w').write(reader.read())
            self.log_info("getting_file_local", self.resource_url)
        except:
            self.filefullpath = "ERROR"
            self.log_error("writing_file_from_local_to", self.filefullpath)
        reader.close()

    def file_exists(self):
        res = os.path.isfile(self.filefullpath)
        self.log_info("check_file_exists", str(res))
        return res

    def check_notebook_server_running(self):
        try:
            # get file from url
            file_request = requests.get(self.jupyternotebook_url, allow_redirects=False)
        except requests.exceptions.RequestException as e:  # This is the correct syntax
            self.log_info("restarting_notebook_server")
            if not self.testing_env:
                os.system(". /usr/lib/ckan/default/src/jupyternotebook/launch_jupyternotebook.sh")
            pass

    def log_info(self, type, data=""):
        if self.log_enabled:
            msg_info = {"starting": "LAUNCHING JUPYTERNOTEBOOK PLUGIN",
                        "gen_filename": ("Generating Filename: " + data),
                        "check_file_exists": "File exists= " + data,
                        "getting_file": "Getting file form URL: " + data,
                        "build_resource_path": "Building path for uploaded file: " + data,
                        "accessing_local_folder": "Accessing local file: " + data,
                        "writing_to_local_file": "Writing to local file: " + data,
                        "writing_file_from_url_to": "Writing file from URL to file: " + data,
                        "getting_file_local": "Getting file from local folder: " + data,
                        "restarting_notebook_server": "Restarting jupyter notebook server"
                        }
            msg = msg_info[type]
            log.info(msg)

    def log_error(self, type, data=""):
        if self.log_enabled:
            msg_error = {"e_getting_file": "Error finding resource file '" + self.resource_url + "' on the web:" + str(data),
                         "writing_file_from_url_to": "Error writing from URL to file: " + str(data),
                         "writing_file_from_local_to": "Error writing from local file to file: " + str(data)
                        }
            msg = msg_error[type]
            log.error(msg)