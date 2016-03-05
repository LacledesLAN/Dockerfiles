FROM ll/gamesvr

MAINTAINER Laclede's LAN <contact@lacledeslan.com>

ENV HOME="/gamesvr/hl2dm/" SERVER_NAME="ll/gamesvr-hl2dm" 

COPY . /gamesvr/hl2dm/

RUN rm -f /gamesvr/hl2dm/Dockerfile && \
    rm -f /gamesvr/hl2dm/.dockerignore

WORKDIR /gamesvr/hl2dm/

#TODO:
#get ftp contents -=> content.lan/fastDownloads/hl2dm/