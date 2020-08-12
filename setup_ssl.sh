# cd into script directory
scriptdir="$(dirname "$0")"
cd "$scriptdir"

printf "\n----- Installing Nginx -----\n"
sudo yum -y install epel-release
sudo yum -y install nginx firewalld

printf "\n----- Staring Nginx and firewalld -----\n" 
sudo systemctl start nginx
sudo systemctl enable nginx
sudo systemctl status nginx --no-pager 
sudo systemctl start firewalld
sudo systemctl enable firewalld
sudo systemctl status firewalld --no-pager  

printf "\n----- Configuring Firewall -----\n"
sleep 1
sudo firewall-cmd --add-service=http
sudo firewall-cmd --add-service=https
sudo firewall-cmd --runtime-to-permanent

printf "\n----- Configuring IP Table -----\n"
sleep 1
sudo iptables -I INPUT -p tcp -m tcp --dport 80 -j ACCEPT
sudo iptables -I INPUT -p tcp -m tcp --dport 443 -j ACCEPT

printf "\n----- Generating Certificate and Key -----\n"
sleep 1
sudo mkdir /etc/ssl/private
sudo chmod 700 /etc/ssl/private/
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt -config ./setup_ssl.conf

printf "\n----- Creating a strong Diffie-Hellman Group -----\n"
sudo openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048

printf "\n----- Configuring Nginx to Use SSL -----\n"
sleep 2
sudo cp ./ssl.conf /etc/nginx/conf.d/ssl.conf
sudo cp ./ssl-redirect.conf /etc/nginx/default.d/ssl-redirect.conf
# restorecon -v -R /etc/nginx

printf "\n----- Enable the Changes in Nginx -----\n"
sleep 1
sudo nginx -t
sudo systemctl restart nginx
sudo systemctl status nginx --no-pager 

printf "\n\n----- SSL Configuration Done -----\n\n"
