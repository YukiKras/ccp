#!/bin/bash
rm -rf /opt/ccp/*
wget -O /opt/ccp/ccp.zip https://github.com/NagibatorIgor/ccp/archive/main.zip
unzip /opt/ccp/ccp.zip -d /opt/ccp
mv /opt/ccp/ccp-main/* /opt/ccp
rm -rf /opt/ccp/ccp-main
rm /opt/ccp/ccp.zip
rm /opt/ccp/installcсp.sh

# Установка прав доступа
chmod -R 755 /opt/ccp

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

echo "The update has been completed successfully."