# ----- Imports ----- #

from flask import Blueprint, jsonify, request
import hue


# ----- Setup ----- #

api = Blueprint('api', __name__)


# ----- Functions ----- #

@api.route('/retrieve', methods=['GET'])
def retrieve():

    return jsonify({ "lights": hue.scan() })

@api.route('/update', methods=['POST'])
def update():

    light = request.get_json()
    hue.update_state(light)

    return jsonify({ "success": True })
