# ----- Imports ----- #

from phue import Bridge
from config import HUE_BRIDGE_IP, HUE_BRIDGE_USERNAME


# ----- Setup ----- #

bridge = Bridge(ip=HUE_BRIDGE_IP, username=HUE_BRIDGE_USERNAME)
OPTIONAL_STATE = ['hue', 'sat', 'effect']


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


def scan():

    lights = bridge.get_light()
    return [_parse_light(id, light) for id, light in lights.items()]


def update_light(hue_id, props):

    if 'name' in props:
        bridge.set_light(hue_id, 'name', props['name'])

    batch_props = {k: v for k, v in props.items() if k != 'name'}

    if batch_props:
        bridge.set_light(hue_id, batch_props)


def update_lights(lights, props):

    batch_props = {k: v for k, v in props.items() if k != 'name'}

    int_lights = list(map(int, lights))

    if batch_props:
        bridge.set_light(int_lights, batch_props)


