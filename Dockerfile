# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: gcefalo <marvin@42.fr>                     +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2021/02/08 18:13:25 by gcefalo           #+#    #+#              #
#    Updated: 2021/02/10 16:37:23 by gcefalo          ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

FROM	debian:buster

RUN		apt-get update

RUN		apt-get install -y \
		openssl \
		wget \
		nginx \
		mariadb-server \
		php7.3-fpm php7.3-mysql php7.3-cli php7.3-json php7.3-mbstring

RUN		mkdir ./var/www/ft_server
#RUN		touch /var/www/ft_server/index.php
#RUN		echo "<?php phpinfo(); ?>" >> /var/www/ft_server/index.php

#nginx
RUN		rm var/www/html/index.nginx-debian.html
COPY	/srcs/nginx.conf /etc/nginx/sites-available/nginx.conf
RUN		ln -s /etc/nginx/sites-available/nginx.conf /etc/nginx/sites-enabled/nginx.conf
RUN		rm -rf /etc/nginx/sites-enabled/default

#phpmyadmin
RUN		wget https://files.phpmyadmin.net/phpMyAdmin/5.0.2/phpMyAdmin-5.0.2-english.tar.gz && \
		tar -xzvf phpMyAdmin-5.0.2-english.tar.gz && \
		mv phpMyAdmin-5.0.2-english/ /var/www/ft_server/phpmyadmin && \
		rm -rf phpMyAdmin-5.0.2-english.tar.gz
COPY	srcs/config.inc.php /var/www/ft_server/phpmyadmin

#wordpress
RUN		wget https://wordpress.org/latest.tar.gz && \
		tar -xzvf latest.tar.gz && \
		mv wordpress /var/www/ft_server/ && \
		rm -rf latest.tar.gz
COPY	srcs/wp-config.php /var/www/ft_server/wordpress

#SLL
RUN		openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt -subj "/C=FR/ST=Ile de France/L=Paris/O=Ecole 42/OU=Ecole 42/CN=toto"

# Giving nginx's user-group rights over page files
RUN		chown -R www-data /var/www/*
RUN		chmod -R 755 /var/www/*

COPY	./srcs/init.sh ./

CMD		bash init.sh
