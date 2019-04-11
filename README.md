[![MicroBadger Size](https://img.shields.io/microbadger/image-size/evilfreelancer/docker-craftcms.svg)](https://hub.docker.com/r/evilfreelancer/docker-craftcms/)
[![MicroBadger Layers](https://img.shields.io/microbadger/layers/evilfreelancer/docker-craftcms.svg)](https://hub.docker.com/r/evilfreelancer/docker-craftcms/)
[![Docker Pulls](https://img.shields.io/docker/pulls/evilfreelancer/docker-craftcms.svg)](https://hub.docker.com/r/evilfreelancer/docker-craftcms/)

# CraftCMS inside Docker container

Extra small image with basic CraftCMS inside Docker container, based on
Alpine Linux with latest PHP (which available from repository of stable Alpine of
course).

List of [available tags](https://hub.docker.com/r/evilfreelancer/docker-craftcms/tags/).

## How to use

### Via Dockerfile

If you want to use this image, but you want to add source code of
your application with dependencies, then you need create `Dockerfile`
with content like below in root of your existing CraftCMS project:

```dockerfile
FROM evilfreelancer/docker-craftcms

# You can add any folders or files to /app folder in container
ADD ["composer.json". "templates/", "/app"]
# For example in resources you have additional js, css, img etc. files
ADD ["web/resources/", "/app/resources"]
WORKDIR /app

RUN composer update \
 && chown -R apache:apache /app
```

For building you need just run:

```bash
docker build . --tag craftcms-local
```

The image [alpine-apache-php7](https://hub.docker.com/r/evilfreelancer/alpine-apache-php7/)
has `80` port exposed (apache2 here) by default, so you just need plug your local
port with port of container together:

```bash
docker run -e SECURITY_KEY=somekey -d -p 80:80 craftcms-local
```

For example you want to mount some external folders `/opt/nfs/assets`
with static files (images, documents, etc.) or logs to your container, 
you need to use `-v` (that mean "volume") key:

```bash
docker run \
    -v ./craft/storage:/app/storage \
    -v ./craft/vendor:/app/vendor \
    -v ./craft/web/cpresources:/app/web/cpresources \
    -v /opt/nfs/assets:/app/web/assets \
    -e SECURITY_KEY=somekey \
    -p 80:80 \
    -d craftcms-local
```

### Via command line

You can pull latest (same as with :latest) version of CraftCMS engine from Docker Hub
(will be downloaded latest stable version, eg 3.9.99):

```bash
docker pull evilfreelancer/docker-craftcms
```

Or set the tag which you need:

```bash
docker pull evilfreelancer/docker-craftcms:3.1.18
```

Or minor stable version (will be downloaded latest stable version in 3.1 release, eg. 3.1.99):

```bash
docker pull evilfreelancer/docker-craftcms:3.1
```

Or major stable version (will be downloaded latest stable version, eg. 3.9.99):

```bash
docker pull evilfreelancer/docker-craftcms:3
```

Then start the container:

```bash
docker run -e SECURITY_KEY=somekey -d -p 80:80 docker-craftcms
```

### Via docker-compose

If you need MySQL with CraftCMS the you need create the
`docker-compose.yml` file and put inside following content:

```yml
version: "2"

services:

  # You can use MySQL, MariaDB or PostgreSQL image
  mysql:
    image: mysql:5.7
    restart: unless-stopped
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
    image: evilfreelancer/docker-craftcms:3
    restart: unless-stopped
    ports:
      - 80:80
    environment:
      # Security key is very important
      - SECURITY_KEY=somekey
      - DB_DRIVER=mysql
      - DB_SERVER=mysql
      - DB_USER=craft
      - DB_PASSWORD=craft_pass
      - DB_DATABASE=craft-production
    volumes:
      # Storage with system logs, cache etc.
      - ./craft/storage/logs:/app/storage/logs
      - ./craft/storage/runtime/cache/us:/app/storage/runtime/cache/us
      # Temapltes of website for development stage
      - ./craft/templates:/app/templates
      # Plugins installed to your project (but better use "docker build context" with custom Dockerfile, example above)
      - ./craft/vendor:/app/vendor
      # Static files, with images, js, css, etc.
      - ./craft/web/cpresources:/app/web/cpresources
      - ./craft/web/assets:/app/web/assets
      - ./craft/web/resources:/app/web/resources
      # ... list of any other folders/files which you need
```

Run this composition of containers:

```bash
docker-compose up -d
```

Now need fix permissions to importnat folders, it should be `apache:apache`.

```bash
# Login to craftcms container
docker-compose exec craftcms bash

# Fix permissions from inside of container
chown apache:apache .env
chown apache:apache composer.json
chown apache:apache composer.lock
chown apache:apache config/license.key
chown apache:apache -R storage
chown apache:apache -R vendor
chown apache:apache -R web/cpresources
```

If you mounted `storage`, `vendor`, `web/cpresources` from real drive
then changes will be saved.  

But how to update the CraftCMS image? That's easy, if you use `:latest`
tag of docker image then you just need:

```bash
docker-compose pull
docker-compose up -d
```

And your CraftCMS container will be recreated if new version of CraftCMS
container pushed added in repository.

## Almost done

Now you need just open this url http://localhost and you'll see the CraftCMS magic.
But do not worry if you see the error message, you need install the engine, for this
you need open http://localhost/index.php?p=admin/install page and follow the instruction.

## Links

* [alpine-apache-php7](https://hub.docker.com/r/evilfreelancer/alpine-apache-php7/)
* [CraftCMS](https://github.com/craftcms/craft)
