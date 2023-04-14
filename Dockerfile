FROM php:8.1-apache

ENV REMOVE_SETUP_DIRS=false \
    UPDATE_SRC=false

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
    && \
    rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/Sarrus1/sourcebans-pp.git /usr/src/sourcebans-pp && \
    mv /usr/src/sourcebans-pp/web/ /usr/src/sourcebans/ && \
    mkdir /docker/

RUN savedAptMark="$(apt-mark showmanual)" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        libgmp-dev \
    && \
    rm -rf /var/lib/apt/lists/* && \
    docker-php-ext-configure gmp && \
    docker-php-ext-install gmp mysqli pdo_mysql bcmath && \
    apt-mark auto '.*' > /dev/null && \
    apt-mark manual $savedAptMark && \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN cd /usr/src/sourcebans && ls -al && composer install

COPY docker-sourcebans-entrypoint.sh /docker/docker-sourcebans-entrypoint.sh
COPY sourcebans.ini /usr/local/etc/php/conf.d/sourcebans.ini

RUN chmod +x /docker/docker-sourcebans-entrypoint.sh

ENTRYPOINT ["/docker/docker-sourcebans-entrypoint.sh"]
CMD ["apache2-foreground"]
