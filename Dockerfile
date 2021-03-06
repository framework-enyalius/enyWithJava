FROM alpine:3.11
MAINTAINER Marcio Bigolin <marcio.bigolinn@gmail.com>
LABEL Description="Imagem com as deps do Enyalius + Java para rodar programas JAVA"

RUN apk --update add apache2 openjdk8 php7 php7-apache2 curl \
          php7 php7-curl php7-json php7-openssl php7-simplexml php7-xml php7-dom php7-phar \
          php7-gd php7-xdebug php7-session php7-pdo_pgsql php7-pdo_mysql php7-mbstring  \
          php7-ctype php7-tokenizer php7-xmlwriter php7-sodium \

RUN rm -f /var/cache/apk/* \
    && mkdir -p /opt/utils 

EXPOSE 80

ADD start.sh /opt/utils/

RUN chmod +x /opt/utils/start.sh

ENTRYPOINT ["/opt/utils/start.sh"]
