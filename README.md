# CraftCMS inside Docker container

Extra small image with basic CraftCMS inside Docker container, based on
Alpine Linux with latest PHP (which available on stable Alpine of
course).

List of available tags [required tag](https://hub.docker.com/r/evilfreelancer/docker-craftcms/tags/).

## How to use

### Via Dockerfile

If you want to use this image and you just need to add source code of
yor application with dependencies, for this just create `Dockerfile`
with following content inside:

```docker
FROM evilfreelancer/docker-craftcms

ADD [".", "/app"]
WORKDIR /app

RUN composer update \
 && chown -R apache:apache /app
```

For building you just need run:

    docker build . --tag craftcms-local

By default image [alpine-apache-php7](https://hub.docker.com/r/evilfreelancer/alpine-apache-php7/)
has `80` port exposed (apache2 here), so you just need plug your local
port with port of container together:

    docker run -d -p 80:80 craftcms-local

### Via docker-compose

If you need MySQL with CraftCMS the you need create the
`docker-compose.yml` file and put inside following content:

```yml
version: "2"

services:

  mysql:
    image: mysql:5.7
    ports:
      - 3306:3306
    environment:
      - MYSQL_DATABASE=craft-production
      - MYSQL_ROOT_PASSWORD=root_pass
      - MYSQL_USER=craft
      - MYSQL_PASSWORD=craft_pass
    volumes:
      - ./databases/mysql:/var/lib/mysql
      - ./logs/mysql:/var/log/mysql

  craftcms:
    image: evilfreelancer/docker-craftcms:latest
    restart: unless-stopped
    ports:
      - 80:80
    environment:
      - SECURITY_KEY=somekey
      - DB_DRIVER=mysql
      - DB_SERVER=mysql
      - DB_USER=craft
      - DB_PASSWORD=craft_pass
      - DB_DATABASE=craft-production
    volumes:
      - ./craft/storage:/app/storage
      - ./craft/templates:/app/templates
      - ./craft/web/assets:/app/web/assets
```

Run this composition of containers:

    docker-compuse up -d

But how to update the CraftCMS image? That's easy, if you use `:latest`
tag of docker image the you just need:

    docker-composer pull
    docker-composer up -d

And your of CraftCMS container will be recreated if new version of
CraftCMS/Craft projects in repository.

## Almost done

Now you need just open this url http://localhost, and you'll see the CraftCMS magic.

## Links

* [alpine-apache-php7](https://hub.docker.com/r/evilfreelancer/alpine-apache-php7/)
* [CraftCMS](https://github.com/craftcms/craft)
