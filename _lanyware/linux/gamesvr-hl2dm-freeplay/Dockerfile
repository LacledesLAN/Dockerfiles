FROM ll/gamesvr-hl2dm

MAINTAINER Laclede's LAN <contact@lacledeslan.com>

ENV HOME="/gamesvr/hl2dm/" SERVER_NAME="ll/gamesvr-hl2dm-freeplay"

COPY . /gamesvr/hl2dm/

RUN rm -f /gamesvr/hl2dm/Dockerfile && \
    rm -f /gamesvr/hl2dm/.dockerignore

WORKDIR /gamesvr/hl2dm/