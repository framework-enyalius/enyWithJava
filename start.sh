#!/bin/sh

#Creditos totais para https://github.com/wichon/alpine-apache-php/blob/master/start.sh

# Enable commonly used apache modules
	
sed -i 's/#LoadModule\ rewrite_module/LoadModule\ rewrite_module/' /etc/apache2/httpd.conf
sed -i 's/#LoadModule\ deflate_module/LoadModule\ deflate_module/' /etc/apache2/httpd.conf
sed -i 's/#LoadModule\ expires_module/LoadModule\ expires_module/' /etc/apache2/httpd.conf

sed -i "s#^DocumentRoot \".*#DocumentRoot \"/app/$WEBAPP_ROOT\"#g" /etc/apache2/httpd.conf
sed -i "s#/var/www/localhost/htdocs#/app/$WEBAPP_ROOT#" /etc/apache2/httpd.conf
printf "\n<Directory \"/app/$WEBAPP_ROOT\">\n\tAllowOverride All\n</Directory>\n" >> /etc/apache2/httpd.conf

#configurando o xdebug
printf "\nzend_extension=/usr/lib/php7/modules/xdebug.so" >> /etc/php7/conf.d/00-xdebug.ini
printf "\nxdebug.coverage_enable=0 " >> /etc/php7/conf.d/00-xdebug.ini
printf "\nxdebug.remote_enable=1  " >> /etc/php7/conf.d/00-xdebug.ini    
printf "\nxdebug.remote_connect_back=1" >> /etc/php7/conf.d/00-xdebug.ini
printf "\nxdebug.remote_log=/app/z_data/xdebug.log" >> /etc/php7/conf.d/00-xdebug.ini
printf "\nxdebug.remote_autostart=true  " >> /etc/php7/conf.d/00-xdebug.ini

#habilitando o display error do php
sed -i "s#display_error=Off#display_error=On#" /etc/php7/php.ini

if [ -z "$WEBAPP_USER_ID" ]; then
    chown -R apache:apache /app
else
    # Override apache user under which apache runs its child processes with the one provided
    # Useful for running container in development mode enabling live code modification
    runApacheAsUser=webapp
    apacheConfigPath="/etc/apache2/httpd.conf"
    addgroup -g $WEBAPP_USER_ID $runApacheAsUser
    adduser -D -H -g "webapp user" -G $runApacheAsUser -u $WEBAPP_USER_ID $runApacheAsUser
    chown -R $WEBAPP_USER_ID:$WEBAPP_USER_ID /app    
    sed -i "s/User apache/User $runApacheAsUser/" $apacheConfigPath
    sed -i "s/Group apache/Group $runApacheAsUser/" $apacheConfigPath
fi

httpd -D FOREGROUND &
touch /var/log/apache2/error.log
tail -f /var/log/apache2/error.log 
