# ----- Imports ----- #

from phue import Bridge
from config import HUE_BRIDGE_IP


# ----- Setup ----- #

bridge = Bridge(HUE_BRIDGE_IP)
OPTIONAL_STATE = ['hue', 'sat', 'effect']
CONSTANT_STATE = ['hue_id', 'name']


# ----- Functions ----- #

def _parse_light(hue_id, raw_light):

    light = {
        "hue_id": hue_id,
        "name": raw_light['name'],
        "on": raw_light['state']['on'],
        "bri": raw_light['state']['bri']
    }

    for prop in OPTIONAL_STATE:

        if prop in raw_light['state']:
            light[prop] = raw_light['state'][prop]

    return light


def _update_name(light):

    if 'name' in light:
        bridge.set_light(light['hue_id'], 'name', light['name'])


def scan():

    lights = bridge.get_light()
    return [_parse_light(id, light) for id, light in lights.items()]


def update_state(light):

    to_send = {k: v for k, v in light.items() if k not in CONSTANT_STATE}

    bridge.set_light(int(light['hue_id']), to_send)
    _update_name(light)
