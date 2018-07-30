FROM evilfreelancer/alpine-apache-php7:php-7.1

ENV CRAFTCMS_TAG="3.0.10.2"
ENV CRAFTCMS_TARGZ="https://api.github.com/repos/craftcms/craft/tarball"
WORKDIR /app

# Change documents root from "public" to "web"
RUN sed "s#/app/public#/app/web#" -i /etc/apache2/httpd.conf

RUN curl -L -o craftcms.tar.gz https://download.craftcdn.com/craft/3.0/Craft-$CRAFTCMS_TAG.tar.gz \
 && tar xfvz craftcms.tar.gz -C . \
 && rm craftcms.tar.gz \
 && composer update
