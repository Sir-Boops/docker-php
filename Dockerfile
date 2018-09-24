FROM alpine:3.7

ENV PHP_VER="7.2.10"
ENV IMG_VER="3.4.3"
ENV APCU_VER="5.1.11"
ENV REDIS_VER="4.0.0"
ENV HTTPD_VER="2.4.34"

RUN addgroup httpd && \
    adduser -H -D -G httpd httpd && \
    echo "httpd:`head /dev/urandom | tr -dc A-Za-z0-9 | head -c 24 | mkpasswd -m sha256`" | chpasswd

RUN apk add -U --virtual deps \
        gcc g++ make libxml2-dev \
        gd-dev libpng-dev freetype-dev \
        libjpeg-turbo-dev libwebp-dev \
        automake autoconf imagemagick-dev \
        icu-dev libressl-dev openldap-dev \
        postgresql-dev curl-dev libzip-dev \
        apr-dev apr-util-dev pcre-dev && \
    apk add libstdc++ libxml2 icu-libs libpng freetype \
        libjpeg-turbo libwebp libssl1.0 imagemagick \
        openldap postgresql-libs diffutils git \
        libzip apr-util && \
    cd ~ && \
    wget https://archive.apache.org/dist/httpd/httpd-$HTTPD_VER.tar.gz && \
    tar xf httpd-$HTTPD_VER.tar.gz && \
    cd ~/httpd-$HTTPD_VER && \
    ./configure --prefix=/opt/httpd && \
    make -j$(nproc) && \
    make install && \
    echo "AddHandler php7-script .php" >> /opt/httpd/conf/httpd.conf && \
    sed -i 's|DocumentRoot "/opt/httpd/htdocs"|DocumentRoot "/opt/www"|' /opt/httpd/conf/httpd.conf && \
    sed -i 's|<Directory "/opt/httpd/htdocs">|<Directory "/opt/www">|' /opt/httpd/conf/httpd.conf && \
    sed -i 's/AllowOverride None/AllowOverride All/' /opt/httpd/conf/httpd.conf && \
    mkdir -p /opt/www && \
    echo "<?php phpinfo();" > /opt/www/index.php && \
    chown httpd:httpd -R /opt/www/ && \
    chmod 755 /opt/www/* && \
    cd ~ && \
    wget https://php.net/distributions/php-$PHP_VER.tar.bz2 && \
    tar xf php-$PHP_VER.tar.bz2 && \
    cd ~/php-$PHP_VER/ && \
    ./configure --prefix=/opt/php \
        --enable-intl --with-apxs2=/opt/httpd/bin/apxs \
        --enable-mbstring --with-openssl \
        --enable-exif --with-gd \
        --with-jpeg-dir=/usr --with-webp-dir=/usr \
        --with-png-dir=/usr --with-freetype-dir=/usr \
        --with-ldap --with-pdo-pgsql --with-pgsql \
        --enable-zip --with-libzip --with-curl \
        --with-zlib-dir \
        --with-config-file-scan-dir=/opt/php/etc/ \
        --with-config-file-path=/opt/php/etc/php.ini && \
    make -j$(nproc) && \
    make install && \
    mv ~/php-$PHP_VER/php.ini-production /opt/php/etc/php.ini && \
    cd ~ && \
    wget https://pecl.php.net/get/imagick-$IMG_VER.tgz && \
    tar xf imagick-$IMG_VER.tgz && \
    cd ~/imagick-$IMG_VER && \
    /opt/php/bin/phpize && \
    ./configure --prefix=/opt/php \
        --with-php-config=/opt/php/bin/php-config && \
    make -j$(nproc) && \
    make install && \
    cd ~ && \
    wget https://pecl.php.net/get/apcu-$APCU_VER.tgz && \
    tar xf apcu-$APCU_VER.tgz && \
    cd ~/apcu-$APCU_VER/ && \
    /opt/php/bin/phpize && \
    ./configure --prefix=/opt/php \
        --with-php-config=/opt/php/bin/php-config && \
    make -j$(nproc) && \
    make install && \
    cd ~ && \
    wget https://pecl.php.net/get/redis-$REDIS_VER.tgz && \
    tar xf redis-$REDIS_VER.tgz && \
    cd ~/redis-$REDIS_VER/ && \
    /opt/php/bin/phpize && \
    ./configure --prefix=/opt/php \
        --with-php-config=/opt/php/bin/php-config && \
    make -j$(nproc) && \
    make install && \
    apk del --purge deps && \
    rm -rf ~/*

CMD /opt/httpd/bin/httpd -e info -DFOREGROUND
