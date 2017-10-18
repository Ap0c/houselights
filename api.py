# ----- Imports ----- #

from flask import Blueprint, jsonify, request
import hue


# ----- Setup ----- #

api = Blueprint('api', __name__)


# ----- Functions ----- #

@api.route('/lights', methods=['GET'])
def get_lights():

    return jsonify({ "data": hue.scan() })

@api.route('/lights/hue/<int:hue_id>', methods=['PATCH', 'PUT'])
def update_light(hue_id):

    light = request.get_json()
    hue.update_light(hue_id, light)

    return 'nice'
