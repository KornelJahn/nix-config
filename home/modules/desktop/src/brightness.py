from argparse import ArgumentParser
from subprocess import run

GAMMA = 2.4
LEVEL_COUNT = 11

MAX_LEVEL = LEVEL_COUNT - 1
MAX_BRIGHTNESS = 255


# Helper functions

def get_level():
    global MAX_BRIGHTNESS
    kwargs = dict(universal_newlines=True, capture_output=True)
    values = run(["brightnessctl", "-m", "i"], **kwargs).stdout.split(",")
    brightness, MAX_BRIGHTNESS = int(values[2]), int(values[4])
    return round(MAX_LEVEL * (brightness / MAX_BRIGHTNESS)**(1/GAMMA))


def step_level(increment):
    level = limit_level(get_level() + increment)
    brightness = round(MAX_BRIGHTNESS * (level / MAX_LEVEL)**GAMMA)
    run(["brightnessctl", "-q", "s", str(brightness)])
    return level


def limit_level(level):
    return max(0, min(MAX_LEVEL, level))


def osd_value(level):
    return round(100 * level / MAX_LEVEL)


# Actions

def get():
    return osd_value(get_level())


def inc():
    return osd_value(step_level(1))


def dec():
    return osd_value(step_level(-1))


parser = ArgumentParser()
parser.add_argument("action", choices=["get", "inc", "dec"])
args = parser.parse_args()
print(globals()[args.action]())
