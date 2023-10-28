#!/bin/bash
sudo apt update
sudo apt install lsb-release ca-certificates apt-transport-https software-properties-common -y
sudo add-apt-repository ppa:ondrej/php -y

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

mkdir /etc/apache2/sslcert
cd /etc/apache2/sslcert
sudo a2query -m ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout web.key -out web.crt <<EOF
VN
HaNoi
HaNoi
CN GTVT
CN GTVT
Nguyen Tien Dung
nguyentiendung@edu.utt.vn
EOF


nextcloud=/etc/apache2/conf-enabled/nextcloud.conf
cat > $nextcloud <<EOF
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

<VirtualHost _default_:443>
     ServerAdmin admin@nextcloudutt.ddns.net
     DocumentRoot /srv/nextcloud/
     ServerName nextcloudutt.ddns.net
     ServerAlias www.nextcloudutt.ddns.net
     ErrorLog /var/log/apache2/nextcloud-error.log
     CustomLog /var/log/apache2/nextcloud-access.log combined
     SSLEngine on
     SSLCertificateFile /etc/apache2/sslcert/web.crt
     SSLCertificateKeyFile /etc/apache2/sslcert/web.key

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
# trust=/srv/nextcloud/config/config.php
# cat > $trust <<EOF
# <?php
# $CONFIG = array (
#   'instanceid' => 'oczei7okcxtb',
#   'passwordsalt' => 'KHqWbOcjKqgTQeA7f9j3VVCj1X5bIv',
#   'secret' => 'Ztt9Uz5dRorDBMOZPxNe1EJ1303FiYYclzZUpfzYQlfTAwc0',
#   'trusted_domains' =>
#      [
#       'nextcloudutt.ddns.net',
#       'nextcloudutt.ddns.net',
#       '10.10.99.157',
#       '[2001:db8::1]'
#     ],
#   array (
#     0 => '10.10.99.157',
#   ),
#   'datadirectory' => '/srv/nextcloud/data',
#   'dbtype' => 'mysql',
#   'version' => '27.1.3.2',
#   'overwrite.cli.url' => 'http://nextcloudutt.ddns.net',
#   'dbname' => 'nextcloud',
#   'dbhost' => 'localhost',
#   'dbport' => '',
#   'dbtableprefix' => 'oc_',
#   'mysql.utf8mb4' => true,
#   'dbuser' => 'nextcloud',
#   'dbpassword' => 'StrongPassword',
#   'installed' => true,
# );
# EOF

sudo a2enmod ssl
sudo a2enmod rewrite dir mime env headers
sudo systemctl restart apache2
