"""
Updates local data - used to sync data between modules
"""

import json
from threading import Lock
from filelock import FileLock

CONFIG_FILENAME = "./koruza_v2/config/config.json"

def get_config():
    """Return read config"""
    return load_json_file(CONFIG_FILENAME)

def load_json_file(filename):
    """Loads json file"""
    with FileLock(filename + ".lock"):
        with open(filename) as data_file:
            return json.load(data_file)