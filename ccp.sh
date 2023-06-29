#!/bin/bash
# Функция для перезагрузки хоста
reboot_host() {
    echo "$REBOOT"
    reboot
}

# Функция для выключения хоста
shutdown_host() {
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
        echo "$SELECT_ACTION"
        echo "1. $NETWORK_MENU1"
        echo "2. $NETWORK_MENU2"
        echo "3. $NETWORK_MENU3"
        echo "0. $EXIT"

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
                exit 0
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
    echo "$SELECT_ACTION"
    echo "1. $UFW_MENU1"
    echo "2. $UFW_MENU2"
    echo "3. $UFW_MENU3"
    echo "4. $UFW_MENU4"
    echo "0. $BACK"
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
  echo "$SELECT_ACTION"
  echo "1. $RESOURCE_MENU1"
  echo "2. $RESOURCE_MENU2"
  echo "3. $RESOURCE_MENU3"
  echo "0. $BACK"
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
      clear
      netstat -ltupan
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

change_language() {
    clear
    echo "$SELECT_LANG"
    echo "1. English"
    echo "2. Русский"

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

    echo $lang_code > "lang.config"  # Запись выбранного языка в файл
    echo "$SUCCESS"
    read -n 1 -s -r -p "$ANYKEY_CONTINUE"
}

load_language_resources() {
    local lang_file="./lang/ccp_en.sh"  # По умолчанию используется английский язык

    if [ -f "lang.config" ]; then
        lang_code=$(cat "lang.config")  # Чтение выбранного языка из файла
        case $lang_code in
            "en")
                lang_file="./lang/ccp_en.sh"
                ;;
            "ru")
                lang_file="./lang/ccp_ru.sh"
                ;;
        esac
    fi

    source "$lang_file"  # Загрузка языковых ресурсов
}

# Основное меню
while true; do

# Загрузка языковых ресурсов
load_language_resources

  if [[ $EUID -ne 0 ]]; then
  echo "$NON_ROOT" 
  exit 1
  fi
    clear
    echo "$MAIN_MENU"
    echo "1. $MAIN_MENU1"
    echo "2. $MAIN_MENU2"
    echo "3. $MAIN_MENU3"
    echo "4. $MAIN_MENU4"
    echo "5. $MAIN_MENU5"
    echo "0. $LEXIT"

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
            change_language
            ;;
        0)
            exit 0
            ;;
        *)
            echo "$FAIL_CHOISE"
            ;;
    esac
done