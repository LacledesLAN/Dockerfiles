FROM ll/gamesvr-csgo

MAINTAINER Laclede's LAN <contact@lacledeslan.com>

ENV HOME="/gamesvr/csgo/" SERVER_NAME="ll/gamesvr-csgo-freeplay"

COPY . /gamesvr/csgo/

RUN rm -f /gamesvr/csgo/Dockerfile && \
    rm -f /gamesvr/csgo/.dockerignore

WORKDIR /gamesvr/csgo/