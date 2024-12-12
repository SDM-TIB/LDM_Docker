
import ckan.lib.helpers as h


def is_fedorkg_page():
    return False if 'ckan-admin' in h.current_url() else '/fedorkg' in h.current_url()  # exclude the admin page
