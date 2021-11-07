#!/usr/bin/env python
import sys
import os
import re
import time
import fcntl

import RPi.GPIO as gpio

# Reset pin (BCM numbering).
MCU_RESET_PIN = 18
# Reset duration.
MCU_RESET_DELAY = 0.12

# Setup stdin stream from strace.
fd = sys.stdin.fileno()
fl = fcntl.fcntl(fd, fcntl.F_GETFL)
fcntl.fcntl(fd, fcntl.F_SETFL, fl | os.O_NONBLOCK)

# Set GPIO pin numbering to BCM.
gpio.setmode(gpio.BCM)
# Syscall matching regexp.
dtr = re.compile('.+TIOCM_DTR.+')


def mcu_reset():
    """Perform MCU reset by cycling the correct GPIO pin."""
    gpio.setup(MCU_RESET_PIN, gpio.OUT)
    gpio.output(MCU_RESET_PIN, gpio.HIGH)
    time.sleep(MCU_RESET_DELAY)
    gpio.output(MCU_RESET_PIN, gpio.LOW)
    gpio.cleanup()


def main():
    """Wait for correct syscall and perform an MCU reset."""
    start = time.time()
    while True:
        try:
            duration = time.time() - start
            input = sys.stdin.readline().strip()
            if dtr.match(input):
                mcu_reset()
                return
            elif duration > 5000:
                return
        except:
            continue

if __name__ == '__main__':
    main()
