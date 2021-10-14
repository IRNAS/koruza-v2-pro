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

def set_config(key, value):
    """Set config of (key, value) pair"""
    config = load_json_file(CONFIG_FILENAME)
    try:
        with FileLock(CONFIG_FILENAME + ".lock"):
            with open(CONFIG_FILENAME, "w") as config_file:
                config[key] = value
                json.dump(config, config_file, indent=4)
    except Exception as e:
        print(f"Error setting {key}:{value}: {e}")

def load_json_file(filename):
    """Loads json file"""
    with FileLock(filename + ".lock"):
        with open(filename) as data_file:
            return json.load(data_file)