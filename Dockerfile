FROM evilfreelancer/alpine-apache-php7:php-7.1

ENV CRAFTCMS_TAG="1.0.14"
ENV CRAFTCMS_TARGZ="https://api.github.com/repos/craftcms/craft/tarball"
WORKDIR /app

# Change documents root from "public" to "web"
RUN sed "s#/app/public#/app/web#" -i /etc/apache2/httpd.conf

RUN curl -L -o craftcms.tar.gz "$CRAFTCMS_TARGZ/$CRAFTCMS_TAG" \
 && tar xfvz craftcms.tar.gz -C . --strip-components=1 \
 && rm craftcms.tar.gz \
 && composer update
