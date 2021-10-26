# done with the help of the following guide: https://dev.to/chand1012/how-to-host-a-flask-server-with-gunicorn-and-https-942

sudo apt install nginx python3-gunicorn
sudo rm /etc/nginx/sites-enabled/default

sudo openssl req -x509 -nodes -days 18250 -newkey rsa:2048 -keyout /etc/ssl/private/selfsigned.key -out /etc/ssl/certs/selfsigned.crt  # generate a self-signed key
sudo cp /home/pi/koruza_v2/reverse-proxy.conf /etc/nginx/sites-enabled/reverse-proxy.conf
sudo systemctl restart nginx