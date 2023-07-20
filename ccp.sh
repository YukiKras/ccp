#!/bin/bash
# Функция для перезагрузки хоста
reboot_host() {
    clear
    echo "$REBOOT"
    reboot
}

# Функция для выключения хоста
shutdown_host() {
    clear
    echo "$SHUTDOWN"
    shutdown now
}

# Функция для показа настроек сети
show_network_settings() {
    clear
    echo "$CURRENT_NETWORK"
    ip a
    read -n 1 -s -r -p "$ANYKEY_CONTINUE"
}

# Функция для настройки сети
configure_network() {
    while true; do
    clear
    echo "        ___                      _        ___   ___ " 
    echo "       / __\___  _ __  ___  ___ | | ___  / __\ / _ |" 
    echo "      / /  / _ \| '_ \/ __|/ _ \| |/ _ \/ /   / /_)/"
    echo "     / /__| (_) | | | \__ \ (_) | |  __/ /___/ ___/ "
    echo "     \____/\___/|_| |_|___/\___/|_|\___\____/\/     "
    echo ""
    echo "========================================================="
    echo ""
    echo "                       $SELECT_ACTION"
    echo ""
    echo "========================================================="
    echo ""
    echo "                    1. $NETWORK_MENU1"
    echo "                    2. $NETWORK_MENU2"
    echo "                    3. $NETWORK_MENU3"
    echo ""
    echo "                    0. $BACK"
        #echo "$SELECT_ACTION"
        #echo "1. $NETWORK_MENU1"
        #echo "2. $NETWORK_MENU2"
        #echo "3. $NETWORK_MENU3"
        #echo "0. $EXIT"

        tput cup $(tput lines) 0
        read -p "$ENTER_NUMBER" choice

        case $choice in
            1)
                show_network_settings
                ;;
            2)
                echo "$SETTING_INTERNET"
                read -p "$ENTER_INTERFACE" interface_name
                echo "1. DHCP"
                echo "2. $SELECT_STATIC_IP"
                read -p "$SELECT_CONFIG_IP_TYPE" config_type

                if [[ $config_type == "1" ]]; then
                    # Используем DHCP
                    echo "auto $interface_name" | tee /etc/network/interfaces
                    echo "iface $interface_name inet dhcp" | tee -a /etc/network/interfaces
                elif [[ $config_type == "2" ]]; then
                    echo "$ENTER_IP"
                    read ip_address
                    echo "$ENTER_MASK"
                    read subnet_mask
                    echo "$ENTER_GATEWAY"
                    read gateway_ip
                    echo "$ENTER_DNS"
                    read dns_server

                    # Записываем настройки в файл /etc/network/interfaces
                    echo "auto $interface_name" | tee /etc/network/interfaces
                    echo "iface $interface_name inet static" | tee -a /etc/network/interfaces
                    echo "    address $ip_address" | tee -a /etc/network/interfaces
                    echo "    netmask $subnet_mask" | tee -a /etc/network/interfaces
                    echo "    gateway $gateway_ip" | tee -a /etc/network/interfaces
                    echo "    dns-nameservers $dns_server" | tee -a /etc/network/interfaces
                else
                    echo "$FAIL_CHOISE"
                    continue
                fi

                echo "$SAVE_NETWORK"

                read -p "$APPLY_CHANGE" -n 1 apply_changes

                if [[ $apply_changes == "1" ]]; then
                    echo "$APPLYING"
                    ifdown $interface_name && ifup $interface_name
                    echo "$CHANGE_SUCCSESS"
                else
                    echo "$CHANGE_FAILED"
                fi
                ;;
            3)
                manage_firewall
                ;;
            0)
                break
                ;;
            *)
                echo "$FAIL_CHOISE"
                ;;
        esac
    done
}

# Функция для настройки фаервола UFW
manage_firewall() {
  # Проверка установки UFW
  if ! command -v ufw &> /dev/null; then
    clear
    echo "$NON_UFW"
    read -p "$LIKE_INSTALL" -n 1 apply_changes
    if [[ $apply_changes == "1" ]]; then
        apt-get update
        apt-get install ufw
        read -n 1 -s -r -p "$ANYKEY_CONTINUE"
    else
        configure_network
    fi
    else
    echo " "
    fi

while true; do
    clear
    #echo "$SELECT_ACTION"
    #echo "1. $UFW_MENU1"
    #echo "2. $UFW_MENU2"
    #echo "3. $UFW_MENU3"
    #echo "4. $UFW_MENU4"
    #echo "0. $BACK"
    echo "        ___                      _        ___   ___ " 
    echo "       / __\___  _ __  ___  ___ | | ___  / __\ / _ |" 
    echo "      / /  / _ \| '_ \/ __|/ _ \| |/ _ \/ /   / /_)/"
    echo "     / /__| (_) | | | \__ \ (_) | |  __/ /___/ ___/ "
    echo "     \____/\___/|_| |_|___/\___/|_|\___\____/\/     "
    echo ""
    echo "========================================================="
    echo ""
    echo "                       $SELECT_ACTION"
    echo ""
    echo "========================================================="
    echo ""
    echo "                    1. $UFW_MENU1"
    echo "                    2. $UFW_MENU2"
    echo "                    3. $UFW_MENU3"
    echo "                    4. $UFW_MENU4"
    echo ""
    echo "                    0. $BACK"
    read -p "$ENTER_NUMBER" choice
    case $choice in
      1)
        # Просмотр правил фаервола
        clear
        ufw status
        read -n 1 -s -r -p "$ANYKEY_CONTINUE"
        ;;
      2)
        # Разрешить доступ к порту
        read -p "$ENTER_PORT" port
        ufw allow $port
        ;;
      3)
        # Запретить доступ к порту
        read -p "$ENTER_PORT" port
        ufw deny $port
        ;;
      4)
        ufw_switch
        ;;
      0)
        # Возврат в предыдущее меню
        break
        ;;
      *)
        echo "$FAIL_CHOISE"
        ;;
    esac
  done
}

ufw_switch() {
# Проверка состояния UFW
ufw_status=$(ufw status | grep "Status" | awk '{print $2}')

if [ "$ufw_status" == "inactive" ]; then
    clear
    echo "$UFW_IS_DOWN"
    tput cup $(tput lines) 0
    read -p "$UFW_UP" -n 1 apply_changes
    echo " "
    if [[ $apply_changes == "1" ]]; then
        ufw enable
        echo "$SUCCESS"
        read -n 1 -s -r -p "$ANYKEY_CONTINUE"
    else
        echo "$CANCELL"
        read -n 1 -s -r -p "$ANYKEY_CONTINUE"
    fi
elif [ "$ufw_status" == "active" ]; then
    clear
    echo "$UFW_IS_UP"
    tput cup $(tput lines) 0
    read -p "$UFW_DOWN" -n 1 apply_changes
    echo " "
    if [[ $apply_changes == "1" ]]; then
        ufw disable
        echo "$SUCCESS"
        read -n 1 -s -r -p "$ANYKEY_CONTINUE"
    else
        echo "$CANCELL"
        read -n 1 -s -r -p "$ANYKEY_CONTINUE"
    fi
else
    echo "$UFW_MISSING"
    read -n 1 -s -r -p "$ANYKEY_CONTINUE"
fi
}

manage_resources() {
  while true; do
  clear
  #echo "$SELECT_ACTION"
  #echo "1. $RESOURCE_MENU1"
  #echo "2. $RESOURCE_MENU2"
  #echo "3. $RESOURCE_MENU3"
  #echo "0. $BACK"
    echo "        ___                      _        ___   ___ " 
    echo "       / __\___  _ __  ___  ___ | | ___  / __\ / _ |" 
    echo "      / /  / _ \| '_ \/ __|/ _ \| |/ _ \/ /   / /_)/"
    echo "     / /__| (_) | | | \__ \ (_) | |  __/ /___/ ___/ "
    echo "     \____/\___/|_| |_|___/\___/|_|\___\____/\/     "
    echo ""
    echo "========================================================="
    echo ""
    echo "                       $SELECT_ACTION"
    echo ""
    echo "========================================================="
    echo ""
    echo "                    1. $RESOURCE_MENU1"
    echo "                    2. $RESOURCE_MENU2"
    echo "                    3. $RESOURCE_MENU3"
    echo ""
    echo "                    0. $BACK"
  tput cup $(tput lines) 0
  read -p "$ENTER_NUMBER" choice
  case $choice in
    1)
      if ! command -v htop &> /dev/null; then
      clear
      echo "$NON_HTOP"
      tput cup $(tput lines) 0
      read -p "$LIKE_INSTALL" -n 1 apply_changes
      if [[ $apply_changes == "1" ]]; then
        # Установка пакета htop
        apt-get install htop
        read -n 1 -s -r -p "$ANYKEY_CONTINUE"
      else
        echo "$CANCELL"
        read -n 1 -s -r -p "$ANYKEY_CONTINUE"
      fi
      else
        htop
      fi
      ;;
    2)
      clear
      read -p "$ENTER_PID" pid
      kill $pid
      ;;
    3)
      if ! command -v netstat &> /dev/null; then
      clear
      echo "$NON_NET_TOOLS"
      tput cup $(tput lines) 0
      read -p "$LIKE_INSTALL" -n 1 apply_changes
      if [[ $apply_changes == "1" ]]; then
        # Установка пакета htop
        apt-get install htop
        read -n 1 -s -r -p "$ANYKEY_CONTINUE"
      else
        echo "$CANCELL"
        read -n 1 -s -r -p "$ANYKEY_CONTINUE"
      fi
      else
        netstat -ltupan
        read -n 1 -s -r -p "$ANYKEY_CONTINUE"
      fi
      ;;
    0)
      break
      ;;
    *)
      echo "$FAIL_CHOISE"
      ;;
  esac
done
}

change_language() {
    clear
    echo "        ___                      _        ___   ___ " 
    echo "       / __\___  _ __  ___  ___ | | ___  / __\ / _ |" 
    echo "      / /  / _ \| '_ \/ __|/ _ \| |/ _ \/ /   / /_)/"
    echo "     / /__| (_) | | | \__ \ (_) | |  __/ /___/ ___/ "
    echo "     \____/\___/|_| |_|___/\___/|_|\___\____/\/     "
    echo ""
    echo "========================================================="
    echo ""
    echo "                       $SELECT_LANG"
    echo ""
    echo "========================================================="
    echo ""
    echo "                    1. English"
    echo "                    2. Русский"
    #echo "$SELECT_LANG"
    #echo "1. English"
    #echo "2. Русский"

    tput cup $(tput lines) 0
    read -p "$ENTER_NUMBER" lang_choice

    case $lang_choice in
        1)
            lang_code="en"
            ;;
        2)
            lang_code="ru"
            ;;
        *)
            echo "$FAIL_CHOISE"
            return
            ;;
    esac

    echo $lang_code > "/opt/ccp/lang.config"  # Запись выбранного языка в файл
    echo "$SUCCESS"
    read -n 1 -s -r -p "$ANYKEY_CONTINUE"
}

load_language_resources() {
    local lang_file="/opt/ccp/lang/ccp_en.sh"  # По умолчанию используется английский язык

    if [ -f "/opt/ccp/lang.config" ]; then
        lang_code=$(cat "/opt/ccp/lang.config")  # Чтение выбранного языка из файла
        case $lang_code in
            "en")
                lang_file="/opt/ccp/lang/ccp_en.sh"
                ;;
            "ru")
                lang_file="/opt/ccp/lang/ccp_ru.sh"
                ;;
        esac
    fi

    source "$lang_file"  # Загрузка языковых ресурсов
}

mysql_manage() {
while true; do
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
      fi
      else
      echo " "
      fi
  clear
  #echo "$SELECT_ACTION"
  #echo "1. $MYSQL_MANAGE_MENU1"
  #echo "2. $MYSQL_MANAGE_MENU2"
  #echo "3. $MYSQL_MANAGE_MENU3"
  #echo "0. $BACK"
    echo "        ___                      _        ___   ___ " 
    echo "       / __\___  _ __  ___  ___ | | ___  / __\ / _ |" 
    echo "      / /  / _ \| '_ \/ __|/ _ \| |/ _ \/ /   / /_)/"
    echo "     / /__| (_) | | | \__ \ (_) | |  __/ /___/ ___/ "
    echo "     \____/\___/|_| |_|___/\___/|_|\___\____/\/     "
    echo ""
    echo "========================================================="
    echo ""
    echo "                       $SELECT_ACTION"
    echo ""
    echo "========================================================="
    echo ""
    echo "                    1. $MYSQL_MANAGE_MENU1"
    echo "                    2. $MYSQL_MANAGE_MENU2"
    echo "                    3. $MYSQL_MANAGE_MENU3"
    echo ""
    echo "                    0. $BACK"
  tput cup $(tput lines) 0
  read -p "$ENTER_NUMBER" choice
  case $choice in
    1)
      manage_mysql_users
      ;;
    2)
      mysql_manage_db
      ;;
    3)
      run_mysql_autofix
      ;;
    0)
      break
      ;;
    *)
      echo "$FAIL_CHOISE"
      ;;
  esac
done
}

manage_mysql_users () {
while true; do
  clear
  tput cup $(tput lines) 0
  read -s -p "$MYSQL_ROOT_PASSWORD_NEED " MYSQL_PASSWORD
  echo
  clear
  #echo "$SELECT_ACTION"
  #echo "1. $MYSQL_USERS_MANAGE_MENU1"
  #echo "2. $MYSQL_USERS_MANAGE_MENU2"
  #echo "3. $MYSQL_USERS_MANAGE_MENU3"
  #echo "0. $BACK"
  #echo " "
    echo "        ___                      _        ___   ___ " 
    echo "       / __\___  _ __  ___  ___ | | ___  / __\ / _ |" 
    echo "      / /  / _ \| '_ \/ __|/ _ \| |/ _ \/ /   / /_)/"
    echo "     / /__| (_) | | | \__ \ (_) | |  __/ /___/ ___/ "
    echo "     \____/\___/|_| |_|___/\___/|_|\___\____/\/     "
    echo ""
    echo "========================================================="
    echo ""
    echo "                       $SELECT_ACTION"
    echo ""
    echo "========================================================="
    echo ""
    echo "                    1. $MYSQL_USERS_MANAGE_MENU1"
    echo "                    2. $MYSQL_USERS_MANAGE_MENU2"
    echo "                    3. $MYSQL_USERS_MANAGE_MENU3"
    echo ""
    echo "                    0. $BACK"
    echo ""
    echo "========================================================="
    echo ""
  # Переменные для подключения к MySQL
  MYSQL_HOST="localhost"
  MYSQL_USER="root"
  # Запрос для получения списка пользователей
  QUERY="SELECT User FROM mysql.user;"
  # Выполнение команды MySQL и получение списка пользователей
  USERS=$(mysql -h "${MYSQL_HOST}" -u "${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -e "${QUERY}" --silent)
  # Проверка успешности выполнения команды MySQL
  if [ $? -eq 0 ]; then
  echo "$MYSQL_USERS_LIST"
  echo "${USERS}"
  else
  echo "$MYSQL_USERS_LIST_ERROR"
  fi
  tput cup $(tput lines) 0
  read -p "$ENTER_NUMBER" choice
  case $choice in
    1)
      clear
      read -p "$ENTER_USERNAME " username_mysql
      read -p "$ENTER_PASSWORD " password_user_mysql
      create_mysql_users $username_mysql $password_user_mysql
      ;;
    2)
      clear
      read -p "$ENTER_USERNAME " username_mysql
      delete_mysql_users $username_mysql
      ;;
    3)
      clear
      read -p "$ENTER_USERNAME " username_mysql
      read -p "$ENTER_NEW_PASSWORD " password_user_mysql
      change_mysql_users_password $username_mysql $password_user_mysql
      ;;
    0)
      break
      ;;
    *)
      echo "$FAIL_CHOISE"
      ;;
  esac
done
}

create_mysql_users () {
  clear
  tput cup $(tput lines) 0
  read -s -p "$MYSQL_ROOT_PASSWORD_NEED " MYSQL_PASSWORD
  echo
    clear
    username_mysql=$1
    password_user_mysql=$2
    
    # Проверка существования пользователя
    exists=$(mysql -u root -p $MYSQL_PASSWORD -e "SELECT EXISTS(SELECT 1 FROM mysql.user WHERE user = '$username_mysql');")
    
    if [ $exists -eq 1 ]; then
        echo "$MYSQL_USER_EXISTS"
        read -n 1 -s -r -p "$ANYKEY_CONTINUE"
    fi
    
    # Создание пользователя
    mysql -u root -p $MYSQL_PASSWORD -e "CREATE USER '$username_mysql'@'localhost' IDENTIFIED BY '$password_user_mysql';"
    
    # Обновление привилегий
    mysql -u root -p $MYSQL_PASSWORD -e "FLUSH PRIVILEGES;"
    
    echo "$CHANGE_SUCCSESS"
    read -n 1 -s -r -p "$ANYKEY_CONTINUE"

}

delete_mysql_users () {
  clear
  tput cup $(tput lines) 0
  read -s -p "$MYSQL_ROOT_PASSWORD_NEED " MYSQL_PASSWORD
  echo
    clear
    username_mysql=$1
    
    # Проверка существования пользователя
    exists=$(mysql -u root -p $MYSQL_PASSWORD -e "SELECT EXISTS(SELECT 1 FROM mysql.user WHERE user = '$username_mysql');")
    
    if [ $exists -eq 0 ]; then
        echo "$MYSQL_USER_NON_EXISTS"
        read -n 1 -s -r -p "$ANYKEY_CONTINUE"
    fi
    
    # Удаление пользователя
    mysql -u root -p $MYSQL_PASSWORD -e "DROP USER '$username_mysql'@'localhost';"
    
    # Обновление привилегий
    mysql -u root -p $MYSQL_PASSWORD -e "FLUSH PRIVILEGES;"
    
    echo "$CHANGE_SUCCSESS"
    read -n 1 -s -r -p "$ANYKEY_CONTINUE"

}

change_mysql_users_password () {
  clear
  tput cup $(tput lines) 0
  read -s -p "$MYSQL_ROOT_PASSWORD_NEED " MYSQL_PASSWORD
  echo
  clear
  username_mysql=$1
  password_user_mysql=$2
# Проверка существования пользователя
    exists=$(mysql -u root -p $MYSQL_PASSWORD -e "SELECT EXISTS(SELECT 1 FROM mysql.user WHERE user = '$username_mysql');")
    
    if [ $exists -eq 0 ]; then
        echo "$MYSQL_USER_NON_EXISTS"
        read -n 1 -s -r -p "$ANYKEY_CONTINUE"
    fi
    
    # Удаление пользователя
    mysql -u root -p $MYSQL_PASSWORD -e "ALTER USER '$username_mysql'@'localhost' IDENTIFIED BY '$password_user_mysql';"
    mysql -u root -p $MYSQL_PASSWORD -e "flush privileges;"

# Проверяем статус выполнения команды MySQL
if [ $? -eq 0 ]; then
  echo "$CHANGE_SUCCSESS"
  read -n 1 -s -r -p "$ANYKEY_CONTINUE"
else
  echo "$CHANGE_FAILED"
  read -n 1 -s -r -p "$ANYKEY_CONTINUE"
fi

}

mysql_manage_db () {
while true; do
  clear
  tput cup $(tput lines) 0
  read -s -p "$MYSQL_ROOT_PASSWORD_NEED " MYSQL_PASSWORD
  echo
  clear
  #echo "$SELECT_ACTION"
  #echo "1. $MYSQL_DB_MANAGE_MENU1"
  #echo "2. $MYSQL_DB_MANAGE_MENU2"
  #echo "3. $MYSQL_DB_MANAGE_MENU3"
  #echo "4. $MYSQL_DB_MANAGE_MENU4"
  #echo "0. $BACK"
  #echo " "
    echo "        ___                      _        ___   ___ " 
    echo "       / __\___  _ __  ___  ___ | | ___  / __\ / _ |" 
    echo "      / /  / _ \| '_ \/ __|/ _ \| |/ _ \/ /   / /_)/"
    echo "     / /__| (_) | | | \__ \ (_) | |  __/ /___/ ___/ "
    echo "     \____/\___/|_| |_|___/\___/|_|\___\____/\/     "
    echo ""
    echo "========================================================="
    echo ""
    echo "                 $SELECT_ACTION"
    echo ""
    echo "========================================================="
    echo ""
    echo "              1. $MYSQL_DB_MANAGE_MENU1"
    echo "              2. $MYSQL_DB_MANAGE_MENU2"
    echo "              3. $MYSQL_DB_MANAGE_MENU3"
    echo "              4. $MYSQL_DB_MANAGE_MENU4"
    echo ""
    echo "              0. $BACK"
    echo ""
    echo "========================================================="
    echo ""
  # Выполнение команды MySQL и получение списка баз данных
  DATABASES=$(mysql -h "localhost" -u "root" -p"${MYSQL_PASSWORD}" -e "SHOW DATABASES;" --silent)
  # Проверка успешности выполнения команды MySQL
  if [ $? -eq 0 ]; then
  echo "$MYSQL_DB_LIST"
  echo "${DATABASES}"
  else
  echo "$MYSQL_DB_LIST_ERROR"
  fi
  tput cup $(tput lines) 0
  read -p "$ENTER_NUMBER" choice
  case $choice in
    1)
      clear
      read -p "$ENTER_USERNAME " username_mysql
      read -p "$ENTER_NEW_PASSWORD " password_user_mysql
      read -p "$ENTER_DB_NAME " database_mysql_name
      create_mysql_db $username_mysql $password_user_mysql $database_mysql_name
      ;;
    2)
      clear
      read -p "$ENTER_DB_NAME " database_mysql_name
      delete_mysql_db $database_mysql_name
      ;;
    3)
      clear
      read -p "$ENTER_USERNAME " username_mysql
      read -p "$ENTER_PASSWORD " password_user_mysql
      read -p "$ENTER_DB_NAME " database_mysql_name
      bind_mysql_db $username_mysql $password_user_mysql $database_mysql_name
      ;;
    4)
      clear
      read -p "$ENTER_USERNAME " username_mysql
      read -p "$ENTER_DB_NAME " database_mysql_name
      unbind_mysql_db $username_mysql $database_mysql_name
      ;;
    0)
      break
      ;;
    *)
      echo "$FAIL_CHOISE"
      ;;
  esac
done
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

delete_mysql_db () {
clear
  tput cup $(tput lines) 0
  read -s -p "$MYSQL_ROOT_PASSWORD_NEED " MYSQL_PASSWORD
  echo
  clear
  database_mysql_name=$1
  mysql -u root -p $MYSQL_PASSWORD -e "DROP DATABASE $database_mysql_name;"
  mysql -u root -p $MYSQL_PASSWORD -e "flush privileges;"
if [ $? -eq 0 ]; then
  echo "$CHANGE_SUCCSESS"
  read -n 1 -s -r -p "$ANYKEY_CONTINUE"
else
  echo "$CHANGE_FAILED"
  read -n 1 -s -r -p "$ANYKEY_CONTINUE"
fi
}

bind_mysql_db () {
clear
  tput cup $(tput lines) 0
  read -s -p "$MYSQL_ROOT_PASSWORD_NEED " MYSQL_PASSWORD
  echo
  clear
  username_mysql=$1
  password_user_mysql=$2
  database_mysql_name=$3
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

unbind_mysql_db () {
  clear
  tput cup $(tput lines) 0
  read -s -p "$MYSQL_ROOT_PASSWORD_NEED " MYSQL_PASSWORD
  echo
  clear
  username_mysql=$1
  database_mysql_name=$2
  mysql -u root -p $MYSQL_PASSWORD -e "REVOKE ALL PRIVILEGES ON $database_mysql_name.localhost FROM $username_mysql@localhost;"
  mysql -u root -p $MYSQL_PASSWORD -e "flush privileges;"
  if [ $? -eq 0 ]; then
  echo "$CHANGE_SUCCSESS"
  read -n 1 -s -r -p "$ANYKEY_CONTINUE"
  else
  echo "$CHANGE_FAILED"
  read -n 1 -s -r -p "$ANYKEY_CONTINUE"
  fi
}

run_mysql_autofix() {
    if ! command -v mysql &> /dev/null; then
      clear
      echo "$NON_SCREEN"
      tput cup $(tput lines) 0
      read -p "$LIKE_INSTALL" -n 1 apply_changes
      if [[ $apply_changes == "1" ]]; then
        apt-get install screen
        read -n 1 -s -r -p "$ANYKEY_CONTINUE"
      else
        echo "$CANCELL"
        read -n 1 -s -r -p "$ANYKEY_CONTINUE"
      fi
      else
      echo " "
      fi
    clear
    read -s -p "$MYSQL_ROOT_PASSWORD_NEED " MYSQL_PASSWORD
    screen -dmS mysql_autofix bash -c mysqlcheck --all-databases --auto-repair --optimize --user=root --password=$MYSQL_PASSWORD
    echo "$RUN_SUCCSESS"
    read -n 1 -s -r -p "$ANYKEY_CONTINUE"
}

add_email_domain () {
  clear
  domain=$1
  # Добавляем домен в конфигурацию Exim
  sed -i "/^dc_other_hostnames/s/$/,$domain/" /etc/exim4/update-exim4.conf
  update-exim4.conf
  service exim reload
  # Добавляем домен в конфигурацию Postfix
  postconf -e "myhostname = $domain"
  service postfix reload
  echo "$CHANGE_SUCCSESS"
  read -n 1 -s -r -p "$ANYKEY_CONTINUE"
}

delete_email_domain () {
  clear
  domain=$1
    update-exim4.conf remove dc_other_hostnames="$domain"
    service exim reload
    postconf -e "mydestination = $(sudo postconf -h mydestination | sed "s/<$domain>//g")"
    service postfix reload
    echo "$CHANGE_SUCCSESS"
    read -n 1 -s -r -p "$ANYKEY_CONTINUE"
}

# Функция для добавления пользователя
add_email_user() {
  clear
    domain=$1
    email_user=$2
    password_email_user=$3
    # Создание пользователя в Postfix
    echo "$email_user@$domain $password_email_user" >> /etc/postfix/vmailbox
    postmap /etc/postfix/vmailbox

    # Создание пользователя в Exim
    echo "$email_user: $password_email_user" >> /etc/exim/passwd
    makepasswd --clearfrom=- --crypt-md5 <<< "$password_email_user" >> /etc/exim/passwd
    makepasswd --clearfrom=- --crypt-md5 <<< "$password_email_user" | awk '{print $2}' >> /etc/exim/passwd.db
    chmod 640 /etc/exim/passwd /etc/exim/passwd.db

    # Перезапуск сервисов
    systemctl restart postfix
    systemctl restart exim
    echo "$CHANGE_SUCCSESS"
    read -n 1 -s -r -p "$ANYKEY_CONTINUE"
}

# Функция для удаления пользователя
delete_email_user() {
  clear
    domain=$1
    email_user=$2

    # Удаление пользователя из Postfix
    sed -i "/^$email_user@$domain/d" /etc/postfix/vmailbox
    postmap /etc/postfix/vmailbox

    # Удаление пользователя из Exim
    sed -i "/^$email_user:/d" /etc/exim/passwd
    sed -i "/^.*$email_user:.*/d" /etc/exim/passwd.db
    chmod 640 /etc/exim/passwd /etc/exim/passwd.db

    # Перезапуск сервисов
    systemctl restart postfix
    systemctl restart exim
    echo "$CHANGE_SUCCSESS"
    read -n 1 -s -r -p "$ANYKEY_CONTINUE"
}

# Функция для настройки DKIM
configure_dkim() {
  clear
    domain=$1
    dkim_selector=$2

    # Генерация ключей DKIM
    opendkim-genkey -D /etc/opendkim/keys -d $domain -s $dkim_selector
    chown -R opendkim:opendkim /etc/opendkim/keys

    # Настройка Postfix
    echo "milter_protocol = 6" >> /etc/postfix/main.cf
    echo "milter_default_action = accept" >> /etc/postfix/main.cf
    echo "smtpd_milters = inet:localhost:8891" >> /etc/postfix/main.cf
    echo "non_smtpd_milters = inet:localhost:8891" >> /etc/postfix/main.cf

    # Настройка Exim
    echo "DKIM_DOMAIN = $domain" >> /etc/exim/exim.conf
    echo "DKIM_PRIVATE_KEY = /etc/opendkim/keys/default.private" >> /etc/exim/exim.conf
    echo "DKIM_SELECTOR = $dkim_selector" >> /etc/exim/exim.conf
    echo "DKIM_CANON = relaxed" >> /etc/exim/exim.conf
    echo "DKIM_STRICT = 0" >> /etc/exim/exim.conf

    # Перезапуск сервисов
    systemctl restart postfix
    systemctl restart exim
    echo "$DKIM_OPEN_DKIM"
    cat /etc/opendkim/keys/$dkim_selector.txt
    read -n 1 -s -r -p "$ANYKEY_CONTINUE"
}

# Функция для настройки SSL-сертификата
configure_email_ssl() {
  clear
  crt=$1
  priv_key=$2
    # Настройка SSL-сертификата в Postfix
    echo "smtpd_tls_cert_file = $crt" >> /etc/postfix/main.cf
    echo "smtpd_tls_key_file = $priv_key" >> /etc/postfix/main.cf

    # Настройка SSL-сертификата в Exim
    echo "tls_certificate = $crt" >> /etc/exim/exim.conf
    echo "tls_privatekey = $privkey" >> /etc/exim/exim.conf

    # Перезапуск сервисов
    systemctl restart postfix
    systemctl restart exim
    echo "$CHANGE_SUCCSESS"
    read -n 1 -s -r -p "$ANYKEY_CONTINUE"
}

# Функция для интеграции аккаунтов с LDAP
configure_ldap_integration() {
    clear
    # Настройка интеграции с LDAP в Postfix
    read -p "$ENTER_LDAP_DOMAIN " ldap_server_address
    read -p "$ENTER_LDAP_SEARCHE_BASE " ldap_search_base
    echo "virtual_mailbox_maps = ldap:/etc/postfix/ldap-users.cf" >> /etc/postfix/main.cf
    echo "virtual_alias_maps = ldap:/etc/postfix/ldap-aliases.cf" >> /etc/postfix/main.cf

    # Настройка интеграции с LDAP в Exim
    echo "ldap_default_servers = ldap://$ldap_server_address" >> /etc/exim/exim.conf
    echo "ldap_default_searchbase = $ldap_search_base" >> /etc/exim/exim.conf
    read -p "$ENTER_LDAP_DN " ldap_bind_dn
    read -sp "$ENTER_LDAP_PASSWORD " ldap_bind_password
    echo "ldap_default_bind_dn = $ldap_bind_dn" >> /etc/exim/exim.conf
    echo "ldap_default_bind_pw = $ldap_bind_password" >> /etc/exim/exim.conf

    # Перезапуск сервисов
    systemctl restart postfix
    systemctl restart exim
    echo "$CHANGE_SUCCSESS"
    read -n 1 -s -r -p "$ANYKEY_CONTINUE"
}

list_email_domains() {
  clear
    exim_conf="/etc/exim/exim.conf"

    if [[ -f "$exim_conf" ]]; then
        # Используем утилиту grep для поиска строк, содержащих "domainlist"
        # Выводим только значения после "domainlist"
        domains=$(grep "domainlist" "$exim_conf" | awk -F"domainlist" '{print $2}')

        if [[ -n "$domains" ]]; then
            echo "$EMAIL_LIST"
            echo "$domains"
        else
            echo "$NON_EMAIL_DOMAINS"
        fi
    else
        echo "$NON_EXIM_CONFIG"
    fi
    read -n 1 -s -r -p "$ANYKEY_CONTINUE"
}

list_email_users () {
clear
postconf -h virtual_mailbox_domains | tr -d '[],' | awk '{for (i=2; i<=NF; i++) print $i}'
read -n 1 -s -r -p "$ANYKEY_CONTINUE"
}

change_email_users_password () {
email_user=$1
password_email_user=$2
  # Изменяем пароль у пользователя в Postfix
  echo "$new_password" | postmap -q "$username" /etc/postfix/virtual_mailbox_password

  # Изменяем пароль у пользователя в Exim
  htpasswd -b /etc/exim4/passwd "$username" "$new_password"
  echo "$CHANGE_SUCCSESS"
  read -n 1 -s -r -p "$ANYKEY_CONTINUE"
}

email_manage () {
if ! command -v exim4 &> /dev/null; then
      clear
      echo "$NON_EXIM"
      tput cup $(tput lines) 0
      read -p "$LIKE_INSTALL" -n 1 apply_changes
      if [[ $apply_changes == "1" ]]; then
        apt install gnupng
        apt install exim4-daemon-heavy
        read -n 1 -s -r -p "$ANYKEY_CONTINUE"
      else
        echo "$CANCELL"
        read -n 1 -s -r -p "$ANYKEY_CONTINUE"
      fi
      else
      echo " "
      fi
      if ! command -v postfix &> /dev/null; then
      clear
      echo "$NON_POSTFIX"
      tput cup $(tput lines) 0
      read -p "$LIKE_INSTALL" -n 1 apply_changes
      if [[ $apply_changes == "1" ]]; then
        apt install gnupng
        apt install postfix
        read -n 1 -s -r -p "$ANYKEY_CONTINUE"
      else
        echo "$CANCELL"
        read -n 1 -s -r -p "$ANYKEY_CONTINUE"
      fi
      else
      echo " "
      fi
    while true; do
    clear
    echo "        ___                      _        ___   ___ " 
    echo "       / __\___  _ __  ___  ___ | | ___  / __\ / _ |" 
    echo "      / /  / _ \| '_ \/ __|/ _ \| |/ _ \/ /   / /_)/"
    echo "     / /__| (_) | | | \__ \ (_) | |  __/ /___/ ___/ "
    echo "     \____/\___/|_| |_|___/\___/|_|\___\____/\/     "
    echo ""
    echo "========================================================="
    echo ""
    echo "                 $SELECT_ACTION"
    echo ""
    echo "========================================================="
    echo ""
    echo "              1. $EMAIL_MANAGE_MENU1"
    echo "              2. $EMAIL_MANAGE_MENU2"
    echo ""
    echo "              3. $EMAIL_MANAGE_MENU3"
    echo "              4. $EMAIL_MANAGE_MENU4"
    echo "              5. $EMAIL_MANAGE_MENU5"
    echo ""
    echo "              6. $EMAIL_MANAGE_MENU6"
    echo "              7. $EMAIL_MANAGE_MENU7"
    echo ""
    echo "              8. $EMAIL_MANAGE_MENU8"
    echo "              9. $EMAIL_MANAGE_MENU9"
    echo "              10. $EMAIL_MANAGE_MENU10"
    echo ""
    echo "              0. $BACK"
  tput cup $(tput lines) 0
  read -p "$ENTER_NUMBER" choice

case $command in
    1)
        clear
        read -p "$ENTER_DOMAIN " domain
        add_email_domain $domain
        ;;
    2)
        clear
        read -p "$ENTER_DOMAIN " domain
        delete_email_domain $domain
        ;;
    3)  
        clear
        read -p "$ENTER_DOMAIN " domain
        read -p "$ENTER_USERNAME " email_user
        read -p "$ENTER_PASSWORD " password_email_user
        create_email_user $domain $email_user $password_email_user
        ;;
    4)
        clear
        read -p "$ENTER_DOMAIN " domain
        read -p "$ENTER_USERNAME " email_user
        delete_email_user $domain $email_user
        ;;
    5)
        clear
        read -p "$ENTER_USERNAME " email_user
        read -p "$ENTER_NEW_PASSWORD " password_email_user
        change_email_users_password $email_user $password_email_user
        ;;
    6)
        list_email_users
        ;;
    7)
        list_email_domains
        ;;
    8)
        clear
        read -P "$ENTER_PATH_TO_CRT " crt
        read -P "$ENTER_PATH_TO_PRIVATE_KEY " priv_key
        configure_ssl $crt $priv_key
        ;;
    9)
        configure_ldap_integration
        ;;
    10)
        clear
        read -p "$ENTER_DOMAIN " domain
        read -p "$ENTER_DKIM_SELECTOR " dkim_selector 
        configure_dkim $domain $dkim_selector
        ;;
    0)
        break
        ;;
    *)
        echo "$FAIL_CHOISE"
        ;;
esac
done
}

# Основное меню
while true; do

# Загрузка языковых ресурсов
load_language_resources

  if [[ $EUID -ne 0 ]]; then
  echo "$NON_ROOT" 
  exit 1
  fi
    width=$(tput cols)
    clear
    echo "        ___                      _        ___   ___ " 
    echo "       / __\___  _ __  ___  ___ | | ___  / __\ / _ |" 
    echo "      / /  / _ \| '_ \/ __|/ _ \| |/ _ \/ /   / /_)/"
    echo "     / /__| (_) | | | \__ \ (_) | |  __/ /___/ ___/ "
    echo "     \____/\___/|_| |_|___/\___/|_|\___\____/\/     "
    echo ""
    echo "========================================================="
    echo ""
    echo "                 $MAIN_MENU"
    echo ""
    echo "========================================================="
    echo ""
    echo "              1. $MAIN_MENU1"
    echo "              2. $MAIN_MENU2"
    echo ""
    echo "              3. $MAIN_MENU3"
    echo "              4. $MAIN_MENU4"
    echo "              5. $MAIN_MENU5"
    echo "              6. $MAIN_MENU6"
    echo ""
    echo "              7. $MAIN_MENU7"
    echo "              8. $MAIN_MENU8"
    echo "              0. $LEXIT"

    tput cup $(tput lines) 0
    read -p "$ENTER_NUMBER" choice

    case $choice in
        1)
            reboot_host
            ;;
        2)
            shutdown_host
            ;;
        3)
            configure_network
            ;;
        4)
            manage_resources
            ;;
        5)
            email_manage
            ;;
        6)
            mysql_manage
            ;;
        7)  
            change_language
            ;;
        8)
            mv /opt/ccp/update.sh /tmp/update.sh
            /tmp/update.sh
            ;;
        0)
            clear
            exit 0
            ;;
        *)
            echo "$FAIL_CHOISE"
            ;;
    esac
done
