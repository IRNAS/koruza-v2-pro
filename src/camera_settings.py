import math

def get_set_zoom():
    """Read set zoom from file and return it"""
    with open("/home/pi/koruza_v2/config/.camera_config", "r") as file:
        filedata = file.readlines()

    for line in filedata:
        if "IMG_P" in line:
            img_p = line.split("=")[1]
            return 1.0 / float(img_p)**2

def get_camera_settings(zoom_factor):
    """Calculate camera settings from desired zoom_factor"""
    # x and y pos of zoom are in normalised coordinates [0, 1]
    x_pos = 0
    y_pos = 0

    # zoom on x and y axis, given in percent of image, normalised [0, 1]
    image_percent = 1.0

    if zoom_factor < 1:
        return x_pos, y_pos, image_percent

    image_percent = math.sqrt(1.0 / zoom_factor)

    x_pos = (1.0 - image_percent) / 2.0
    y_pos = x_pos

    return x_pos, y_pos, image_percent

def set_camera_config(x, y, img_p):
    """Write camera config to file"""
    # Read in the file
    with open("/home/pi/koruza_v2/config/.camera_config", "r") as file:
        filedata = file.readlines()

    # Replace the target values
    new_lines = []
    for line in filedata:
        if "X" in line:
            new_line = f"X={x}\n"
        if "Y" in line:
            new_line = f"Y={y}\n"
        if "IMG_P" in line:
            new_line = f"IMG_P={img_p}"
        new_lines.append(new_line)

    # Write the file out again
    with open("/home/pi/koruza_v2/config/.camera_config", "w") as file:
        for line in new_lines:
            file.write(line)

def get_camera_config():
    """Read camera config from file and return values"""
    # Read in the file
    with open("/home/pi/koruza_v2/config/.camera_config", "r") as file:
        filedata = file.readlines()

    # Replace the target values
    config = {}
    for line in filedata:
        setting = line.split("=")
        config[setting[0].lower()] = float(setting[1])

    return config