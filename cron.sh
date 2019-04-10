#!/usr/bin/env bash

# Cron fix
cd "$(dirname $0)"

function getTarballs
{
    curl "https://api.github.com/repos/craftcms/cms/tags" -o - 2>/dev/null \
        | grep '"name":' \
        | awk -F \" '{print $4}' \
        | grep -v hotdocs \
        | sort --version-sort
}

function getTarballsOwn
{
    curl "https://api.github.com/repos/EvilFreelancer/docker-craftcms/tags" -o - 2>/dev/null \
        | grep '"name":' \
        | awk -F \" '{print $4}' \
        | grep -v hotdocs \
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

function getMajor
{
    echo "$1" | awk -F \. '{print $1}'
}

function getMajorMinor
{
    echo "$1" | awk -F \. '{print $1"."$2}'
}

function isStable
{
    if [[ $1 == *"-alpha"* ]]; then
        return 1
    fi

    if [[ $1 == *"-beta"* ]]; then
        return 1
    fi

    if [[ $1 == *"-rc"* ]]; then
        return 1
    fi

    return 0
}

function getLatestStable()
{
    getTarballsOwn | while read tag; do
        if isStable "$tag"; then
            echo "$tag"
        fi
    done | tail -n 1
}

function versionGT
{
    test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1"
}

latest=`getLatestStable`

getTarballs | while read tag; do
    major=`getMajor $tag`
    major_minor=`getMajorMinor $tag`

    echo ">>> $major / $major_minor / $tag"

    if [ "x$(checkTag "$tag")" == "x" ]
        then

            echo "> Possible is $major / $major_minor / $tag tags"

            sed -r "s/(CRAFTCMS_TAG=\")(.*)(\")/\1$tag\3/g" -i Dockerfile
            git commit -m "Release of CraftCMS changes to $tag" -a
            git push
            git tag "$tag"

            if isStable "$tag"; then
                # Major with minor release tag
                echo "> Create $major_minor tag of stable release"
                git push origin :refs/tags/"$major_minor"
                git tag -f "$major_minor"

                # Only major release tag
                if versionGT $tag $latest; then
                    echo "> $latest is less than $tag, need to fix major tag"
                    echo "> Create $major tag of stable release"
                    git push origin :refs/tags/"$major"
                    git tag -f "$major_minor"
                fi
            fi

            git push --tags

exit

        else
            echo ">>> Tag $tag has been already created"
    fi

done
