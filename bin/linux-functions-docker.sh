#!/bin/bash

function remove_docker_image() {
    command -v docker > /dev/null 2>&1 || { echo >&2 "Docker is required.  Aborting."; return 255; }

    image_count=$(docker images $1 | grep -o "$1" | wc -l);

    if [ $image_count -ge 1 ] ; then

        if [ $image_count -gt 1 ] ; then
            echo -n "Deleting #$1 existing images and any related containers..";
        else
            echo -n "Deleting existing image and any related containers..";
        fi;

        # Remove Derived containers
        docker ps -a | grep $1 | awk '{print $1}' | xargs docker rm

        # Remove image(s)
        docker rmi -f $1
    else
        echo -n "No existing images to remove.";
    fi

    echo ".done.";
    echo -e "";
}