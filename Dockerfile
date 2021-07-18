FROM evilfreelancer/alpine-apache-php7:php-7.4

ENV CRAFTCMS_TAG="3.7.1"
ENV CRAFTCMS_TARGZ="https://codeload.github.com/craftcms/cms/tar.gz"
WORKDIR /app

# Install required packages
RUN apk --update --no-cache add php7-pecl-imagick php7-intl php7-fileinfo php7-mcrypt imagemagick

# Change documents root from "public" to "web"
RUN sed "s#/app/public#/app/web#" -i /etc/apache2/httpd.conf

# Creanup project folder
RUN rm -Rv public

RUN git clone https://github.com/craftcms/craft.git ./ \
 && sed "s#\"craftcms/cms\": \".*\",#\"craftcms/cms\": \"$CRAFTCMS_TAG\",#" -i composer.json \
 && cat composer.json \
 && composer install --no-dev \
 && chmod 755 /app/craft \
 && chown -R apache:apache /app
