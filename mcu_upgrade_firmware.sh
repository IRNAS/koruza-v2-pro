#!/bin/bash

sudo apt install avrdude

# Tag to use.
MCU_TAG="${1:-stable}"

# Must be root.
if [ "$UID" != "0" ]; then
  echo "ERROR: Must be root."
  exit 1
fi

# Fetch latest firmware from Git repository.
MCU_FIRMWARE_DIR="$(mktemp -d)"
MCU_FIRMWARE="${MCU_FIRMWARE_DIR}/output/move_driver_firmware.ino.hex"
git clone -b ${MCU_TAG} https://github.com/IRNAS/Koruza-Move-Driver-Firmware.git ${MCU_FIRMWARE_DIR}
if [ ! -f "${MCU_FIRMWARE}" ]; then
  echo "ERROR: Missing firmware binary."
  exit 1
fi

# Stop koruza-driver.
systemctl stop koruza_main || {
  echo "ERROR: Failed to stop koruza-main. Aborting MCU firmware upgrade."
  rm -rf ${MCU_FIRMWARE_DIR}
  exit 1
}

# Flash firmware.
strace -o "|/usr/bin/mcu-reset" -eioctl /usr/bin/avrdude -V -p atmega328p -C /etc/avrdude.conf -c arduino -b 57600 -P /dev/ttyAMA0 -U flash:w:${MCU_FIRMWARE}:i

# Cleanup.
rm -rf ${MCU_FIRMWARE_DIR}

# Restart koruza-driver.
systemctl start koruza_main
