FROM ll/gamesvr-tf2

MAINTAINER Laclede's LAN <contact@lacledeslan.com>

ENV HOME="/gamesvr/tf2/" SERVER_NAME="ll/gamesvr-tf2-freeplay" 

COPY ./files/ /gamesvr/tf2/

RUN `##Set up container enviorment##` && \
    useradd -M --home /gamesvr/tf2/ gamesvr-tf2-freeplay -c "Docker container user for ll/gamesvr-tf2-freeplay"

USER gamesvr-tf2-freeplay

WORKDIR /gamesvr/tf2/