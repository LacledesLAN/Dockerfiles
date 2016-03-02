FROM ll/gamesvr

MAINTAINER Laclede's LAN <contact@lacledeslan.com>

ENV DEBIAN_FRONTEND="noninteractive" HOME="/gamesvr/hl2dm/" SERVER_NAME="ll/gamesvr-hl2dm" 

USER root

COPY . /gamesvr/hl2dm/

RUN rm -f /gamesvr/hl2dm/Dockerfile && \
    rm -f /gamesvr/hl2dm/.dockerignore

USER container

WORKDIR /gamesvr/hl2dm/

#TODO:
#get ftp contents -=> content.lan/fastDownloads/hl2dm/