#!/bin/bash
rm -rf /opt/ccp/*
wget -O /opt/ccp/ccp.zip https://github.com/NagibatorIgor/ccp/archive/main.zip
unzip /opt/ccp/ccp.zip -d /opt/ccp
mv /opt/ccp/ccp-main/* /opt/ccp
rm -rf /opt/ccp/ccp-main
rm /opt/ccp/ccp.zip
rm /opt/ccp/installcсp.sh
rm -rf /opt/ccp/screenshots
rm -rf /opt/ccp/wiki
mv /tmp/lang.config /opt/ccp/lang.config

# Установка прав доступа
chmod -R 755 /opt/ccp

echo "The update has been completed successfully."