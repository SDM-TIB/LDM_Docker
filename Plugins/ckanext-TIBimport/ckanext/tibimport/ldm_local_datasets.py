from ckan.plugins import toolkit
import ckan.model as model
import ckan.logic as logic

NotFound = logic.NotFound


class LDMLocalDatasets:

    def __init__(self):
                
        # CKAN's API Actions
        self.action_package_show = toolkit.get_action('package_show')
        # Allow unauthorized ejecution
        toolkit.auth_allow_anonymous_access(self.action_package_show)
    
    # LOCAL CKAN INTERACTION
    # **********************

    def get_LDM_dataset(self, name):
        # https://docs.ckan.org/en/2.9/api/#ckan.logic.action.get.package_show
        # Note: Returns data even with dataset deleted => ds['state'] = 'deleted'
        params = {'id': name}
        context = {'model': model, 'session': model.Session, 'ignore_auth': True, 'user': 'admin'}
        
        try:
            result = self.action_package_show(context, params)
        except NotFound as e:
            return {}
        return result
    
    def insert_ldm_dataset(self):

        pass