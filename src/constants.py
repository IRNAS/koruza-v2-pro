
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

# RPC
KORUZA_MAIN_PORT = 8000
BLE_PORT = 8001
AUTO_ALIGNMENT_PORT = 8002
CONFIG_PORT = 8003