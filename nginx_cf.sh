sudo mkdir /root/cert
sudo apt install openssl -y
sudo openssl req -x509 -nodes -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 -keyout /root/cert/default_server.key -out /root/cert/default_server.crt -days 5475 -subj "/C=US/ST=State/L=City/O=Organization/OU=Organizational Unit/CN=Common Name"
sudo rm /etc/nginx/sites-available/default
sudo wget -O default https://raw.githubusercontent.com/gebu8f/SH/refs/heads/main/default_cf /etc/nginx/sites-available
sudo systemctl restart nginx