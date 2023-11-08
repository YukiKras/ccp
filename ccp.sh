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
    # Определение количества символов в строке терминала
cols=$(tput cols)

# Создание строки, состоящей из символов "="
line=$(printf "%${cols}s" | tr ' ' '=')
external_ip=$(wget -qO- https://ipinfo.io/ip)
    width=$(tput cols)
    echoc "   ___                      _        ___   ___ " $width
    echoc "  / __\___  _ __  ___  ___ | | ___  / __\ / _ |" $width
    echoc " / /  / _ \| '_ \/ __|/ _ \| |/ _ \/ /   / /_)/" $width
    echoc "/ /__| (_) | | | \__ \ (_) | |  __/ /___/ ___/ " $width
    echoc "\____/\___/|_| |_|___/\___/|_|\___\____/\/     " $width
    echo ""
    echo $line
    echo ""
    echoc "$SELECT_ACTION" $width
    echo ""
    echo $line
    echo ""
    echo "         1. $NETWORK_MENU1 $external_ip"
    echo "         2. $NETWORK_MENU2"
    echo "         3. $NETWORK_MENU3"
    echo "         4. $NETWORK_MENU4"
    echo ""
    echo "         0. $BACK"
        tput cup $(tput lines) 0
        read -p "$ENTER_NUMBER" choice

        case $choice in
            1)
                show_network_settings
                ;;
            2)
                clear
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
            4)
                clear
                read -p "$ENTER_NEW_HOSTNAME " hostname
                hostnamectl set-hostname "$hostname"
                echo "$CHANGE_SUCCSESS"
                read -p "$LIKE_REBOOT " -n 1 apply_changes
                if [ "$apply_changes" == "1" ]; then
                reboot_host
                else
                echo "$CANCELL"
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
# Определение количества символов в строке терминала
cols=$(tput cols)

# Создание строки, состоящей из символов "="
line=$(printf "%${cols}s" | tr ' ' '=')
    width=$(tput cols)
    echoc "   ___                      _        ___   ___ " $width
    echoc "  / __\___  _ __  ___  ___ | | ___  / __\ / _ |" $width
    echoc " / /  / _ \| '_ \/ __|/ _ \| |/ _ \/ /   / /_)/" $width
    echoc "/ /__| (_) | | | \__ \ (_) | |  __/ /___/ ___/ " $width
    echoc "\____/\___/|_| |_|___/\___/|_|\___\____/\/     " $width
    echo ""
    echo $line
    echo ""
    echoc "$SELECT_ACTION" $width
    echo ""
    echo $line
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
# Определение количества символов в строке терминала
cols=$(tput cols)

# Создание строки, состоящей из символов "="
line=$(printf "%${cols}s" | tr ' ' '=')
    width=$(tput cols)
    echoc "   ___                      _        ___   ___ " $width
    echoc "  / __\___  _ __  ___  ___ | | ___  / __\ / _ |" $width
    echoc " / /  / _ \| '_ \/ __|/ _ \| |/ _ \/ /   / /_)/" $width
    echoc "/ /__| (_) | | | \__ \ (_) | |  __/ /___/ ___/ " $width
    echoc "\____/\___/|_| |_|___/\___/|_|\___\____/\/     " $width
    echo ""
    echo $line
    echo ""
    echoc "$SELECT_ACTION" $width
    echo ""
    echo $line
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
    # Определение количества символов в строке терминала
cols=$(tput cols)

# Создание строки, состоящей из символов "="
line=$(printf "%${cols}s" | tr ' ' '=')
    width=$(tput cols)
    echoc "   ___                      _        ___   ___ " $width
    echoc "  / __\___  _ __  ___  ___ | | ___  / __\ / _ |" $width
    echoc " / /  / _ \| '_ \/ __|/ _ \| |/ _ \/ /   / /_)/" $width
    echoc "/ /__| (_) | | | \__ \ (_) | |  __/ /___/ ___/ " $width
    echoc "\____/\___/|_| |_|___/\___/|_|\___\____/\/     " $width
    echo ""
    echo $line
    echo ""
    echoc "$SELECT_LANG" $width
    echo ""
    echo $line
    echo ""
    echoc "1. English" $width
    echoc "2. Русский" $width
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
# Определение количества символов в строке терминала
cols=$(tput cols)

# Создание строки, состоящей из символов "="
line=$(printf "%${cols}s" | tr ' ' '=')
    width=$(tput cols)
    echoc "   ___                      _        ___   ___ " $width
    echoc "  / __\___  _ __  ___  ___ | | ___  / __\ / _ |" $width
    echoc " / /  / _ \| '_ \/ __|/ _ \| |/ _ \/ /   / /_)/" $width
    echoc "/ /__| (_) | | | \__ \ (_) | |  __/ /___/ ___/ " $width
    echoc "\____/\___/|_| |_|___/\___/|_|\___\____/\/     " $width
    echo ""
    echo $line
    echo ""
    echoc "$SELECT_ACTION" $width
    echo ""
    echo $line
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
# Определение количества символов в строке терминала
cols=$(tput cols)

# Создание строки, состоящей из символов "="
line=$(printf "%${cols}s" | tr ' ' '=')
    width=$(tput cols)
    echoc "   ___                      _        ___   ___ " $width
    echoc "  / __\___  _ __  ___  ___ | | ___  / __\ / _ |" $width
    echoc " / /  / _ \| '_ \/ __|/ _ \| |/ _ \/ /   / /_)/" $width
    echoc "/ /__| (_) | | | \__ \ (_) | |  __/ /___/ ___/ " $width
    echoc "\____/\___/|_| |_|___/\___/|_|\___\____/\/     " $width
    echo ""
    echo $line
    echo ""
    echoc "$SELECT_ACTION" $width
    echo ""
    echo $line
    echo ""
    echo "                    1. $MYSQL_USERS_MANAGE_MENU1"
    echo "                    2. $MYSQL_USERS_MANAGE_MENU2"
    echo "                    3. $MYSQL_USERS_MANAGE_MENU3"
    echo ""
    echo "                    0. $BACK"
    echo ""
    echo $line
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
  username_mysql=$1
  password_user_mysql=$2
  tput cup $(tput lines) 0
  read -s -p "$MYSQL_ROOT_PASSWORD_NEED " MYSQL_PASSWORD
  # Переменные для подключения к MySQL
  MYSQL_HOST="localhost"
  MYSQL_USER="root"
  QUERY="SELECT EXISTS(SELECT 1 FROM mysql.user WHERE user = '$username_mysql');"
  mysql -h "${MYSQL_HOST}" -u "${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -e "${QUERY}" --silent

  echo
    clear  
    # Проверка существования пользователя
    #exists=$(mysql -u root -p $MYSQL_PASSWORD -e "SELECT EXISTS(SELECT 1 FROM mysql.user WHERE user = '$username_mysql');")
    
    if [ $exists -eq 1 ]; then
        echo "$MYSQL_USER_EXISTS"
        read -n 1 -s -r -p "$ANYKEY_CONTINUE"
    fi
    
    # Создание пользователя
    #mysql -u root -p $MYSQL_PASSWORD -e "CREATE USER '$username_mysql'@'localhost' IDENTIFIED BY '$password_user_mysql';"
    QUERY="CREATE USER '$username_mysql'@'localhost' IDENTIFIED BY '$password_user_mysql');"
    mysql -h "${MYSQL_HOST}" -u "${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -e "${QUERY}" --silent
    
    # Обновление привилегий
    #mysql -u root -p $MYSQL_PASSWORD -e "FLUSH PRIVILEGES;"
    QUERY="FLUSH PRIVILEGES;"
    mysql -h "${MYSQL_HOST}" -u "${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -e "${QUERY}" --silent

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
    MYSQL_HOST="localhost"
  MYSQL_USER="root"
  QUERY="SELECT EXISTS(SELECT 1 FROM mysql.user WHERE user = '$username_mysql');"
  mysql -h "${MYSQL_HOST}" -u "${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -e "${QUERY}" --silent
    # Проверка существования пользователя
    #exists=$(mysql -u root -p $MYSQL_PASSWORD -e "SELECT EXISTS(SELECT 1 FROM mysql.user WHERE user = '$username_mysql');")
    
    if [ $exists -eq 0 ]; then
        echo "$MYSQL_USER_NON_EXISTS"
        read -n 1 -s -r -p "$ANYKEY_CONTINUE"
    fi
    
    # Удаление пользователя
    #mysql -u root -p $MYSQL_PASSWORD -e "DROP USER '$username_mysql'@'localhost';"
      QUERY="DROP USER '$username_mysql'@'localhost');"
  mysql -h "${MYSQL_HOST}" -u "${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -e "${QUERY}" --silent
    
    # Обновление привилегий
    #mysql -u root -p $MYSQL_PASSWORD -e "FLUSH PRIVILEGES;"
    QUERY="FLUSH PRIVILEGES;"
    mysql -h "${MYSQL_HOST}" -u "${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -e "${QUERY}" --silent
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
    #exists=$(mysql -u root -p $MYSQL_PASSWORD -e "SELECT EXISTS(SELECT 1 FROM mysql.user WHERE user = '$username_mysql');")
    MYSQL_HOST="localhost"
  MYSQL_USER="root"
  QUERY="SELECT EXISTS(SELECT 1 FROM mysql.user WHERE user = '$username_mysql');"
  mysql -h "${MYSQL_HOST}" -u "${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -e "${QUERY}" --silent
    if [ $exists -eq 0 ]; then
        echo "$MYSQL_USER_NON_EXISTS"
        read -n 1 -s -r -p "$ANYKEY_CONTINUE"
    fi
    
    # Удаление пользователя
    QUERY="ALTER USER '$username_mysql'@'localhost' IDENTIFIED BY '$password_user_mysql';"
    mysql -h "${MYSQL_HOST}" -u "${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -e "${QUERY}" --silent
    #mysql -u root -p $MYSQL_PASSWORD -e "ALTER USER '$username_mysql'@'localhost' IDENTIFIED BY '$password_user_mysql';"
    QUERY="FLUSH PRIVILEGES;"
    mysql -h "${MYSQL_HOST}" -u "${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -e "${QUERY}" --silent
    #mysql -u root -p $MYSQL_PASSWORD -e "flush privileges;"

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
  # Определение количества символов в строке терминала
cols=$(tput cols)

# Создание строки, состоящей из символов "="
line=$(printf "%${cols}s" | tr ' ' '=')
    width=$(tput cols)
    echoc "   ___                      _        ___   ___ " $width
    echoc "  / __\___  _ __  ___  ___ | | ___  / __\ / _ |" $width
    echoc " / /  / _ \| '_ \/ __|/ _ \| |/ _ \/ /   / /_)/" $width
    echoc "/ /__| (_) | | | \__ \ (_) | |  __/ /___/ ___/ " $width
    echoc "\____/\___/|_| |_|___/\___/|_|\___\____/\/     " $width
    echo ""
    echo $line
    echo ""
    echoc "$SELECT_ACTION" $width
    echo ""
    echo $line
    echo ""
    echo "              1. $MYSQL_DB_MANAGE_MENU1"
    echo "              2. $MYSQL_DB_MANAGE_MENU2"
    echo "              3. $MYSQL_DB_MANAGE_MENU3"
    echo "              4. $MYSQL_DB_MANAGE_MENU4"
    echo ""
    echo "              0. $BACK"
    echo ""
    echo $line
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
    if ! command -v screen &> /dev/null; then
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
  while true; do
#if ! command -v exim4 &> /dev/null; then
#      clear
#      echo "$NON_EXIM"
#      tput cup $(tput lines) 0
#      read -p "$LIKE_INSTALL" -n 1 apply_changes
#      if [[ $apply_changes == "1" ]]; then
#        apt install gnupng
#        apt install exim4-daemon-heavy
#        read -n 1 -s -r -p "$ANYKEY_CONTINUE"
#      else
#        echo "$CANCELL"
#        read -n 1 -s -r -p "$ANYKEY_CONTINUE"
#      fi
#      else
#      echo " "
#      fi
#      if ! command -v postfix &> /dev/null; then
#      clear
#      echo "$NON_POSTFIX"
#      tput cup $(tput lines) 0
#      read -p "$LIKE_INSTALL" -n 1 apply_changes
#      if [[ $apply_changes == "1" ]]; then
#        apt install gnupng
#        apt install postfix
#        echo "$CHANGE_SUCCSESS"
#        read -n 1 -s -r -p "$ANYKEY_CONTINUE"
#      else
#        echo "$CANCELL"
#        read -n 1 -s -r -p "$ANYKEY_CONTINUE"
#      fi
#      else
#      echo " "
#      fi
    clear
    # Определение количества символов в строке терминала
    cols=$(tput cols)

# Создание строки, состоящей из символов "="
    line=$(printf "%${cols}s" | tr ' ' '=')
    width=$(tput cols)
    echoc "   ___                      _        ___   ___ " $width
    echoc "  / __\___  _ __  ___  ___ | | ___  / __\ / _ |" $width
    echoc " / /  / _ \| '_ \/ __|/ _ \| |/ _ \/ /   / /_)/" $width
    echoc "/ /__| (_) | | | \__ \ (_) | |  __/ /___/ ___/ " $width
    echoc "\____/\___/|_| |_|___/\___/|_|\___\____/\/     " $width
    echo ""
    echo $line
    echo ""
    echo "$EMAIL_NOTE"
    echo ""
    echo $line
    echo ""
    echoc "$SELECT_ACTION" $width
    echo ""
    echo $line
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

case $choise in
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

vpn_manage () {
  while true; do
    clear
    # Определение количества символов в строке терминала
    cols=$(tput cols)

# Создание строки, состоящей из символов "="
    line=$(printf "%${cols}s" | tr ' ' '=')
    width=$(tput cols)
    echoc "   ___                      _        ___   ___ " $width
    echoc "  / __\___  _ __  ___  ___ | | ___  / __\ / _ |" $width
    echoc " / /  / _ \| '_ \/ __|/ _ \| |/ _ \/ /   / /_)/" $width
    echoc "/ /__| (_) | | | \__ \ (_) | |  __/ /___/ ___/ " $width
    echoc "\____/\___/|_| |_|___/\___/|_|\___\____/\/     " $width
    echo ""
    echo $line
    echo ""
    echoc "$SELECT_ACTION" $width
    echo ""
    echo $line
    echo ""
    echo "              1. $VPN_MANAGE_MENU1"
    echo "              2. $VPN_MANAGE_MENU2"
    echo "              0. $BACK"
  tput cup $(tput lines) 0
  read -p "$ENTER_NUMBER" choice
  case $choice in
  1)
  clear
if [ -f "/root/wireguard-install.sh" ]; then
  /root/wireguard-install.sh
else
      echo "$NON_WIREGUARD"
      tput cup $(tput lines) 0
      read -p "$LIKE_INSTALL" -n 1 apply_changes
  if [ "$apply_changes" == "1" ]; then
    wget -P /root https://raw.githubusercontent.com/angristan/wireguard-install/master/wireguard-install.sh
    chmod +x /root/wireguard-install.sh
    echo "$CHANGE_SUCCSESS"
    read -n 1 -s -r -p "$ANYKEY_CONTINUE"
  else
    echo "$CANCELL"
    read -n 1 -s -r -p "$ANYKEY_CONTINUE"
  fi
fi
  ;;
  2)
  clear
  if [ -f "/root/openvpn-install.sh" ]; then
  /root/openvpn-install.sh
else
      echo "$NON_OPENVPN"
      tput cup $(tput lines) 0
      read -p "$LIKE_INSTALL" -n 1 apply_changes
  if [ "$apply_changes" == "1" ]; then
    wget -P /root https://raw.githubusercontent.com/angristan/openvpn-install/master/openvpn-install.sh
    chmod +x /root/openvpn-install.sh
    read -n 1 -s -r -p "$ANYKEY_CONTINUE"
  else
    echo "$CANCELL"
    read -n 1 -s -r -p "$ANYKEY_CONTINUE"
  fi
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

# Функция для центровки текста
echoc() {
    local text="$1"
    local width="$2"
    local padding=$(( (width - ${#text}) / 2 ))
    printf "%*s%s%*s
" $padding "" "$text" $padding ""
}

ask_question() {
    local question=$1
    local variable=$2
    read -p "$question" answer
    case "$answer" in
        "0"|"1")
            eval "$variable=$answer"
            ;;
        *)
            echo "$FAIL_CHOISE"
            ask_question "$question" "$variable"
            ;;
    esac
}

web_manage () {
  while true; do
  if ! command -v nginx &> /dev/null; then
      clear
      echo "$NON_NGINX"
      tput cup $(tput lines) 0
      read -p "$LIKE_INSTALL" -n 1 apply_changes
      if [[ $apply_changes == "1" ]]; then
        apt install nginx
        read -n 1 -s -r -p "$ANYKEY_CONTINUE"
      else
        echo "$CANCELL"
        read -n 1 -s -r -p "$ANYKEY_CONTINUE"
        break
      fi
      else
      echo " "
      fi
  if ! command -v apache2 &> /dev/null; then
      clear
      echo "$NON_APACHE"
      tput cup $(tput lines) 0
      read -p "$LIKE_INSTALL" -n 1 apply_changes
      if [[ $apply_changes == "1" ]]; then
        apt install apache2
        mkdir /var/log/apache2/domains/
        chown -R www-data:www-data /var/log/apache2/domains/
        chmod -R 755 /var/log/apache2/domains/
        chmod -R 755 /var/log/apache2/domains/*
        a2enmod proxy rewrite ssl headers proxy_http proxy_fcgi setenvif
        rm /etc/apache2/ports.conf
cat << EOF > /etc/apache2/ports.conf
Listen 8089

<IfModule ssl_module>
        Listen 8443
</IfModule>

<IfModule mod_gnutls.c>
        Listen 8443
</IfModule>
EOF
        a2dissite 000-default
        systemctl restart apache2
        read -n 1 -s -r -p "$ANYKEY_CONTINUE"
      else
        echo "$CANCELL"
        read -n 1 -s -r -p "$ANYKEY_CONTINUE"
        break
      fi
      else
      echo " "
      fi
  if ! command -v php8.1 &> /dev/null; then
      clear
      echo "$NON_PHP"
      tput cup $(tput lines) 0
      read -p "$LIKE_INSTALL" -n 1 apply_changes
      if [[ $apply_changes == "1" ]]; then
        apt install lsb-release ca-certificates apt-transport-https software-properties-common gnupg2 curl
        echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/sury-php.list
        curl -fsSL https://packages.sury.org/php/apt.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/sury-keyring.gpg
        apt update
        apt install php8.1 php8.1-cgi php8.1-cli php8.1-fpm libapache2-mod-php8.1 php8.1-curl php8.1-dom php8.1-imagick php8.1-mbstring php8.1-zip php8.1-gd php8.1-intl php8.1-mysql php8.1-common
        a2enconf php8.1-fpm
        systemctl restart apache2 php8.1-fpm
        read -n 1 -s -r -p "$ANYKEY_CONTINUE"
      else
        echo "$CANCELL"
        read -n 1 -s -r -p "$ANYKEY_CONTINUE"
        break
      fi
      else
      echo " "
      fi
  if ! command -v certbot &> /dev/null; then
      clear
      echo "$NON_CERTBOT"
      tput cup $(tput lines) 0
      read -p "$LIKE_INSTALL" -n 1 apply_changes
      if [[ $apply_changes == "1" ]]; then
        apt install certbot
        read -n 1 -s -r -p "$ANYKEY_CONTINUE"
      else
        echo "$CANCELL"
        read -n 1 -s -r -p "$ANYKEY_CONTINUE"
        break
      fi
      else
      echo " "
      fi
    clear
    cols=$(tput cols)
    line=$(printf "%${cols}s" | tr ' ' '=')
    width=$(tput cols)
    echoc "   ___                      _        ___   ___ " $width
    echoc "  / __\___  _ __  ___  ___ | | ___  / __\ / _ |" $width
    echoc " / /  / _ \| '_ \/ __|/ _ \| |/ _ \/ /   / /_)/" $width
    echoc "/ /__| (_) | | | \__ \ (_) | |  __/ /___/ ___/ " $width
    echoc "\____/\___/|_| |_|___/\___/|_|\___\____/\/     " $width
    echo ""
#    echo $line
#    echo ""
#    echo "$WEB_MANAGE_NOTE" написать про скрипт по проверке сертификатов letsencrypt 
#    echo ""
    echo $line
    echo ""
    echoc "$SELECT_ACTION" $width
    echo ""
    echo $line
    echo ""
    echo "              1. $WEB_MANAGE_MENU1"
    echo "              2. $WEB_MANAGE_MENU2"
    echo "              3. $WEB_MANAGE_MENU3"
    echo ""
    echo "              4. $WEB_MANAGE_MENU4"
    echo "              5. $WEB_MANAGE_MENU5"
    echo ""
    echo "              6. $WEB_MANAGE_MENU6"
    echo "              7. $WEB_MANAGE_MENU7"
    echo "              8. $WEB_MANAGE_MENU8"
    echo "              9. $WEB_MANAGE_MENU9"
    echo "              0. $BACK"
    echo ""
    echo $line
    echo ""
    WEB_SITE_LISTS=$(ls -1 /etc/nginx/sites-enabled/)
    echo "$WEB_SITE_LIST"
    echo $WEB_SITE_LISTS
  tput cup $(tput lines) 0
  read -p "$ENTER_NUMBER" choice
  case $choice in
  1)
#  clear
#  tput cup $(tput lines) 0
#  read -p "$ENTER_DOMAIN " domain
#  ask_question "$LIKE_SSL " question_1
#if [[ "$question_1" == "1" ]]; then
    # Задаем второй вопрос только если пользователь ответил положительно на первый
#    ask_question "$LIKE_LTSENCRYPT " question_2

#    if [[ "$question_2" == "1" ]]; then
        # Задаем третий вопрос только если пользователь ответил положительно на второй
#        ask_question "$ENTER_SSL_PATH " question_3
#echo " "
        # Задаем четвертый вопрос только если пользователь ответил положительно на второй
#        ask_question "$ENTER_SSL_KEY_PATH " question_4
#    fi
#fi
  web_site_create #$domain $question_1 $question_2 $question_3 $question_4
  ;;
  2)
  clear
  tput cup $(tput lines) 0
  read -p "$ENTER_DOMAIN " domain
  read -p "$LIKE_WEB_DIR_DELETE " -n 1 apply_changes
  web_site_delete $domain $apply_changes
  ;;
  3)
  clear
  tput cup $(tput lines) 0
  read -p "$ENTER_DOMAIN " domain
  source /opt/ccp/web_templates/cms/wp_install.sh
  ;;
  4)
  clear
  tput cup $(tput lines) 0
  read -p "$ENTER_DOMAIN " domain
  web_site_enable $domain
  ;;
  5)
  clear
  tput cup $(tput lines) 0
  read -p "$ENTER_DOMAIN " domain
  web_site_disable $domain
  ;;
  6)
  clear
  systemctl restart nginx apache2 mysql php*
  read -n 1 -s -r -p "$ANYKEY_CONTINUE"
  ;;
  7)
  clear
  tput cup $(tput lines) 0
  read -p "$ENTER_DOMAIN " domain
  certbot --nginx -d $domain
  read -n 1 -s -r -p "$ANYKEY_CONTINUE"
  ;;
  8)
  php_manage
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

web_site_create () {
clear
tput cup $(tput lines) 0
read -p "$ENTER_DOMAIN " domain
# Определите путь к папке со скриптами
scripts_dir="/opt/ccp/web_templates/web_config"

# Получите список скриптов в папке
scripts=( "$scripts_dir"/*.sh )

# Переберите каждый скрипт в папке
for (( i=0; i<${#scripts[@]}; i++ )); do
  script="${scripts[$i]}"
  
  # Выведите информацию о скрипте с использованием ключа description
  echo "[$i] $($script description)"
done

# Запросите у пользователя выбрать скрипт с помощью числа
  read -p "$ENTER_NUMBER" selection

# Проверьте, что введенное значение является числом и находится в диапазоне допустимых значений
if [[ $selection =~ ^[0-9]+$ && $selection -ge 0 && $selection -lt ${#scripts[@]} ]]; then
  selected_script="${scripts[$selection]}"
  
  # Запустите выбранный скрипт
  source $selected_script create_site
else
  echo "$FAIL_CHOISE"
fi

clear
#read -p "$LIKE_WP " -n 1 apply_changes
#    if [[ $apply_changes == "1" ]]; then
#    source /opt/ccp/web_templates/cms/wp_ibstall.sh
# Определите путь к папке со скриптами
#scripts_dir="/opt/ccp/web_templates/cms"
#
## Получите список скриптов в папке
#scripts=( "$scripts_dir"/*.sh )
#
## Переберите каждый скрипт в папке
#for (( i=0; i<${#scripts[@]}; i++ )); do
#  script="${scripts[$i]}"
#  
#  # Выведите информацию о скрипте с использованием ключа description
#  echo "[$i] $($script description)"
#done
#
## Запросите у пользователя выбрать скрипт с помощью числа
#  read -p "$ENTER_NUMBER" selection
#fi
## Проверьте, что введенное значение является числом и находится в диапазоне допустимых значений
#if [[ $selection =~ ^[0-9]+$ && $selection -ge 0 && $selection -lt ${#scripts[@]} ]]; then
#  selected_script="${scripts[$selection]}"
#  
#  # Запустите выбранный скрипт
#  source $selected_script 
#else
#  echo " "
#fi
}

web_templates_manage () {
  while true; do
    clear
    cols=$(tput cols)
    line=$(printf "%${cols}s" | tr ' ' '=')
    width=$(tput cols)
    echoc "   ___                      _        ___   ___ " $width
    echoc "  / __\___  _ __  ___  ___ | | ___  / __\ / _ |" $width
    echoc " / /  / _ \| '_ \/ __|/ _ \| |/ _ \/ /   / /_)/" $width
    echoc "/ /__| (_) | | | \__ \ (_) | |  __/ /___/ ___/ " $width
    echoc "\____/\___/|_| |_|___/\___/|_|\___\____/\/     " $width
    echo ""
    echo $line
    echo ""
    echoc "$SELECT_ACTION" $width
    echo ""
    echo $line
    echo ""
    echo "              1. $WEB_TEMLATES_MENU1"
    echo "              2. $WEB_TEMLATES_MENU2"
    echo "              0. $BACK"
    echo ""
    echo $line
    echo ""
    echo "$WEB_CONFIG_TEMLATES_LIST"
    # Определите путь к папке со скриптами
scripts_dir="/opt/ccp/web_templates/web_config"

# Получите список скриптов в папке
scripts=( "$scripts_dir"/*.sh )

# Переберите каждый скрипт в папке
for (( i=0; i<${#scripts[@]}; i++ )); do
  script="${scripts[$i]}"
  
  # Выведите информацию о скрипте с использованием ключа description
  echo "[$i] $($script description)"
done
echo $line
echo "$CMS_TEMLATES_LIST"
echo "Wordpress"
#scripts_dir="/opt/ccp/web_templates/cms"

# Получите список скриптов в папке
#scripts=( "$scripts_dir"/*.sh )

# Переберите каждый скрипт в папке
#for (( i=0; i<${#scripts[@]}; i++ )); do
#  script="${scripts[$i]}"
  
  # Выведите информацию о скрипте с использованием ключа description
#  echo "[$i] $($script description)"
#done
  tput cup $(tput lines) 0
  read -p "$ENTER_NUMBER" choice
  case $choice in
  1)
  clear
  tput cup $(tput lines) 0
  read -p "$ENTER_URL " template_url
  wget -P /opt/ccp/web_templates/web_config $template_url
  ;;
  2)
  clear
  tput cup $(tput lines) 0
  read -p "$ENTER_URL " template_url
  wget -P /opt/ccp/web_templates/cms $template_url
  ;;
  0)
  break
  ;;
  *)
  echo "$FAIL_CHOISE"
  read -n 1 -s -r -p "$ANYKEY_CONTINUE"
  esac
done
}

web_site_create_old () {
  domain=$1
  enable_ssl=$2
  letsencrypt_enable=$3
  ssl_path=$4
  ssl_key_path=$5
  mkdir /var/www/html/$domain
cat << EOF > /var/www/html/$domain/index.html
<html>
Domain: $domain <br>
This host used <a href="https://github.com/NagibatorIgor/ccp" target="_blank">Console Control Panel</a> <br>
<br><br>
<a href="http://$domain/phpinfo.php" target="_blank">PHP Info</a>
</html>
EOF
cat << EOF > /var/www/html/$domain/phpinfo.php
<?php
phpinfo();
?>
EOF
  chown -R www-data:www-data /var/www/html/$domain
  chmod -R 755 /var/www/html/$domain
if [[ "$enable_ssl" -eq 0 && "$letsencrypt_enable" -eq 0 ]]; then
cat << EOF > /etc/apache2/sites-available/$domain.conf
<VirtualHost localhost:8089>

    ServerName $domain
    ServerAdmin admin@$domain
    DocumentRoot /var/www/html/$domain
    ScriptAlias /cgi-bin/ /var/www/cgi-bin/$domain
    #CustomLog /var/log/apache2/domains/$domain.bytes bytes
    CustomLog /var/log/apache2/domains/$domain.log combined
    ErrorLog /var/log/apache2/domains/$domain.error.log

    <Directory /var/www/html/$domain/>
        AllowOverride All
        Options +Includes -Indexes +ExecCGI
    </Directory>

    <FilesMatch \.php$>
        SetHandler "proxy:unix:/run/php/php8.1-fpm-$domain.sock|fcgi://localhost"
    </FilesMatch>
    SetEnvIf Authorization .+ HTTP_AUTHORIZATION=\$0
</VirtualHost>
EOF
cat << EOF > /etc/nginx/sites-available/$domain.conf
server {
        listen      80;
        server_name $domain;
        error_log   /var/log/apache2/domains/$domain.error.log error;

        location ~ /\.(?!well-known\/|file) {
                deny all;
                return 404;
        }

        location / {
                proxy_pass http://localhost:8089;

                location ~* ^.+\.(css|htm|html|js|json|xml|apng|avif|bmp|cur|gif|ico|jfif|jpg|jpeg|pjp|pjpeg|png|svg|tif|tiff|webp|aac|caf|flac|m4a|midi|mp3|ogg|opus|wav|3gp|av1|avi|m4v|mkv|mov|mpg|mpeg|mp4|mp4v|webm|otf|ttf|woff|woff2|doc|docx|odf|odp|ods|odt|pdf|ppt|pptx|rtf|txt|xls|xlsx|7z|bz2|gz|rar|tar|tgz|zip|apk|appx|bin|dmg|exe|img|iso|jar|msi)$ {
                        try_files  \$uri @fallback;

                        root       /var/www/html/$domain;
                        access_log /var/log/apache2/domains/$domain.log combined;
                        #access_log /var/log/apache2/domains/$domain.bytes bytes;

                        expires    max;
                }
        }

        location @fallback {
                proxy_pass http://localhost:8089;
        }
}
EOF
ln -s /etc/nginx/sites-available/$domain.conf /etc/nginx/sites-enabled/
a2ensite $domain.conf
echo "listen = /run/php/php8.1-fpm-$domain.sock" >> /etc/php/8.1/fpm/php-fpm.conf
touch /run/php/php8.1-fpm-$domain.sock
chown -R www-data:www-data /run/php/php8.1-fpm-$domain.sock
chmod -R 755 /run/php/php8.1-fpm-$domain.sock
systemctl restart nginx apache2 php*
echo $WEB_SITE_CREATED
read -n 1 -s -r -p "$ANYKEY_CONTINUE"
    elif [[ "$enable_ssl" -eq 1 && "$letsencrypt_enable" -eq 0 ]]; then
    read -p "$ENTER_SSL_PATH " ssl_path
    read -p "$ENTER_SSL_KEY_PATH " ssl_key_path
cat << EOF > /etc/apache2/sites-available/$domain.conf
<VirtualHost localhost:8443>

    ServerName $domain

    ServerName $domain
    ServerAdmin admin@$domain
    DocumentRoot /var/www/html/$domain
    ScriptAlias /cgi-bin/ /var/www/cgi-bin/$domain
    #CustomLog /var/log/apache2/domains/$domain.bytes bytes
    CustomLog /var/log/apache2/domains/$domain.log combined
    ErrorLog /var/log/apache2/domains/$domain.error.log
    <Directory /var/www/html/$domain>
        AllowOverride All
        SSLRequireSSL
        Options +Includes -Indexes +ExecCGI
        </Directory>
    SSLEngine on
    SSLVerifyClient none
    SSLCertificateFile $ssl_path
    SSLCertificateKeyFile $ssl_key_path

    <FilesMatch \.php$>
        SetHandler "proxy:unix:/run/php/php8.1-fpm-$domain.sock|fcgi://localhost"
    </FilesMatch>
    SetEnvIf Authorization .+ HTTP_AUTHORIZATION=\$0
</VirtualHost>
EOF
cat << EOF > /etc/nginx/sites-available/$domain.conf
server {
        listen      80;
        server_name $domain;
        error_log   /var/log/apache2/domains/$domain.error.log error;

        return 301 https://\$host\$request_uri;
        }
server {
        listen      443 ssl;
        server_name $domain;
        error_log   /var/log/apache2/domains/$domain.error.log error;

        ssl_certificate     $ssl_path;
        ssl_certificate_key $ssl_key_path;
        ssl_stapling        on;
        ssl_stapling_verify on;

        # TLS 1.3 0-RTT anti-replay
        #if (\$anti_replay = 307) { return 307 https://\$host\$request_uri; }
        #if (\$anti_replay = 425) { return 425; }

        add_header Strict-Transport-Security "max-age=31536000;" always;

        location ~ /\.(?!well-known\/|file) {
                deny all;
                return 404;
        }
        
        location / {
                proxy_pass https://localhost:8443;

                location ~* ^.+\.(css|htm|html|js|json|xml|apng|avif|bmp|cur|gif|ico|jfif|jpg|jpeg|pjp|pjpeg|png|svg|tif|tiff|webp|aac|caf|flac|m4a|midi|mp3|ogg|opus|wav|3gp|av1|avi|m4v|mkv|mov|mpg|mpeg|mp4|mp4v|webm|otf|ttf|woff|woff2|doc|docx|odf|odp|ods|odt|pdf|ppt|pptx|rtf|txt|xls|xlsx|7z|bz2|gz|rar|tar|tgz|zip|apk|appx|bin|dmg|exe|img|iso|jar|msi)$ {
                        try_files  \$uri @fallback;

                        root       /var/www/html/$domain;
                        access_log /var/log/apache2/domains/$domain.log combined;
                        #access_log /var/log/apache2/domains/$domain.bytes bytes;

                        expires    max;
                }
        }

        location @fallback {
                proxy_pass https://localhost:8443;
        }

        proxy_hide_header Upgrade;
}
EOF
ln -s /etc/nginx/sites-available/$domain.conf /etc/nginx/sites-enabled/
a2ensite $domain.conf
echo "listen = /run/php/php8.1-fpm-$domain.sock" >> /etc/php/8.1/fpm/php-fpm.conf
touch /run/php/php8.1-fpm-$domain.sock
chown -R www-data:www-data /run/php/php8.1-fpm-$domain.sock
chmod -R 755 /run/php/php8.1-fpm-$domain.sock
systemctl restart nginx apache2 php*
echo $WEB_SITE_CREATED
read -n 1 -s -r -p "$ANYKEY_CONTINUE"
    elif [[ "$enable_ssl" -eq 1 && "$letsencrypt_enable" -eq 1 ]]; then
cat << EOF > /etc/apache2/sites-available/$domain.conf
<VirtualHost localhost:8443>

    ServerName $domain

    ServerName $domain
    ServerAdmin admin@$domain
    DocumentRoot /var/www/html/$domain
    ScriptAlias /cgi-bin/ /var/www/cgi-bin/$domain
    #CustomLog /var/log/apache2/domains/$domain.bytes bytes
    CustomLog /var/log/apache2/domains/$domain.log combined
    ErrorLog /var/log/apache2/domains/$domain.error.log
    <Directory /var/www/html/$domain>
        AllowOverride All
        SSLRequireSSL
        Options +Includes -Indexes +ExecCGI
        </Directory>
    SSLEngine on
    SSLVerifyClient none
    SSLCertificateFile /etc/letsencrypt/live/$domain/fullchain.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/$domain/privkey.pem

    <FilesMatch \.php$>
        SetHandler "proxy:unix:/run/php/php8.1-fpm-$domain.sock|fcgi://localhost"
    </FilesMatch>
    SetEnvIf Authorization .+ HTTP_AUTHORIZATION=\$0
</VirtualHost>
EOF
cat << EOF > /etc/nginx/sites-available/$domain.conf
server {
        listen      80;
        server_name $domain;
        error_log   /var/log/apache2/domains/$domain.error.log error;

        return 301 https://\$host\$request_uri;
        }
server {
        listen      443 ssl;
        server_name $domain;
        error_log   /var/log/apache2/domains/$domain.error.log error;

        ssl_certificate     /etc/letsencrypt/live/$domain/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/$domain/privkey.pem;
        ssl_stapling        on;
        ssl_stapling_verify on;

        # TLS 1.3 0-RTT anti-replay
        #if (\$anti_replay = 307) { return 307 https://\$host\$request_uri; }
        #if (\$anti_replay = 425) { return 425; }

        add_header Strict-Transport-Security "max-age=31536000;" always;

        location ~ /\.(?!well-known\/|file) {
                deny all;
                return 404;
        }
        
        location / {
                proxy_pass https://localhost:8443;

                location ~* ^.+\.(css|htm|html|js|json|xml|apng|avif|bmp|cur|gif|ico|jfif|jpg|jpeg|pjp|pjpeg|png|svg|tif|tiff|webp|aac|caf|flac|m4a|midi|mp3|ogg|opus|wav|3gp|av1|avi|m4v|mkv|mov|mpg|mpeg|mp4|mp4v|webm|otf|ttf|woff|woff2|doc|docx|odf|odp|ods|odt|pdf|ppt|pptx|rtf|txt|xls|xlsx|7z|bz2|gz|rar|tar|tgz|zip|apk|appx|bin|dmg|exe|img|iso|jar|msi)$ {
                        try_files  \$uri @fallback;

                        root       /var/www/html/$domain;
                        access_log /var/log/apache2/domains/$domain.log combined;
                        #access_log /var/log/apache2/domains/$domain.bytes bytes;

                        expires    max;
                }
        }

        location @fallback {
                proxy_pass https://localhost:8443;
        }

        proxy_hide_header Upgrade;
}
EOF
ln -s /etc/nginx/sites-available/$domain.conf /etc/nginx/sites-enabled/
a2ensite $domain.conf
certbot certonly --nginx -d $domain
echo "listen = /run/php/php8.1-fpm-$domain.sock" >> /etc/php/8.1/fpm/php-fpm.conf
touch /run/php/php8.1-fpm-$domain.sock
chown -R www-data:www-data /run/php/php8.1-fpm-$domain.sock
chmod -R 755 /run/php/php8.1-fpm-$domain.sock
read -p "$LIKE_WP " -n 1 apply_changes
    if [[ $apply_changes == "1" ]]; then
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
    else
    echo " "
    fi
systemctl restart nginx apache2 php*
echo $WEB_SITE_CREATED
read -n 1 -s -r -p "$ANYKEY_CONTINUE"
    else
        tput cup $(tput lines) 0
        echo "$FAIL_CHOISE"
        read -n 1 -s -r -p "$ANYKEY_CONTINUE"
    fi

}

web_site_delete () {
  domain=$1
  dir_delete=$2
  if [[ $dir_delete == "1" ]]; then
        rm /etc/apache2/sites-enabled/$domain.conf
        rm /etc/apache2/sites-available/$domain.conf
        rm /etc/nginx/sites-enabled/$domain.conf
        rm /etc/nginx/sites-available/$domain.conf
        cat "/etc/php/8.1/fpm/php-fpm.conf" | grep -v "listen = /run/php/php8.1-fpm-$domain.sock"
        rm /run/php/php8.1-fpm-$domain.sock
        systemctl restart nginx apache2 php*
        rm -rf /var/log/apache2/domains/$domain*
        rm -rf /var/www/html/$domain
        echo $WEB_SITE_DELETED
        read -n 1 -s -r -p "$ANYKEY_CONTINUE"
      else
        rm /etc/apache2/sites-enabled/$domain.conf
        rm /etc/apache2/sites-available/$domain.conf
        rm /etc/nginx/sites-enabled/$domain.conf
        rm /etc/nginx/sites-available/$domain.conf
        cat "/etc/php/8.1/fpm/php-fpm.conf" | grep -v "listen = /run/php/php8.1-fpm-$domain.sock"
        rm /run/php/php8.1-fpm-$domain.sock
        systemctl restart nginx apache2 php*
        rm -rf /var/log/apache2/domains/$domain*
        echo $WEB_SITE_DELETED
        read -n 1 -s -r -p "$ANYKEY_CONTINUE"
      fi
}

web_site_enable () {
  domain=$1
  a2ensite $domain.conf
  ln -s /etc/nginx/sites-available/$domain.conf /etc/nginx/sites-enabled/
  systemctl restart nginx apache2
echo $WEB_SITE_ENABLED
read -n 1 -s -r -p "$ANYKEY_CONTINUE"
}

web_site_disable () {
  domain=$1
  a2dissite $domain.conf
  rm /etc/nginx/sites-enabled/$domain.conf
  systemctl restart nginx apache2
  echo $WEB_SITE_DISABLED
  read -n 1 -s -r -p "$ANYKEY_CONTINUE"
}

php_manage () {
  while true; do
  clear
  cols=$(tput cols)
line=$(printf "%${cols}s" | tr ' ' '=')
    width=$(tput cols)
    clear
    echoc "   ___                      _        ___   ___ " $width
    echoc "  / __\___  _ __  ___  ___ | | ___  / __\ / _ |" $width
    echoc " / /  / _ \| '_ \/ __|/ _ \| |/ _ \/ /   / /_)/" $width
    echoc "/ /__| (_) | | | \__ \ (_) | |  __/ /___/ ___/ " $width
    echoc "\____/\___/|_| |_|___/\___/|_|\___\____/\/     " $width
    echo ""
    echo $line
    echo ""
    echoc "$SELECT_ACTION" $width
    echo ""
    echo $line
    echo ""
    echo "              1. $PHP_MANAGE_MENU1"
    echo "              2. $PHP_MANAGE_MENU2"
    echo "              3. $PHP_MANAGE_MENU3"
    echo "              4. $PHP_MANAGE_MENU4"
    echo "              5. $PHP_MANAGE_MENU5"
    echo "              0. $BACK"
    echo $line
    echo ""
    echo "$INSTALLED_PHP"
    ls -1 /etc/php/
    tput cup $(tput lines) 0
    read -p "$ENTER_NUMBER" choice

    case $choice in
        1)
            clear
            read -p "$ENTER_PHP_VERSION " version
            install_php_version $version
            ;;
        2)
            clear
            read -p "$ENTER_PHP_VERSION " version
            delete_php_version $version
            ;;
        3)
            clear
            wget -P /root https://gist.githubusercontent.com/rangerz/271504c282ea254779ddb730605fd662/raw/28193a7d1595939c0d10ad1822fa4b95d0e915b0/install_ioncube.sh
            /root/install_ioncube.sh
            read -n 1 -s -r -p "$ANYKEY_CONTINUE"
            ;;
        4)
            clear
            read -p "$ENTER_PHP_VERSION " version
            read -p "$ENTER_PHP_PLUGIN " plugin
            install_php_plugin $version $plugin
            ;;
        5)
            clear
            read -p "$ENTER_DOMAIN " domain
            read -p "$ENTER_OLD_PHP_VERSION " old_php_version
            read -p "$ENTER_PHP_VERSION " php_version
            change_web_site_php $domain $php_version $old_php_version
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

install_php_version () {
  version=$1
  apt install php$version php$version-cgi php$version-fpm php$version-cli
  read -n 1 -s -r -p "$ANYKEY_CONTINUE"
}

delete_php_version () {
  version=$1
  apt remove php$version php$version-*
  read -n 1 -s -r -p "$ANYKEY_CONTINUE"
}

install_php_plugin () {
  version=$1
  plugin=$2
  apt install php$version-$plugin
  read -n 1 -s -r -p "$ANYKEY_CONTINUE"
}

change_web_site_php () {
    domain=$1
    php_version=$2
    old_php_version=$3

    # Изменение конфигурационного файла для Apache
    local apache_config_file="/etc/apache2/sites-available/$domain.conf"
    if [ -f "$apache_config_file" ]; then
        sed -i "s/php${old_php_version}/php${php_version}/g" "$apache_config_file"
        cat "/etc/php/$old_php_version/fpm/php-fpm.conf" | grep -v "listen = /run/php/php$old_php_version-fpm-$domain.sock"
        rm /run/php/php$old_php_version-fpm-$domain.sock
        echo "listen = /run/php/php$php_version-fpm-$domain.sock" >> /etc/php/$php_version/fpm/php-fpm.conf
        touch /run/php/php$php_version-fpm-$domain.sock
        chown -R www-data:www-data /run/php/php$php_version-fpm-$domain.sock
        chmod -R 755 /run/php/php$php_version-fpm-$domain.sock
        systemctl restart apache2 php$php_version-fpm
        echo "$CHANGE_SUCCSESS"
    else
        echo "$MISSING_DOMAIN"
        read -n 1 -s -r -p "$ANYKEY_CONTINUE"
    fi
    # Изменение конфигурационного файла для Nginx
    #local nginx_config_file="/etc/nginx/sites-available/$domain"
    #if [ -f "$nginx_config_file" ]; then
    #    sed -i "s/fastcgi_pass unix:/run/php/php[0-9.]+/fastcgi_pass unix:/run/php/php${php_version}-fpm.sock/g" "$nginx_config_file"
    #    echo "$CHANGE_SUCCSESS"
    #    read -n 1 -s -r -p "$ANYKEY_CONTINUE"
    #else
    #    echo "$MISSING_DOMAIN"
    #    read -n 1 -s -r -p "$ANYKEY_CONTINUE"
    #fi
}

log_menu () {
  while true; do
  clear
  cols=$(tput cols)
line=$(printf "%${cols}s" | tr ' ' '=')
    width=$(tput cols)
    clear
    echoc "   ___                      _        ___   ___ " $width
    echoc "  / __\___  _ __  ___  ___ | | ___  / __\ / _ |" $width
    echoc " / /  / _ \| '_ \/ __|/ _ \| |/ _ \/ /   / /_)/" $width
    echoc "/ /__| (_) | | | \__ \ (_) | |  __/ /___/ ___/ " $width
    echoc "\____/\___/|_| |_|___/\___/|_|\___\____/\/     " $width
    echo ""
    echo $line
    echo ""
    echoc "$SELECT_ACTION" $width
    echo ""
    echo $line
    echo ""
    echo "              1. $LOG_MENU1"
    echo "              2. $LOG_MENU2"
    echo "              3. $LOG_MENU3"
    echo "              4. $LOG_MENU4"
    echo "              5. $LOG_MENU5"
    echo "              0. $BACK"
    tput cup $(tput lines) 0
    read -p "$ENTER_NUMBER" choice

    case $choice in
    1)
    clear
    systemctl status nginx apache2 mysql php*
    read -n 1 -s -r -p "$ANYKEY_CONTINUE"
    ;;
    2)
    clear
    read -p "$ENTER_DOMAIN " domain
    cat /var/log/apache2/domains/$domain.error.log
    read -n 1 -s -r -p "$ANYKEY_CONTINUE"
    ;;
    3)
    clear
    read -p "$ENTER_DOMAIN " domain
    cat /var/log/apache2/domains/$domain.log
    read -n 1 -s -r -p "$ANYKEY_CONTINUE"
    ;;
    4)
    clear
    tput cup $(tput lines) 0
    read -p "$ENTER_PHP_VERSION " version
    cat /var/log/php$version-fpm.log
    read -n 1 -s -r -p "$ANYKEY_CONTINUE"
    ;;
    5)
    clear
    cat /root/.bash_history
    read -n 1 -s -r -p "$ANYKEY_CONTINUE"
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

config_host () {
while true; do
clear
config_file="/etc/ssh/sshd_config"
permit_root_login=$(grep -E '^PermitRootLogin' "$config_file")
if [[ $permit_root_login =~ "yes" ]]; then
    root_login_status="[ON]"
elif [[ $permit_root_login =~ "no" ]] || [[ $permit_root_login =~ ^# ]]; then
    root_login_status="[OFF]"
else
    root_login_status="[?]"
fi
  cols=$(tput cols)
  line=$(printf "%${cols}s" | tr ' ' '=')
    width=$(tput cols)
    clear
    echoc "   ___                      _        ___   ___ " $width
    echoc "  / __\___  _ __  ___  ___ | | ___  / __\ / _ |" $width
    echoc " / /  / _ \| '_ \/ __|/ _ \| |/ _ \/ /   / /_)/" $width
    echoc "/ /__| (_) | | | \__ \ (_) | |  __/ /___/ ___/ " $width
    echoc "\____/\___/|_| |_|___/\___/|_|\___\____/\/     " $width
    echo ""
    echo $line
    echo ""
    echoc "$SELECT_ACTION" $width
    echo ""
    echo $line
    echo ""
    echo "              1. $root_login_status $CONFIG_HOST_MENU1"
    echo "              2. $CONFIG_HOST_MENU2"
    echo "              3. $CONFIG_HOST_MENU3"
    echo "              0. $BACK"
    tput cup $(tput lines) 0
    read -p "$ENTER_NUMBER" choice

    case $choice in
    1)
    clear
    config_file="/etc/ssh/sshd_config"
    new_value="yes"
    permit_root_login=$(grep -E '^PermitRootLogin' "$config_file")
    if [[ $permit_root_login =~ ^# ]]; then
        echo "PermitRootLogin $new_value" | sudo tee -a "$config_file" >/dev/null
    else
        sed -i "s/^PermitRootLogin.*/PermitRootLogin $new_value/" "$config_file"
    fi
    echo "$LIKE_REBOOT_SSH"
                read -p "$APPLY_CHANGE" -n 1 apply_changes
                if [[ $apply_changes == "1" ]]; then
                    echo "$APPLYING"
                    systemctl restart ssh
                    echo "$CHANGE_SUCCSESS"
                    read -n 1 -s -r -p "$ANYKEY_CONTINUE"
                else
                    echo "$CHANGE_FAILED"
                    read -n 1 -s -r -p "$ANYKEY_CONTINUE"
                fi
    ;;
    2)
    clear
    echo 'termcapinfo xterm ti@:te@' >> ~/.screenrc
    echo $CHANGE_SUCCSESS
    read -n 1 -s -r -p "$ANYKEY_CONTINUE"
    ;;
    3)
    clear
    passwd
    read -n 1 -s -r -p "$ANYKEY_CONTINUE"
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
# Определение количества символов в строке терминала
cols=$(tput cols)

# Создание строки, состоящей из символов "="
line=$(printf "%${cols}s" | tr ' ' '=')
    width=$(tput cols)
    clear
    echoc "   ___                      _        ___   ___ " $width
    echoc "  / __\___  _ __  ___  ___ | | ___  / __\ / _ |" $width
    echoc " / /  / _ \| '_ \/ __|/ _ \| |/ _ \/ /   / /_)/" $width
    echoc "/ /__| (_) | | | \__ \ (_) | |  __/ /___/ ___/ " $width
    echoc "\____/\___/|_| |_|___/\___/|_|\___\____/\/     " $width
    echo ""
    echo $line
    echo ""
    echo "$MAIN_MENU_NOTE"
    echo ""
    echo $line
    echo ""
    echoc "$MAIN_MENU" $width
    echo ""
    echo $line
    echo ""
    echo "              1. $MAIN_MENU1"
    echo "              2. $MAIN_MENU2"
    echo "              3. $MAIN_MENU3"
    echo ""
    echo "              4. $MAIN_MENU4"
    echo "              5. $MAIN_MENU5"
#    echo "              5. $MAIN_MENU5"
    echo "              6. $MAIN_MENU6"
    echo "              7. $MAIN_MENU7"
    echo "              8. $MAIN_MENU8"
    echo ""
    echo "              9. $MAIN_MENU9"
    echo "              10. $MAIN_MENU10"
    echo "              11. $MAIN_MENU11"
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
            config_host
            ;;
        4)
            configure_network
            ;;
        5)
            manage_resources
            ;;
#        5)
#            email_manage
#            ;;
        6)
            mysql_manage
            ;;
        7)  
            vpn_manage
            ;;
        8)
            web_manage
            ;;
        9)  
            change_language
            ;;
        10)
            cp /opt/ccp/lang.config /tmp/lang.config
            mv /opt/ccp/update.sh /tmp/update.sh
            clear
            /tmp/update.sh
            exit 0
            ;;
        11)
            log_menu
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
