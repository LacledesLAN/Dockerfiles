FROM ll/gamesvr-csgo

MAINTAINER Laclede's LAN <contact@lacledeslan.com>

ENV DEBIAN_FRONTEND="noninteractive" HOME="/gamesvr/csgo/" SERVER_NAME="ll/gamesvr-csgo-freeplay"

COPY . /gamesvr/csgo/

RUN rm -f /gamesvr/csgo-freeplay/Dockerfile && \
    rm -f /gamesvr/csgo-freeplay/.dockerignore

USER container

WORKDIR /gamesvr/csgo/