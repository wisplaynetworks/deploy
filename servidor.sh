#!/bin/bash

#SERVER INSTALAR APACHE2
sudo apt update -y && sudo apt upgrade -y

sudo timedatectl set-timezone America/Caracas

#INSTALAR APACHE2
sudo apt install apache2 -y

#INSTALAR PHP8.0
sudo add-apt-repository ppa:ondrej/php -y
sudo apt-get update -y

sudo apt install libapache2-mod-php8.0 php8.0 php8.0-common php8.0-fpm php8.0-mysql php8.0-xml php8.0-xmlrpc php8.0-curl php8.0-gd php8.0-imagick php8.0-dev php8.0-imap php8.0-mbstring php8.0-opcache php8.0-soap php8.0-zip php8.0-intl -y

sudo a2enmod proxy_fcgi setenvif
sudo a2enconf php8.0-fpm
sudo service apache2 restart

#INSTALAR CONECTOR CON SQL SERVER
sudo  curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
sudo curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list > /etc/apt/sources.list.d/mssql-release.list

sudo apt-get update -y
sudo ACCEPT_EULA=Y apt-get install -y msodbcsql17
sudo ACCEPT_EULA=Y apt-get install -y mssql-tools
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
source ~/.bashrc
sudo apt-get install -y unixodbc-dev

sudo pecl config-set php_ini /etc/php/8.0/fpm/php.ini
sudo pecl install sqlsrv
sudo pecl install pdo_sqlsrv
printf "; priority=20\nextension=sqlsrv.so\n" > /etc/php/8.0/mods-available/sqlsrv.ini
printf "; priority=30\nextension=pdo_sqlsrv.so\n" > /etc/php/8.0/mods-available/pdo_sqlsrv.ini
sudo phpenmod -v 8.0 sqlsrv pdo_sqlsrv

echo "extension=odbc" >> /etc/php/8.0/fpm/php.ini
echo "extension=pdo_mysql" >> /etc/php/8.0/fpm/php.ini
echo "extension=pdo_sqlsrv" >> /etc/php/8.0/fpm/php.ini
echo "extension=pdo_odbc" >> /etc/php/8.0/fpm/php.ini

sudo systemctl restart php8.0-fpm

sudo systemctl restart apache2

#MYSQL

ROOTBD="$(tr -dc A-Z1-9 < /dev/urandom | head -c 15 | xargs)"
wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg

sudo apt install mariadb-server -y

sudo apt -y install expect

SECURE_MYSQL=$(expect -c "
set timeout 10
spawn mysql_secure_installation
expect \"Enter current password for root (enter for none):\"
send \"\r\"
expect \"Set root password?\"
send \"y\r\"
expect \"New password:\"
send \"$ROOTBD\r\"
expect \"Re-enter new password:\"
send \"$ROOTBD\r\"
expect \"Remove anonymous users?\"
send \"y\r\"
expect \"Disallow root login remotely?\"
send \"y\r\"
expect \"Remove test database and access to it?\"
send \"y\r\"
expect \"Reload privilege tables now?\"
send \"y\r\"
expect eof
")

echo "$SECURE_MYSQL"

apt -y purge expect
mysql -u root  mysql -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('$ROOTBD')"
mysql --user="root" --password=""  --execute="UPDATE user SET authentication_string=PASSWORD('$ROOTBD') where User='root';" mysql
mysql --user="root" --password="" --execute="UPDATE user SET plugin='mysql_native_password';" mysql
mysql -u root mysql -e "FLUSH PRIVILEGES;"
USERBD="$(tr -dc A-Z1-9 < /dev/urandom | head -c 6 | xargs)"
PASSBD="$(tr -dc A-Z1-9 < /dev/urandom | head -c 15 | xargs)"
mysql -u root -p$ROOTBD -e "DROP DATABASE IF EXISTS crmdbwisplay;"
mysql -u root -p$ROOTBD -e "CREATE DATABASE crmdbwisplay /*\!40100 DEFAULT CHARACTER SET utf8 */;"
mysql -u root -p$ROOTBD -e "CREATE USER '$USERBD@localhost' IDENTIFIED BY '$PASSBD';"
mysql -u root -p$ROOTBD -e "GRANT ALL PRIVILEGES ON crmdbwisplay.* TO '$USERBD'@'localhost';"
#mysql -u root -p$ROOTBD  mysql -e "update user set plugin='' where user='root'";
#mysql -u root -p$ROOTBD  mysql -e "update user set plugin='unix_socket' where user='root'";
mysql -u root -p$ROOTBD mysql -e "FLUSH PRIVILEGES;"

mysql -u root -p$ROOTBD  mysql -e "SET GLOBAL group_concat_max_len = 1000000";

cat <<EOT > accessmysql.log
User: $USERBD
Pass: $PASSBD
Passroot: $ROOTBD
EOT


#sudo chown -R www-data:www-data /var/www/html/
sudo a2enmod rewrite
sudo a2dismod php8.0
sudo systemctl restart apache2

apt install zip

#COMPOSER
curl -sS https://getcomposer.org/installer -o composer-setup.php
HASH=`curl -sS https://composer.github.io/installer.sig`
echo $HASH
php -r "if (hash_file('SHA384', 'composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
echo " \n"


IP=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')
echo " \n"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+                                                                                       +"
echo "+    LUEGO DE REINICIAR PUEDE CONTINUAR VIA WEB  http://$IP/      "
echo "+                                                                                     +"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
read -rp 'Pulsa Enter para terminar y reiniciar servidor...'  key
reboot