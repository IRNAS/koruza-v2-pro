# KORUZA-Pro-V2

This repository contains all code used to setup, run and manage the KORUZA Pro V2 device.

### Software
* [KORUZA V2 driver](https://github.com/IRNAS/koruza-v2-driver) - main KORUZA code, implements interfaces to all hardware modules and packages core functionality into a single main module
* [KORUZA V2 UI](https://github.com/IRNAS/koruza-v2-ui) - KORUZA user interface available to the user through the web browser
* [KORUZA V2 device to device management](https://github.com/IRNAS/koruza-v2-device-management) - KORUZA device to device management with Bluetooth and Python
* [KORUZA V2 tracking](https://github.com/IRNAS/koruza-v2-tracking) - KORUZA auto aligment and tracking
* [mjpg-streamer fork](https://github.com/IRNAS/mjpg-streamer) - fork of mjpg-streamer with added functions required for KORUZA
* [Raspberry Pi OS](https://www.raspberrypi.org/software/) core operating system on Raspberry Pi

### Hardware
* KORUZA compute module board - TODO
* [KORUZA move driver](https://github.com/IRNAS/koruza-move-driver) - standalone motor controller board for dual unipolar stepper motors in KORUZA Pro for automatic alignment

## Setup

### Raspberry Pi OS installation
1. Download the latest Raspberry OS Lite from: https://www.raspberrypi.org/software/operating-systems/
2. Download balenaEtcher from: https://www.balena.io/etcher/
3. Install git using `sudo apt install git`
4. Clone the `usbboot` tool repository 
```
git clone --depth=1 https://github.com/raspberrypi/usbboot
cd usbboot
```
5. Install `libusb` with `sudo apt install libusb-1.0.0-dev`
6. Build and install the `usbtool` by running `make`
7. Run the `usbboot` tool with `sudo ./rpiboot`
8. Power up the KORUZA unit and wait for the the `rpiboot` tool to discover the Compute Module 3
10. Open balena etcher and flash latest Raspberry OS image to eMMC flash of the Compute Module 3 
11. To enable SSH place a file called `ssh` into the boot folder of the compute module
12. Set up passwordless ssh for easy access with: https://www.raspberrypi.org/documentation/remote-access/ssh/passwordless.md

### Installation
1. Install required dependencies with
```
sudo apt install python3-pip wiringpi libatlas-base-dev
```
2. Clone this repository and init submodules with
```
git clone https://github.com/IRNAS/koruza-pro-v2 koruza_v2
cd koruza_v2
git submodule update --init
```
3. Install python3 requirements with
```
sudo pip3 install -r koruza_v2_ui/requirements.txt
sudo pip3 install -r koruza_v2_driver/requirements.txt 
```
4. Run `sudo python3 -m pip install --force-reinstall adafruit-blinka`

### mjpg-streamer installation
1. Clone mjpg-streamer for with
```
cd ~
git clone https://github.com/IRNAS/mjpg-streamer -b feature/raspicam-roi
```
2. Install cmake and libjpeg8-dev `sudo apt install cmake libjpeg8-dev`
3. Install mjpg-streamer fork
```
cd mjpg-streamer/mjpg-streamer-experimental
make
sudo make install
```

### Raspberry Pi Interface configuration
1. Open settings with `sudo raspi-config`
2. Navigate to `Interface options`
3. Navigate to `Camera` and enable it
4. Navigate to `I2C` and enable the interface
5. Navigate to `Serial Port`
6. Select `No` when asked `Would you like a login shell to be accessible over serial?`
7. Select `Yes` when asked `Would you like the serial port hardware to be enabled?`
8. Exit the `raspi-config` screen and `reboot` the device


### Camera configuration
1. Move into the repository with `cd koruza_v2`
1. Run `cp dt-blob.bin /boot/dt-blob.bin`
2. Reboot
3. Test camera with `raspistill -o test.jpg`


## Services
There are serveral services running to enable KORUZA functionality at startup.

### GPIO configuration on boot
1. Copy the snippet below and paste it to a new service file created with `sudo nano /etc/systemd/system/gpio_config.service`
```
[Unit]
Description="GPIO Config at Start"
After=multi-user.target

[Service]
ExecStart=/usr/bin/bash /home/pi/koruza_v2/services/gpio_config.sh
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
```
2. Run the following commands to enable the service
```
sudo systemctl daemon-reload 
sudo systemctl enable gpio_config
sudo systemctl start gpio_config
```

### Video stream on boot
1. Copy the snippet below and paste it to a new service file created with `sudo nano /etc/systemd/system/video_stream.service`
```
[Unit]
Description="Serve Video stream"
After=multi-user.target

[Service]
Environment=LD_LIBRARY_PATH=/home/pi/mjpg-streamer/mjpg-streamer-experimental
ExecStart=/home/pi/mjpg-streamer/mjpg-streamer-experimental/mjpg_streamer -o "output_http.so -w ./www" -i "input_raspicam.so -x 640 -y 640 -fps 15 -ex snow -vs -roi 0.25,0.25,0.5,0.5"
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
```
2. Run the following commands to enable the service
```
sudo systemctl daemon-reload 
sudo systemctl enable video_stream
sudo systemctl start video_stream
```

### KORUZA main service on boot
1. Copy the snippet below and paste it to a new service file created with `sudo nano /etc/systemd/system/koruza_main.service`
```
[Unit]
Description="Koruza Main service"
After=multi-user.target

[Service]
WorkingDirectory=/home/pi
ExecStart=python3 -m koruza_v2.koruza_v2_driver.koruza
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
```
2. Run the following commands to enable the service
```
sudo systemctl daemon-reload 
sudo systemctl enable koruza_main
sudo systemctl start koruza_main
```

### KORUZA UI service on boot
1. Copy the snippet below and paste it to a new service file created with `sudo nano /etc/systemd/system/koruza_ui.service`
```
[Unit]
Description="Koruza UI service"
After=multi-user.target

[Service]
WorkingDirectory=/home/pi
ExecStart=python3 -m koruza_v2.koruza_v2_ui.index
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
```
2. Run the following commands to enable the service
```
sudo systemctl daemon-reload 
sudo systemctl enable koruza_ui
sudo systemctl start koruza_ui
```