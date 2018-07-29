#!/bin/bash

# Cron fix
cd "$(dirname $0)"

function getTarballs
{
    curl "https://api.github.com/repos/craftcms/craft/tags?page=2" -o - 2>/dev/null \
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

    if [ "x$(getTag "$tag")" == "x" ]
        then
            sed -r "s/(CRAFTCMS_TAG=\")(.*)(\")/\1$1\3/g" -i Dockerfile
            git commit -m "Release of CraftCMS changes to $tag" -a
            git push
            git tag "$tag"
            git push --tags
        else
            echo ">>> Tag $tag has been already created"
    fi

done
