sudo mkdir /root/cert
sudo apt install openssl -y
sudo openssl req -x509 -nodes -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 -keyout /root/cert/default_server.key -out /root/cert/default_server.crt -days 5475 -subj "/C=US/ST=State/L=City/O=Organization/OU=Organizational Unit/CN=Common Name"
rm /etc/nginx/sites-available/default
wget 
