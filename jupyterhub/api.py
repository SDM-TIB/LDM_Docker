#!/usr/bin/env python3
#
# Description: GET service for getting free guest users.
#


from flask import Flask, make_response
import json
import logging
import jupyterhub_api as hub_api
logging.basicConfig(level=logging.DEBUG)
log = logging.getLogger(__name__)

app = Flask(__name__)


@app.route('/get_user', methods=['GET'])
def f1():
    usr = hub_api.get_free_user()
    response = {'user': usr}
    r = json.dumps(response, indent=4)
    response = make_response(r, 200)
    response.mimetype = "application/json"
    log.info(response)
    return response


@app.route('/running_user', methods=['GET'])
def f2():
    running_list = hub_api.get_running_users()
    return running_list


@app.route('/guest_user', methods=['GET'])
def f3():
    guest_list = hub_api.get_guest_list()
    return guest_list


if __name__ == '__main__':
    app.run(host='jupyterhub', port=6000)
    # app.run(host='0.0.0.0', port=5500)