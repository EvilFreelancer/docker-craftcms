FROM evilfreelancer/alpine-apache-php7:php-7.2

ENV CRAFTCMS_TAG="3.1.9.1"
ENV CRAFTCMS_RELEASE="3.1"
ENV CRAFTCMS_TARGZ="https://api.github.com/repos/craftcms/craft/tarball"
WORKDIR /app

# Change documents root from "public" to "web"
RUN sed "s#/app/public#/app/web#" -i /etc/apache2/httpd.conf

RUN apk --update --no-cache add php7-fileinfo php7-imagick php7-mcrypt php7-intl \
 && curl -L -o craftcms.tar.gz https://download.craftcdn.com/craft/$CRAFTCMS_RELEASE/Craft-$CRAFTCMS_TAG.tar.gz \
 && tar xfvz craftcms.tar.gz -C . \
 && rm craftcms.tar.gz \
 && chmod +x craft \
 && chown -R apache:apache /app \
 && composer install
