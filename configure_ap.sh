mode=$1
if [ ${mode} != "primary"  ] && [ ${mode} != "secondary" ]; then
    echo "Wrong mode selected. Exiting!"
    exit
fi

echo "Starting Access point configuration in ${mode} mode"

if [ ${mode} == "primary" ]; then
    ap_ip=192.168.92.1
else
    ap_ip=192.168.92.2
fi

sudo apt install hostapd
sudo systemctl unmask hostapd
sudo systemctl disable hostapd
sudo systemctl stop hostapd
# sudo systemctl enable hostapd
sudo apt install dnsmasq
sudo DEBIAN_FRONTEND=noninteractive apt install -y netfilter-persistent iptables-persistent

if grep -Fxq "static ip_address=${ap_ip}/24" /etc/dhcpcd.conf; then
    echo "User access AP ip already set to ${ap_ip}"
else
    echo "Setting user access AP to ${ap_ip}"
    echo "interface wlan0
        static ip_address=${ap_ip}/24
        nohook wpa_supplicant
    " >> /etc/dhcpcd.conf
fi

if [ ${mode} == "primary" ]; then
    if grep -Fxq "static ip_address=192.168.93.20/24" /etc/dhcpcd.conf; then
        echo "d2d access AP ip already set to 192.168.93.20"
    else
        echo "Setting user access AP to 192.168.93.20"
        echo "interface wlan1
            static ip_address=192.168.93.20/24
            nohook wpa_supplicant
        " >> /etc/dhcpcd.conf
    fi

    if grep -Fxq "interface=wlan1" /etc/dnsmasq.conf; then
        echo "DHCP and DNS services already configured"
    else
        echo "Configuring DHCP and DNS services"
        sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
        sudo touch /etc/dnsmasq.conf
        echo "
    interface=wlan1 # Listening interface
    dhcp-range=192.168.93.150,192.168.93.250,255.255.255.0,24h
                    # Pool of IP addresses served via DHCP
    domain=wlan
    address=/gw.wlan/192.168.93.20
                    # Alias for this router
        " >> /etc/dnsmasq.conf
    fi

    if grep -Fxq "wpa_passphrase=KoruzaV2d2d" /etc/hostapd/hostapd2.conf; then
        echo "d2d access point already configured"
    else
        echo "Configuring d2d access point"
        sudo touch /etc/hostapd/hostapd2.conf
        echo "country_code=SI
interface=wlan1
ssid=koruza-d2d
hw_mode=g
channel=6
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=KoruzaV2d2d
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
" > /etc/hostapd/hostapd2.conf
    fi
fi

if grep -Fxq "interface=wlan0" /etc/dnsmasq.conf; then
    echo "DHCP and DNS services already configured"
else
    echo "Configuring DHCP and DNS services"
    # sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
    sudo touch /etc/dnsmasq.conf
    echo "
interface=wlan0 # Listening interface
dhcp-range=192.168.92.50,192.168.92.147,255.255.255.0,24h
                # Pool of IP addresses served via DHCP
domain=wlan
address=/gw.wlan/${ap_ip}
                # Alias for this router
    " >> /etc/dnsmasq.conf
fi

if grep -Fxq "wpa_passphrase=KoruzaV2Pro" /etc/hostapd/hostapd1.conf; then
    echo "User Access Point already configured"
else
    echo "Configuring User Access point"
    sudo touch /etc/hostapd/hostapd1.conf
    echo "country_code=SI
interface=wlan0
ssid=koruza-${mode}
hw_mode=g
channel=7
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=KoruzaV2Pro
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP" > /etc/hostapd/hostapd1.conf
fi

echo "Copy service to /etc/systemd./system/hostapd_ap@.service"
sudo cp /home/pi/koruza_v2/services/hostapd_ap.service /etc/systemd/system/hostapd_ap@.service
sudo systemctl daemon-reload
if [ ${mode} == "primary" ]; then
    sudo systemctl enable hostapd_ap@1.service hostapd_ap@2.service
    sudo systemctl start hostapd_ap@1.service hostapd_ap@2.service  # if koruza mode is primary start both services
else
    sudo systemctl enable hostapd_ap@1.service
    sudo systemctl start hostapd_ap@1.service  # else start only this one, as other dongle is configured to connect to first dongle
    sudo apt install network-manager
    echo "[keyfile]
unmanaged-devices=interface-name:wlan0" > /etc/NetworkManager/conf.d/unmanaged.conf
    # sudo nmcli dev wifi connect "koruza-d2d" password "KoruzaV2d2d"
    sudo nmcli con add con-name "koruza-d2d" type wifi ifname wlan1 wifi.ssid "koruza-d2d" wifi-sec.psk "KoruzaV2d2d" 802-11-wireless-security.key-mgmt wpa-psk
    sudo nmcli con mod "koruza-d2d" ipv4.addresses 192.168.93.200/24
    sudo nmcli con mod "koruza-d2d" ipv4.gateway 192.168.93.20
    sudo nmcli con mod "koruza-d2d" ipv4.dns 8.8.8.8
    sudo nmcli con mod "koruza-d2d" ipv4.method manual
    sudo nmcli connection up "koruza-d2d"
    sudo cp /home/pi/koruza_v2/services/connection_manager.service /etc/systemd/system/connection_manager.service
    sudo systemctl daemon-reload
    sudo systemctl enable connection_manager
    sudo systemctl start connection_manager
fi

sudo rfkill unblock wlan
echo "Configuring of Access Point complete. Rebooting unit."
sleep 5

sudo reboot now