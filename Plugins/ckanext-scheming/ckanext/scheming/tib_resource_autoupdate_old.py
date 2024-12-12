import logging
from datetime import date
import ckan.lib.jobs as jobs
from pathlib import Path
from crontab import CronTab

log = logging.getLogger(__name__)

"""
Helper servind data for the creation of the selectbox in resources 
add/edit formulars.
"""
def get_resource_update_options():

    options = [{'value':'No', 'text': 'No'},
               {'value': 'Daily', 'text': 'Daily'},
               {'value': 'Weekly', 'text': 'Weekly'},
               {'value': 'Monthly', 'text': 'Monthly'}]

    return options

"""
    Class implementing automatic resource updates
"""
class TIB_resource_update_tool:

    def __init__(self):
        # Create CKAN's background jobs
        self._config_logger()
        self._create_ckan_background_jobs()
        self._create_cronjobs()

    def _create_ckan_background_jobs(self):
        # Create CKAN's background jobs
        jobs.enqueue(self.update_daily, title='update_resource_daily', queue='ur_day')
        jobs.enqueue(self.update_weekly, title='update_resource_weekly', queue='ur_week')
        jobs.enqueue(self.update_monthly, title='update_resource_monthly', queue='ur_month')

    def _get_run_enqueue_job_command(self, type):
        return ". /usr/lib/ckan/default/src/ckanext-scheming/ckanext/scheming/run_resource_updates.sh " + type

    def _create_cronjobs(self):
        cron = CronTab(user=True)

        # Daily Updates
        job = cron.new(command= self._get_run_enqueue_job_command('ur_day'))
        job.minute.every(1)

        # Weekly Updates
        job = cron.new(command= self._get_run_enqueue_job_command('ur_week'))
        job.minute.every(3)

        # Daily Updates
        job = cron.new(command= self._get_run_enqueue_job_command('ur_month'))
        job.minute.every(5)

    def update_daily(self):
        self._update_logger()
        log.info("Making daily resources update")
        self.logger.info("Making daily resources update")

    def update_weekly(self):
        self._update_logger()
        log.info("Making Weekly resources update")
        self.logger.info("Making weekly resources update")

    def update_monthly(self):
        self._update_logger()
        log.info("Making monthly resources update")
        self.logger.info("Making monthly resources update")

    def _config_logger(self):
        '''
            The order of logging levels is:
            DEBUG < INFO < WARNING < ERROR < CRITICAL
        '''
        logger = logging.getLogger('tibimport_resupdateprofile')
        logger.setLevel(logging.DEBUG)

        # logs directory settings
        self.log_file_path = '/usr/lib/ckan/default/src/ckanext-scheming/ckanext/scheming/logs/tib_resource_update/'
        Path(self.log_file_path).mkdir(parents=True, exist_ok=True)

        self.logger = logger
        self.logger.message = ""

    def _update_logger(self):
        log_file = date.today().strftime("%Y_%m_%d") + "_log.log"
        fh = logging.FileHandler(self.log_file_path + log_file)
        formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
        fh.setFormatter(formatter)
        fh.setLevel(logging.DEBUG)
        self.logger.handlers.clear()
        self.logger.addHandler(fh)
