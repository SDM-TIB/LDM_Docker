
import ckan.lib.base as base
import ckan.logic as logic
import ckan.model as model
from DeTrusty.Decomposer import Decomposer
from ckan.common import request, config
from ckan.plugins import toolkit

DEFAULT_QUERY_KEY = 'ckanext.fedorkg.query'
DEFAULT_QUERY_NAME_KEY = 'ckanext.fedorkg.query.name'


class FedORKGController:

    @staticmethod
    def admin():
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

        from ckanext.fedorkg.views import detrusty_config
        msg = ''
        error = False
        if request.method == 'POST':
            action = request.form.get('action')
            if action == 'default_query':
                query = request.form.get(DEFAULT_QUERY_KEY, '').strip().replace('\r\n', '\n')
                query_name = request.form.get(DEFAULT_QUERY_NAME_KEY, '').strip()
                if query != '' and query_name != '':
                    decomposed_query = None
                    try:
                        decomposed_query = Decomposer(query, detrusty_config).decompose()
                    except:
                        error = True
                        msg = toolkit._('The query is malformed. Please, check your syntax.')

                    if not error:
                        if decomposed_query is None:
                            error = True
                            msg = toolkit._('The query cannot be answer by the federation of FedORKG.')
                        else:
                            logic.get_action(u'config_option_update')({
                                u'user': toolkit.c.user
                            }, {
                                DEFAULT_QUERY_KEY: query.replace('\n', '\\n'),
                                DEFAULT_QUERY_NAME_KEY: query_name
                            })
                else:
                    error = True
                    msg = toolkit._('The default query and its name are required.')
            else:
                kg = request.form.get('kg')
                if action == '0':
                    # TODO: Try to delete the KG from the federation and set error state accordingly
                    if error:
                        msg = toolkit._('There was an error when deleting {kg} from the federation!').format(kg=kg)
                    else:
                        msg = toolkit._('Successfully removed {kg} from the federation!').format(kg=kg)
                    # TODO: Remove after implementing the deletion of a KG from the federation
                    error = True
                    msg = 'This feature is not yet implemented.'
                elif action == '1':
                    # TODO: Try to add the KG to the federation and set error state accordingly
                    if error:
                        msg = toolkit._('There was an error when adding {kg} from the federation!').format(kg=kg)
                    else:
                        msg = toolkit._('Successfully added {kg} from the federation!').format(kg=kg)
                    error = True
                    msg = 'This feature is not yet implemented.'

        return toolkit.render('admin.jinja2',
                              extra_vars={
                                  'query': config.get(DEFAULT_QUERY_KEY).strip().replace('\\n', '\n'),
                                  'query_name': config.get(DEFAULT_QUERY_NAME_KEY).strip().replace('\\n', '\n'),
                                  'kgs': sorted(list(detrusty_config.getEndpoints().keys())),
                                  'msg': msg,
                                  'error': error
                              })
