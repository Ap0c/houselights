# ----- Imports ----- #

from flask import Blueprint, jsonify
import hue


# ----- Setup ----- #

api = Blueprint('api', __name__)


# ----- Functions ----- #

@api.route('/lights', methods=['GET'])
def lights():

    return jsonify({ "lights": hue.scan() })
