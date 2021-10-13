import math
from PIL import Image, ImageDraw

def get_set_zoom():
    """Read set zoom from file and return it"""
    with open("/home/pi/koruza_v2/config/.camera_config", "r") as file:
        filedata = file.readlines()

    for line in filedata:
        if "IMG_P" in line:
            img_p = line.split("=")[1]
            return 1.0 / float(img_p)**2

def calculate_camera_config(zoom_factor):
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

def calculate_zoom_area_position(marker_x, marker_y, img_p):
    """Get zoom area upper left corner from marker position"""
    print(f"Calculating zoom area position from marker_x: {marker_x}, marker_y: {marker_y}, img_p: {img_p}")
    # print(f"Marker x: {marker_x}")
    # print(f"Marker y: {marker_y}")
    if img_p == 1.0:
        return 0, 0, 0, 0
    x = marker_x / 720 - img_p / 2
    y = 1.0 - (marker_y / 720) - img_p / 2
    # print(f"New x pos: {x}")
    # print(f"New y pos: {y}")

    return x, y, clamp(x, 0.0, 1-img_p), clamp(y, 0.0, 1-img_p)

def clamp(n, smallest, largest): 
    return max(smallest, min(n, largest))

def calculate_marker_pos(x, y, img_p):
    # move marker if zoomed in image is outside of bounds
    print(f"Calculating marker position from: {x} {y}")
    if x < 0:
        marker_x = 360.0 + ((1 / img_p) * x * 720.0)
    elif x > 1 - img_p:
        marker_x = 360.0 + ((1 / img_p) * (x - (1 - img_p))) * 720.0
    else:
        marker_x = 360.0
    
    if y < 0:
        marker_y = 360.0 - ((1 / img_p) * y * 720.0)
    elif y > 1 - img_p:
        marker_y = 360.0 - ((1 / img_p) * (y - (1 - img_p))) * 720.0
    else:
        marker_y = 360.0

    return marker_x, marker_y

def generate_marker(pos_x, pos_y, SQUARE_SIZE):
    marker_lb_rt = {
        "type": "line",
        "x0": pos_x - (SQUARE_SIZE / 2),
        "y0": pos_y - (SQUARE_SIZE / 2),
        "x1": pos_x + (SQUARE_SIZE / 2),
        "y1": pos_y + (SQUARE_SIZE / 2),
        "line": {
            "color": "#ff0000",
            "opacity": "1.0"
        }
    }
    marker_lt_rb = {
        "type": "line",
        "x0": pos_x - (SQUARE_SIZE / 2),
        "y0": pos_y + (SQUARE_SIZE / 2),
        "x1": pos_x + (SQUARE_SIZE / 2),
        "y1": pos_y - (SQUARE_SIZE / 2),
        "line": {
            "color": "#ff0000",
            "opacity": "1.0"
        }
    }

    return marker_lb_rt, marker_lt_rb

def generate_overlay_image(marker_x, marker_y, SQUARE_SIZE, filename):
    img = Image.new("RGBA", (1440, 1440), color=(255, 255, 255, 0))

    x = 2 * marker_x - (2 * SQUARE_SIZE)
    y = 1440 - 2 * marker_y + (2 * SQUARE_SIZE)
    shape = [(x, y), (x + (4 * SQUARE_SIZE), y - (4 * SQUARE_SIZE))]
    img1 = ImageDraw.Draw(img)
    img1.rectangle(shape, outline="lime", width=2)
    img.save(filename)