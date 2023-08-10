#!/bin/bash
description () {
    echo "Wordpress"
}

create_mysql_db () {
clear
  tput cup $(tput lines) 0
  read -s -p "$MYSQL_ROOT_PASSWORD_NEED " MYSQL_PASSWORD
  echo
clear
  username_mysql=$1
  password_user_mysql=$2
  database_mysql_name=$3
# Создание базы данных
mysql -u root -p $MYSQL_PASSWORD -e "CREATE DATABASE $database_mysql_name;"
mysql -u root -p $MYSQL_PASSWORD -e "grant all privileges on $database_mysql_name.localhost to $username_mysql@localhost identified by '$password_user_mysql';"
mysql -u root -p $MYSQL_PASSWORD -e "flush privileges;"
if [ $? -eq 0 ]; then
  echo "$CHANGE_SUCCSESS"
  read -n 1 -s -r -p "$ANYKEY_CONTINUE"
else
  echo "$CHANGE_FAILED"
  read -n 1 -s -r -p "$ANYKEY_CONTINUE"
fi
}

if ! command -v mysql &> /dev/null; then
      clear
      echo "$NON_MYSQL"
      tput cup $(tput lines) 0
      read -p "$LIKE_INSTALL" -n 1 apply_changes
      if [[ $apply_changes == "1" ]]; then
        apt install gnupng
        wget https://dev.mysql.com/get/mysql-apt-config_0.8.22-1_all.deb -P /tmp
        dpkg -i /tmp/mysql-apt-config_0.8.22-1_all.deb
        apt update 
        apt install mysql-server
        rm /tmp/mysql-apt-config_0.8.22-1_all.deb
        read -n 1 -s -r -p "$ANYKEY_CONTINUE"
      else
        echo "$CANCELL"
        read -n 1 -s -r -p "$ANYKEY_CONTINUE"
        break
      fi
      else
      echo " "
      fi
      echo "$ENTER_WP_CONF"
      read -p "$ENTER_EMAIL " wpemail
      read -p "$ENTER_USERNAME " wpuser
      read -p "$ENTER_PASSWORD " wppass
      echo "$ENTER_MYSQL_FOR_WP"
      read -p "$ENTER_USERNAME " username_mysql
      read -p "$ENTER_NEW_PASSWORD " password_user_mysql
      read -p "$ENTER_DB_NAME " database_mysql_name
      create_mysql_db $username_mysql $password_user_mysql $database_mysql_name
      wget -P /tmp http://wordpress.org/latest.tar.gz
      tar zxf /tmp/latest.tar.gz
      rm -rf /var/www/html/$domain/*
      mv /tmp/wordpress/* /var/www/html/$domain/
      wget -O /tmp/wp.keys https://api.wordpress.org/secret-key/1.1/salt/
      sed -e "s/localhost/"localhost"/" -e "s/database_name_here/"$database_mysql_name"/" -e "s/username_here/"$username_mysql"/" -e "s/password_here/"$password_user_mysql"/" /var/www/html/$domain/wp-config-sample.php > /var/www/html/$domain/wp-config.php
      sed -i '/#@-/r /tmp/wp.keys' /var/www/html/$domain/wp-config.php
      sed -i "/#@+/,/#@-/d" /var/www/html/$domain/wp-config.php
      curl -d "weblog_title=$domain&user_name=$wpuser&admin_password=$wppass&admin_password2=$wppass&admin_email=$wpemail" http://$siteurl/wp-admin/install.php?step=2
      rm -rf /tmp/wordpress
      rm /tmp/latest.tar.gz
      rm /tmp/wp.keys
chown -R www-data:www-data /var/www/html/$domain
chmod -R 755 /var/www/html/$domain
systemctl restart nginx apache2 php*
echo $WP_INSTALLED
read -n 1 -s -r -p "$ANYKEY_CONTINUE"

if [[ $1 == "description" ]]; then
    description
else
echo ""
fi