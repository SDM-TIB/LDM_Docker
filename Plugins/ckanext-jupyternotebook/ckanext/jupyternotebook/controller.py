import ckan.lib.base as base
import ckan.logic as logic
import ckan.model as model
from ckan.common import request, config
from ckan.plugins import toolkit
import os
import requests
# import docker
import logging

log = logging.getLogger(__name__)

DEFAULT_TIMEOUT = 'ckanext.jupyternotebook.timeout'
DEFAULT_MAX_USER = 'ckanext.jupyternotebook.max_user'
DEFAULT_CPU_PERCENTAGE = 'ckanext.jupyternotebook.cpu'
DEFAULT_MEMORY_LIMIT = 'ckanext.jupyternotebook.memory'
API_URL = os.getenv('CKAN_API_JUPYTERHUB')


def restart_jupyterhub():
    response = requests.get(API_URL + '/restart_jupyterhub')
    log.info(f"Response: {response}")
    if response.status_code == 200:
        result = response.text
        if result == 'True':
            return True
    return False

def update_env_variable(key, value):
    """Update environment variable"""
    try:
        os.environ[key] = str(value)
        return True
    except Exception as e:
        log.error(f"Error updating environment variable {key}: {str(e)}")
        return False


class JupyterHubController:

    def __init__(self):
        pass
        # self.docker_client = docker.from_env()

    # def restart_jupyterhub(self):
    #     """Restart the main JupyterHub container using os.system"""
    #     try:
    #         result = os.system('docker restart jupyterhub')
    #         if result == 0:
    #             log.info("JupyterHub container successfully restarted")
    #             return True
    #         else:
    #             log.error("Error restarting JupyterHub container")
    #             return False
    #     except Exception as e:
    #         log.error(f"Error restarting JupyterHub: {str(e)}")
    #         return False

    # def restart_jupyterhub(self):
    #     """Restart the main JupyterHub container"""
    #     return True
        # try:
        #     # Get container directly by name since we know it from docker-compose
        #     container = self.docker_client.containers.get('jupyterhub')
        #     container.restart()
        #     log.info("JupyterHub container successfully restarted")
        #     return True
        # except docker.errors.APIError as e:
        #     log.error(f"Docker API error while restarting JupyterHub: {str(e)}")
        #     return False
        # except Exception as e:
        #     log.error(f"Error restarting JupyterHub container: {str(e)}")
        #     return False

    @staticmethod
    def get_jupyterhub_env_variable(variable_name, default=''):
        """
        Retrieve a JupyterHub-related environment variable.

        :param variable_name: Name of the environment variable
        :param default: Default value if environment variable is not set
        :return: Value of the environment variable or default
        """
        return os.getenv(variable_name, default)


    @staticmethod
    def validate_inputs(timeout, max_user, cpu, memory):
        """Validate all input values with specific ranges and requirements"""
        try:
            # Convert and validate timeout
            timeout = int(timeout)
            if timeout < 5:
                raise ValueError("Timeout must be at least 5 seconds")

            # Convert and validate max_user
            max_user = int(max_user)
            if max_user <= 0:
                raise ValueError("Maximum users must be greater than 0")

            # Convert and validate CPU
            cpu = int(cpu)
            if cpu < 1 or cpu > 100:
                raise ValueError("CPU percentage must be between 1 and 100")

            # Validate memory format and value
            if not memory.endswith(('M', 'G')):
                raise ValueError("Memory must end with M or G")

            # Extract numeric value from memory string
            memory_value = int(memory[:-1])
            if memory_value <= 0:
                raise ValueError("Memory value must be greater than 0")

            # Return validated values
            return timeout, max_user, cpu, memory

        except ValueError as e:
            raise ValueError(str(e))

    def admin(self):
        context = {
            'model': model,
            'session': model.Session,
            'user': toolkit.c.user,
            'auth_user_obj': toolkit.c.userobj
        }
        try:
            logic.check_access('sysadmin', context, {})
        except logic.NotAuthorized:
            base.abort(403, toolkit._('Need to be system administrator to administer.'))

        if request.method == 'POST':
            action = request.form.get('action')
            if action == 'default_setup':
                # Get form values
                timeout = request.form.get(DEFAULT_TIMEOUT, '')
                max_user = request.form.get(DEFAULT_MAX_USER, '')
                cpu = request.form.get(DEFAULT_CPU_PERCENTAGE, '')
                memory = request.form.get(DEFAULT_MEMORY_LIMIT, '').strip()

                try:
                    # Validate all inputs
                    timeout, max_user, cpu, memory = self.validate_inputs(
                        timeout, max_user, cpu, memory
                    )

                    # Update environment variables
                    updates = {
                        'CKAN_JUPYTERHUB_TIMEOUT': str(timeout),
                        'CKAN_JUPYTERHUB_USER': str(max_user),
                        'CKAN_JUPYTERHUB_PERCENTAGE_CPU': str(cpu),
                        'CKAN_JUPYTERHUB_MEMORY_LIMIT': memory
                    }

                    success = True
                    for key, value in updates.items():
                        if not update_env_variable(key, value):
                            success = False
                            break

                    # update_env_variable in jupyterhub container
                    requests.get(API_URL + '/update_env_variable', params=updates)


                    # if success and restart_jupyterhub():
                    #     toolkit.h.flash_success(
                    #         toolkit._('JupyterHub settings have been updated and service restarted.'))
                    if success:
                        toolkit.h.flash_success(toolkit._('JupyterHub settings have been updated.'))
                    else:
                        toolkit.h.flash_error(toolkit._('Error updating JupyterHub settings.'))

                except ValueError as e:
                    toolkit.h.flash_error(f"Invalid input: {str(e)}")

        # Get current values for display
        extra_vars = {
            'timeout': self.get_jupyterhub_env_variable('CKAN_JUPYTERHUB_TIMEOUT'),
            'max_user': self.get_jupyterhub_env_variable('CKAN_JUPYTERHUB_USER'),
            'cpu': self.get_jupyterhub_env_variable('CKAN_JUPYTERHUB_PERCENTAGE_CPU'),
            'memory': self.get_jupyterhub_env_variable('CKAN_JUPYTERHUB_MEMORY_LIMIT')
        }

        return toolkit.render('admin_jupyter.html', extra_vars=extra_vars)
