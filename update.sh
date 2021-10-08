# Koruza v2 update script, gets called from UI and updates KORUZA to the latest version
# The update is performed by simply pulling the latest version of the KORUZA software from GitHub and calling the install.sh script

echo "Moving into the koruza_v2 directory"
cd /home/pi/koruza_v2
echo "Pulling latest version of the KORUZA software"
git checkout $1
git pull --recurse-submodules

echo "Running install.sh script"
bash /home/pi/koruza_v2/install.sh

echo "Rebooting RPi for update to take effect"
sleep 1
sudo reboot now