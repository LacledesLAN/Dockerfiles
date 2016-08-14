#!/bin/bash

function import_github_repo() { # REPO url; destination directory
    #Header
    echo "Importing GITHub Repo";
    echo -e "\t[Source] $1";
    echo -e "\t[Destination] $2";

    declare GITHUB_REPO_URL="$1";
    declare GITHUB_REPO_DESTINATION_PATH="$2";

    mkdir "$2" --parents;

    {
        cd `mktemp -d` && \
            git clone -b master --single-branch "git://github.com/$1" && \
            rm -rf *.git && \
            cd `ls -A | head -1` && \
            rm -f *.md && \
            cp -r * "$2";
    } &> /dev/null;

    sleep 5;

    echo -e "";
}