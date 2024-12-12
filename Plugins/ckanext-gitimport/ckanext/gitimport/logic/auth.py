import ckan.plugins.toolkit as tk


@tk.auth_allow_anonymous_access
def gitimport_get_sum(context, data_dict):
    return {"success": True}


def get_auth_functions():
    return {
        "gitimport_get_sum": gitimport_get_sum,
    }
