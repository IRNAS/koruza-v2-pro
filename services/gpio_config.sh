#!/bin/bash
# rpi cm3 datasheet: https://www.raspberrypi.org/documentation/hardware/computemodule/datasheets/rpi_DATA_CM_1p0.pdf
/usr/bin/gpio -g mode 2 alt5  # enable i2c
/usr/bin/gpio -g mode 44 alt2  # alt2 - SDA1
/usr/bin/gpio -g mode 45 alt2  # alt2 - SCL1