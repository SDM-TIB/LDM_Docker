#!/usr/bin/env python3
#
# Description: POST service for
#
from flask import Flask, request, jsonify
import plugin  # Import the plugin.py script

app = Flask(__name__)

# Endpoint to remove a session from the user dictionary
@app.route('/rm_session_user', methods=['POST'])
def remove_user():
    data = request.json
    user_id = data.get('username')

    # Call the function from plugin.py to remove user from session_dict
    if plugin.remove_session_to_user(user_id):
        return jsonify({'message': 'Session removed successfully from user_session dictionary'}), 200
    else:
        return jsonify({'message': 'User not found in user_session dictionary'}), 404

if __name__ == '__main__':
    app.run(host='ckan', port=6500)