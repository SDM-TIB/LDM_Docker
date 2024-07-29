#!/usr/bin/env python3
#
# Description: GET service for getting free guest users.
#


from flask import Flask, make_response
import json
import logging
import jupyterhub_api as hub_api
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

app = Flask(__name__)


@app.route('/get_user', methods=['GET'])
def d_recommendation():
    usr = hub_api.get_free_user()
    response = {'user': usr}
    r = json.dumps(response, indent=4)
    response = make_response(r, 200)
    response.mimetype = "application/json"
    return response


if __name__ == '__main__':
    app.run(host='jupyterhub', port=6000)
    # app.run(host='0.0.0.0', port=5500)