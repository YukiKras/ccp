#!/bin/bash

description () {
    echo "$HTTP_PHP_TEMPLATES_DESCRIPTION"
}

create_site () {
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
#cat << EOF > /etc/apache2/sites-available/$domain.conf
#<VirtualHost localhost:8089>
#
#    ServerName $domain
#    ServerAdmin admin@$domain
#    DocumentRoot /var/www/html/$domain
#    ScriptAlias /cgi-bin/ /var/www/cgi-bin/$domain
#    #CustomLog /var/log/apache2/domains/$domain.bytes bytes
#    CustomLog /var/log/apache2/domains/$domain.log combined
#    ErrorLog /var/log/apache2/domains/$domain.error.log
#
#    <Directory /var/www/html/$domain/>
#        AllowOverride All
#        Options +Includes -Indexes +ExecCGI
#    </Directory>
#
#    <FilesMatch \.php$>
#        SetHandler "proxy:unix:/run/php/php8.1-fpm-$domain.sock|fcgi://localhost"
#    </FilesMatch>
#    SetEnvIf Authorization .+ HTTP_AUTHORIZATION=\$0
#</VirtualHost>
#EOF
#cat << EOF > /etc/nginx/sites-available/$domain.conf
#server {
#        listen      80;
#        server_name $domain;
#        error_log   /var/log/apache2/domains/$domain.error.log error;
#
#        location ~ /\.(?!well-known\/|file) {
#                deny all;
#                return 404;
#        }
#
#        location / {
#                proxy_pass http://localhost:8089;
#                proxy_set_header Host \$host;
#                proxy_set_header X-Real-IP \$remote_addr;
#
#                location ~* ^.+\.(css|htm|html|js|json|xml|apng|avif|bmp|cur|gif|ico|jfif|jpg|jpeg|pjp|pjpeg|png|svg|tif|tiff|webp|aac|caf|flac|m4a|midi|mp3|ogg|opus|wav|3gp|av1|avi|m4v|mkv|mov|mpg|mpeg|mp4|mp4v|webm|otf|ttf|woff|woff2|doc|docx|odf|odp|ods|odt|pdf|ppt|pptx|rtf|txt|xls|xlsx|7z|bz2|gz|rar|tar|tgz|zip|apk|appx|bin|dmg|exe|img|iso|jar|msi)$ {
#                        try_files  \$uri @fallback;
#
#                        root       /var/www/html/$domain;
#                        access_log /var/log/apache2/domains/$domain.log combined;
#                        #access_log /var/log/apache2/domains/$domain.bytes bytes;
#
#                        expires    max;
#                }
#        }
#
#        location @fallback {
#                proxy_pass http://localhost:8089;
#                #proxy_set_header Host \$host;
#                #proxy_set_header X-Real-IP \$remote_addr;
#
#        }
#}
#EOF
cat << EOF > /etc/nginx/sites-available/$domain.conf
upstream php-handler {
    #server 127.0.0.1:9000;
    server unix:/var/run/php/php8.1-fpm.sock;
}

server {
        listen 80;
        ## Your website name goes here.
        server_name $domain;
        ## Your only path reference.
        root /var/www/html/$domain;

        location = /favicon.ico {
                log_not_found off;
                access_log off;
        }

        location = /robots.txt {
                allow all;
                log_not_found off;
                access_log off;
        }

        location ~ \.php$ {
                #NOTE: You should have "cgi.fix_pathinfo = 0;" in php.ini
                include fastcgi_params;
                fastcgi_intercept_errors on;
                fastcgi_pass unix:/run/php/php8.1-fpm-$domain.sock;
                #The following parameter can be also included in fastcgi_params file
                fastcgi_param  SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        }

        location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
                expires max;
                log_not_found off;
        }
}
EOF
ln -s /etc/nginx/sites-available/$domain.conf /etc/nginx/sites-enabled/
#a2ensite $domain.conf
echo "listen = /run/php/php8.1-fpm-$domain.sock" >> /etc/php/8.1/fpm/php-fpm.conf
touch /run/php/php8.1-fpm-$domain.sock
chown -R www-data:www-data /run/php/php8.1-fpm-$domain.sock
chmod -R 755 /run/php/php8.1-fpm-$domain.sock
echo $WEB_SITE_CREATED
read -n 1 -s -r -p "$ANYKEY_CONTINUE"
}

delete_site () {
read -p "$LIKE_WEB_DIR_DELETE " -n 1 apply_changes
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

if [[ $1 == "create_site" ]]; then
    create_site
elif [[ $1 == "delete_site" ]]; then
    delete_site
elif [[ $1 == "description" ]]; then
    description
else
    echo "$UNKNOW_ERROR"
fi