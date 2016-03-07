FROM ll/gamesvr-csgo

MAINTAINER Laclede's LAN <contact@lacledeslan.com>

ENV HOME="/gamesvr/csgo/" SERVER_NAME="ll/gamesvr-csgo-freeplay"

COPY ./files/ /gamesvr/csgo/

RUN `##Set up container enviorment##` && \
    useradd  -m --home /gamesvr/csgo/ gamesvr-csgo-freeplay -c "Docker container user for ll/gamesvr-csgo-freeplay"

USER gamesvr-csgo-freeplay

WORKDIR /gamesvr/csgo/