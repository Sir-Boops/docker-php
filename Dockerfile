FROM alpine:3.7

ENV PHP_VER="7.2.3"
ENV IMG_VER="3.4.3"

RUN addgroup php && \
	adduser -H -D -G php php && \
	echo "php:`head /dev/urandom | tr -dc A-Za-z0-9 | head -c 24 | mkpasswd -m sha256`" | chpasswd

RUN apk add -U --virtual deps \
		gcc g++ make libxml2-dev \
		gd-dev libpng-dev freetype-dev \
		libjpeg-turbo-dev libwebp-dev \
		automake autoconf imagemagick-dev \
		icu-dev libressl-dev openldap-dev && \
	cd ~ && \
	wget https://php.net/distributions/php-$PHP_VER.tar.bz2 && \
	tar xf php-$PHP_VER.tar.bz2 && \
	cd ~/php-$PHP_VER/ && \
	./configure --prefix=/opt/php \
		--enable-fpm --enable-intl \
		--enable-mbstring --with-openssl \
		--enable-exif --with-gd \
		--with-jpeg-dir=/usr --with-webp-dir=/usr \
		--with-png-dir=/usr --with-freetype-dir=/usr \
		--with-ldap \
		--with-fpm-user=php \
		--with-fpm-group=php \
		--with-config-file-scan-dir=/opt/php/etc/ \
		--with-config-file-path=/opt/php/etc/php.ini && \
	make -j$(nproc) && \
	make install && \
	mv ~/php-$PHP_VER/php.ini-production /opt/php/etc/php.ini && \
	mv /opt/php/etc/php-fpm.conf.default /opt/php/etc/php-fpm.conf && \
	mv /opt/php/etc/php-fpm.d/www.conf.default /opt/php/etc/php-fpm.d/www.conf && \
	cd ~ && \
	wget https://pecl.php.net/get/imagick-$IMG_VER.tgz && \
	tar xf imagick-$IMG_VER.tgz && \
	cd ~/imagick-$IMG_VER && \
	/opt/php/bin/phpize && \
	./configure --prefix=/opt/php \
		--with-php-config=/opt/php/bin/php-config && \
	make -j$(nproc) && \
	make install && \
	apk del --purge deps && \
	apk add libstdc++ libxml2 icu-libs libpng freetype \
		libjpeg-turbo libwebp libssl1.0 imagemagick \
		openldap && \
	rm -rf ~/*
