"""
Updates global config - used to sync file between modules
"""

import json
from threading import Lock
from filelock import FileLock

class ConfigManager():
    def __init__(self):
        """Init config manager"""
        # self.SETTINGS_FILE = "./koruza_v2/config.json"
        # self.config = self.load_json_file()
        self.lock = Lock()

        self.calibration = self.load_json_file("./koruza_v2/config/calibration.json")
        self.camera = self.load_json_file("./koruza_v2/config/camera.json")
        self.motors = self.load_json_file("./koruza_v2/config/motors.json")

    def get_calibration(self):
        """Return calibration part of json file"""
        return self.config["calibration"]

    def get_motors_position(self):
        """Return motors part of json file"""
        return self.config["motors"]

    def get_camera_config(self):
        """Return camera config part of json file"""
        return self.config["camera"]

    def update_calibration_config(self, key_value_pairs):
        """Update calibration config with given key_value_pairs"""
        print("Updating calibration config")
        self.lock.acquire()
        with FileLock("./koruza_v2/config/calibration.json" + ".lock"):
            with open("./koruza_v2/config/calibration.json", "w") as config_file:
                for key, data in key_value_pairs:
                    print(key, data)
                    self.calibration[key] = data
                    print(self.calibration)
                json.dump(self.calibration, config_file, indent=4)
        self.lock.release()

    def update_motors_config(self, key_value_pairs):
        """Update motors config with given key_value_pairs"""
        self.lock.acquire()
        with FileLock("./koruza_v2/config/motors.json" + ".lock"):
            with open("./koruza_v2/config/motors.json", "w") as config_file:
                for key, data in key_value_pairs:
                    self.motors[key] = data
                    # print(self.motors)
                json.dump(self.motors, config_file, indent=4)
        self.lock.release()

    def update_camera_config(self, key_value_pairs):
        """Update camera config with given key_value_pairs"""
        self.lock.acquire()
        with FileLock("./koruza_v2/config/camera.json" + ".lock"):
            with open("./koruza_v2/config/camera.json", "w") as config_file:
                for key, data in key_value_pairs:
                    self.camera[key] = data
                json.dump(self.camera, config_file, indent=4)
        self.lock.release()

    def load_json_file(self, filename):
        """Loads json file"""
        with FileLock(filename + ".lock"):
            with open(filename) as config_file:
                return json.load(config_file)

config_manager = ConfigManager()  # expose config manager