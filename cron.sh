#!/bin/bash

# Cron fix
cd "$(dirname $0)"

function getTarballs
{
    curl "https://api.github.com/repos/craftcms/cms/tags" -o - 2>/dev/null \
        | grep 'tarball_url' \
        | awk -F \" '{print $4}' \
        | sort --version-sort
}

function getTag
{
    echo "$1" | awk -F 'tarball/' '{print $2}'
}

function checkTag
{
    git rev-list "$1" 2>/dev/null
}

getTarballs | while read line; do
    tag=`getTag "$line"`
    echo ">>> $line >>> $tag"

    if [ "x$(checkTag "$tag")" == "x" ]
        then

            url=https://download.craftcdn.com/craft/3.0/Craft-$tag.tar.gz
            if curl --output /dev/null --silent --head --fail "$url"; then
                echo ">>> URL exists: $url"
                sed -r "s/(CRAFTCMS_TAG=\")(.*)(\")/\1$tag\3/g" -i Dockerfile
                git commit -m "Release of CraftCMS changes to $tag" -a
                git push
                git tag "$tag"
                git push --tags
            else
                echo ">>> URL don't exist: $url"
            fi

        else
            echo ">>> Tag $tag has been already created"
    fi

done
