# ----- Imports ----- #

from flask import Blueprint, jsonify, request
import hue
import db


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

    return '', 204


@api.route('/groups/new_group', methods=['POST'])
def new_group():

    group = request.get_json()
    db.add_group(group['name'], group['lights'])

    return '', 204
