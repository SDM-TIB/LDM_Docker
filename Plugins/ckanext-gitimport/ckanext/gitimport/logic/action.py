import ckan.plugins.toolkit as tk
import ckanext.gitimport.logic.schema as schema


@tk.side_effect_free
def gitimport_get_sum(context, data_dict):
    tk.check_access(
        "gitimport_get_sum", context, data_dict)
    data, errors = tk.navl_validate(
        data_dict, schema.gitimport_get_sum(), context)

    if errors:
        raise tk.ValidationError(errors)

    return {
        "left": data["left"],
        "right": data["right"],
        "sum": data["left"] + data["right"]
    }


def get_actions():
    return {
        'gitimport_get_sum': gitimport_get_sum,
    }
