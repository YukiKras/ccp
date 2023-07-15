#!/bin/bash
# Проверка дистрибутива Linux
if [[ "$(lsb_release -si)" != "Debian" && "$(lsb_release -si)" != "Ubuntu" ]]; then
    echo "So far, ConsoleCP supports only Debian and Ubuntu."
    exit 1
fi

# Проверка пользователя root
if [[ $EUID -ne 0 ]]; then
    echo "You need to run install with root permissions"
    exit 1
fi

apt install unzip

# Создание директории /opt/ccp
mkdir -p /opt/ccp

wget -O /opt/ccp/ccp.zip https://github.com/NagibatorIgor/ccp/archive/main.zip
unzip /opt/ccp/ccp.zip -d /opt/ccp
mv /opt/ccp/ccp-main/* /opt/ccp
rm -rf /opt/ccp/ccp-main
rm /opt/ccp/ccp.zip
rm /opt/ccp/installcсp.sh

# Установка прав доступа
chmod -R 755 /opt/ccp

# Обновление текущего окружения
echo 'export PATH="/opt/ccp:$PATH"' >> /etc/profile
cat >> ~/.bashrc << 'EOF'
alias ccp="/opt/ccp/ccp.sh"
EOF
# Обновляем текущую оболочку
source ~/.bashrc
source /etc/profile

# Запрос языка установки
echo "Select langluage:"
    echo "1. English"
    echo "2. Русский"

    tput cup $(tput lines) 0
    read -p "Select: " lang

    case $lang in
        1)
            lang_code="en"
            ;;
        2)
            lang_code="ru"
            ;;
        *)
            echo "Fail choise"
            return
            ;;
    esac

echo $lang_code > /opt/ccp/lang.config  # Запись выбранного языка в файл

echo "The installation has been completed successfully. Use ccp to bring up the control panel."