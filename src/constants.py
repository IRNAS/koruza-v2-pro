
# ========== I2C ====================

#RPi I2C channel
I2C_CHANNEL = 1

# =========== TLV ===================
#
#
#

# =========== NETWORK ===============
LOCALHOST = ""   # TODO find a way to implement below code:
"""
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.connect(("8.8.8.8", 80))
LOCALHOST = s.getsockname()[0]
"""

# ports are set the same on both units, only ip is different
# RPC
KORUZA_MAIN_PORT = 8000
DEVICE_MANAGEMENT_PORT = 8001
ALIGNMENT_ENGINE_PORT = 8002

# TODO set ip based on selected config
REMOTE_UNIT_IP = "192.168.13.199"

# ========== UI =====================
SQUARE_SIZE = 18