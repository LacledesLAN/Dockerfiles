FROM ll/gamesvr-csgo

MAINTAINER Laclede's LAN <contact@lacledeslan.com>

ENV HOME="/gamesvr/csgo/" SERVER_NAME="ll/gamesvr-csgo-freeplay"

COPY ./files/ /gamesvr/csgo/

RUN `##Set up container enviorment##` && \
    useradd --home /gamesvr/csgo/ --create-home gamesvr-csgo-freeplay

USER gamesvr-csgo-freeplay

WORKDIR /gamesvr/csgo/