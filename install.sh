# 0. Install requirements
cd /home/pi/koruza_v2
sudo pip3 install -r koruza_v2_ui/requirements.txt
sudo pip3 install -r koruza_v2_cloud/requirements.txt 
sudo pip3 install -r koruza_v2_driver/requirements.txt
sudo pip3 install -r requirements.txt
sudo python3 -m pip install --force-reinstall adafruit-blinka

# 1. install mjpeg-streamer
cd /home/pi
echo "Starting mjpg-streamer installation"
if [ ! -d "/home/pi/mjpg-streamer" ]; then
    echo "Cloning mjpg-streamer fork"
    git clone https://github.com/IRNAS/mjpg-streamer -b feature/raspicam-roi
    sudo apt install cmake libjpeg8-dev libopenjp2-7
    cd mjpg-streamer/mjpg-streamer-experimental
    echo "Installing mjpeg-streamer"
    make
    sudo make install
else
    echo "mjpg-streamer already installed. Skipping installation."
fi

# 2. copy device tree configuration
echo "Checking if device tree configration exists"
if [ ! -f "/boot/dt-blob.bin" ]; then
    echo "Copying device tree configuration to /boot/dt-blob.bin"
    cd /home/pi/koruza_v2
    sudo cp dt-blob.bin /boot/dt-blob.bin
else
    echo "Device tree configuration already exists in /boot/dt-blob.bin"
fi

# 3. create koruza services and missing folders
cd /home/pi/koruza_v2
sudo mkdir ./logs
sudo mkdir ./koruza_v2_driver/data
echo "Copying template data.json to /home/pi/koruza_v2_driver/data/data.json"
sudo cp ./koruza_v2_driver/data.json ./koruza_v2_driver/data
echo "Copying secrets_example.json to /home/pi/koruza_v2_ui/secrets.json"
sudo cp ./koruza_v2_ui/secrets_example.json ./koruza_v2_ui/secrets.json

# 4. Configure interfaces
echo "Enabling i2c"
sudo raspi-config nonint do_i2c 0
echo "Enabling camera"
sudo raspi-config nonint do_camera 0
echo "Enabling hardware serial"
sudo raspi-config nonint do_serial 2 

echo "Copying configuration files to /home/pi/koruza_v2/config"
cd /home/pi/koruza_v2
sudo mkdir ./config
if [ ! -f "./config/config.json" ]; then
    echo "Copying config.json to /home/pi/koruza_v2/config/config.json"
    sudo cp example_config.json ./config/config.json
else
    echo "config.json already exists in /home/pi/koruza_v2/config/config.json"
fi

if [ ! -f "./config/.camera_config" ]; then
    echo "Copying .camera_config to /home/pi/koruza_v2/config/.camera_config"
    sudo cp .camera_config ./config/.camera_config
else
    echo ".camera_config already exists in /home/pi/koruza_v2/config/.camera_config"
fi

if [ ! -f "./config/calibration.json" ]; then
    echo "Copying calibration.json to /home/pi/koruza_v2/config/calibration.json"
    sudo cp .factory_defaults.json ./config/calibration.json
else
    echo "calibration already exists in /home/pi/koruza_v2/config/calibration.json"
fi

if [ ! -f "./config/factory_defaults.json" ]; then
    echo "Copying factory_defaults.json to /home/pi/koruza_v2/config/factory_defaults.json"
    sudo cp .factory_defaults.json ./config/factory_defaults.json
    sudo chattr -i ./config/factory_defaults.json
else
    echo "factory_defaults.json already exists in /home/pi/koruza_v2/config/factory_defaults.json"
fi

echo "Copying koruza services to /etc/systemd/system/"
sudo cp /home/pi/koruza_v2/services/gpio_config.service /etc/systemd/system/gpio_config.service
sudo cp /home/pi/koruza_v2/services/video_stream.service /etc/systemd/system/video_stream.service
sudo cp /home/pi/koruza_v2/services/koruza_main.service /etc/systemd/system/koruza_main.service
sudo cp /home/pi/koruza_v2/services/koruza_ui.service /etc/systemd/system/koruza_ui.service
sudo cp /home/pi/koruza_v2/services/koruza_d2d.service /etc/systemd/system/koruza_d2d.service
sudo cp /home/pi/koruza_v2/services/koruza_cloud.service /etc/systemd/system/koruza_cloud.service
sudo cp /home/pi/koruza_v2/services/koruza_alignment_engine.service /etc/systemd/system/koruza_alignment_engine.service

echo "Starting all services"
sudo systemctl daemon-reload
sudo systemctl enable koruza_main koruza_ui koruza_d2d koruza_alignment_engine koruza_cloud gpio_config video_stream
sudo systemctl start koruza_main koruza_ui koruza_d2d koruza_alignment_engine koruza_cloud gpio_config video_stream

echo "Enabling i2c"
sudo raspi-config nonint do_i2c 0

echo "Enabling camera"
sudo raspi-config nonint do_camera 0

echo "Enabling hardware serial"
sudo raspi-config nonint do_serial 2 

echo "Rebooting RPi for configuration to take effect"
sleep 1
sudo reboot now
