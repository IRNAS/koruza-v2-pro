# Koruza v2 update script, gets called from UI and updates KORUZA to the latest version
# The update is performed by simply pulling the latest version of the KORUZA software from GitHub and calling the install.sh script
echo "Moving into the koruza_v2 directory"
cd ~/koruza_v2
echo "Pulling latest version of the KORUZA software"
git pull --recurse-submodules
echo "Starting installation script"
bash ./install.sh