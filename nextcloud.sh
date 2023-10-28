#!/bin/bash
sudo apt update
sudo apt install lsb-release ca-certificates apt-transport-https software-properties-common -y
sudo add-apt-repository ppa:ondrej/php 

sudo apt update && sudo apt install php8.2 -y
sudo apt install php8.2-{bcmath,xml,fpm,mysql,zip,intl,ldap,gd,cli,bz2,curl,mbstring,pgsql,opcache,soap,cgi} -y
sudo apt install apache2 libapache2-mod-php8.2 -y
sudo a2enmod php8.2

zone=/etc/php/*/apache2/php.ini
cat > $zone <<EOF
date.timezone = Asia/Ho_Chi_Minh
memory_limit = 512M
upload_max_filesize = 500M
post_max_size = 500M
max_execution_time = 300
EOF

sudo systemctl restart apache2

sudo apt -y install mariadb-server

mysql_secure_installation <<EOF

y
y
thudo@123
thudo@123
y
y
y
y
EOF

mysql -uroot -pthudo@123 <<EOF
CREATE USER 'nextcloud'@'localhost' IDENTIFIED BY 'StrongPassword';
CREATE DATABASE nextcloud;
GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'localhost';
FLUSH PRIVILEGES;
EOF

sudo apt install -y wget unzip
wget https://download.nextcloud.com/server/releases/latest.zip

unzip latest.zip
sudo mv nextcloud/ /srv
sudo chown -R www-data:www-data /srv/nextcloud/

nextcloud=/etc/apache2/conf-enabled/nextcloud.conf
cat >> $nextcloud <<EOF
<VirtualHost *:80>
     ServerAdmin admin@nextcloudutt.ddns.net
     DocumentRoot /srv/nextcloud/
     ServerName nextcloudutt.ddns.net
     ServerAlias www.nextcloudutt.ddns.net
     ErrorLog /var/log/apache2/nextcloud-error.log
     CustomLog /var/log/apache2/nextcloud-access.log combined
 
    <Directory /srv/nextcloud/>
	Options +FollowSymlinks
	AllowOverride All
        Require all granted
 	SetEnv HOME /srv/nextcloud
 	SetEnv HTTP_HOME /srv/nextcloud
 	<IfModule mod_dav.c>
  	  Dav off
        </IfModule>
    </Directory>
</VirtualHost>
EOF

sudo a2enmod rewrite dir mime env headers
sudo systemctl restart apache2
