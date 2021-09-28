# 0. Install requirements
cd ~/koruza_v2
sudo pip3 install -r koruza_v2_ui/requirements.txt
sudo pip3 install -r koruza_v2_cloud/requirements.txt 
sudo pip3 install -r koruza_v2_driver/requirements.txt 
sudo python3 -m pip install --force-reinstall adafruit-blinka

# 1. install mjpeg-streamer
cd ~
echo "Cloning mjpeg-streamer fork"
git clone https://github.com/IRNAS/mjpg-streamer -b feature/raspicam-roi
sudo apt install cmake libjpeg8-dev
cd mjpg-streamer/mjpg-streamer-experimental
echo "Installing mjpeg-streamer"
make
sudo make install

# 2. copy device tree configuration
echo "Copying device tree configuration to /boot/dt-blob.bin"
cd ~/koruza_v2
sudo cp dt-blob.bin /boot/dt-blob.bin

# 3. create koruza services and missing folders with files
cd ~/koruza_v2
sudo mkdir ./logs
sudo mkdir ./koruza_v2_driver/data
sudo cp ./koruza_v2_driver/data.json ./koruza_v2_driver/data

sudo mkdir ./config
sudo cp config.json ./config
sudo cp calibration.json ./config/calibration.json
sudo cp factory_defaults.json ./config/factory_defaults.json
sudo chattr -i ./config/factory_defaults.json

echo "Copying koruza services to /etc/systemd/system/"
sudo cp /home/pi/koruza_v2/services/gpio_config.service /etc/systemd/system/gpio_config.service
sudo cp /home/pi/koruza_v2/services/video_stream.service /etc/systemd/system/video_stream.service
sudo cp /home/pi/koruza_v2/services/koruza_main.service /etc/systemd/system/koruza_main.service
sudo cp /home/pi/koruza_v2/services/koruza_ui.service /etc/systemd/system/koruza_ui.service
sudo cp /home/pi/koruza_v2/services/koruza_d2d.service /etc/systemd/system/koruza_d2d.service
sudo cp /home/pi/koruza_v2/services/koruza_cloud.service /etc/systemd/system/koruza_cloud.service

echo "Starting all services"
sudo systemctl daemon-reload
sudo systemctl enable koruza_main koruza_ui koruza_d2d koruza_cloud gpio_config video_stream
sudo systemctl start koruza_main koruza_ui koruza_d2d koruza_cloud gpio_config video_stream

echo "Enabling i2c"
sudo raspi-config nonint do_i2c 0

echo "Enabling camera"
sudo raspi-config nonint do_camera 0

echo "Enabling hardware serial"
sudo raspi-config nonint do_serial 2 

echo "Rebooting RPi for configuration to take effect"
sleep 1
sudo reboot now
