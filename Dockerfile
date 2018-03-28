FROM alpine:3.7

ENV PHP_VER="7.2.3"

RUN addgroup php && \
	adduser -H -D -G php php && \
	echo "php:`head /dev/urandom | tr -dc A-Za-z0-9 | head -c 24 | mkpasswd -m sha256`" | chpasswd

RUN apk add -U --virtual deps \
		gcc g++ make libxml2-dev \
		icu-dev && \
	cd ~ && \
	wget https://php.net/distributions/php-$PHP_VER.tar.bz2 && \
	tar xf php-$PHP_VER.tar.bz2 && \
	cd ~/php-$PHP_VER/ && \
	./configure --prefix=/opt/php \
		--enable-fpm --enable-intl \
		--with-fpm-user=php \
		--with-fpm-group=php \
		--with-config-file-path=/opt/php/etc/php.ini && \
	make -j$(nproc) && \
	make install && \
	apk del --purge deps && \
	apk add libstdc++ libxml2 icu-libs && \
	mv ~/php-$PHP_VER/php.ini-production /opt/php/etc/php.ini && \
	mv /opt/php/etc/php-fpm.conf.default /opt/php/etc/php-fpm.conf && \
	mv /opt/php/etc/php-fpm.d/www.conf.default /opt/php/etc/php-fpm.d/www.conf && \
	rm -rf ~/*
