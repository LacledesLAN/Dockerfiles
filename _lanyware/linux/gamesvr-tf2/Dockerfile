FROM ll/gamesvr

MAINTAINER Laclede's LAN <contact@lacledeslan.com>

ENV HOME="/gamesvr/tf2/" SERVER_NAME="ll/gamesvr-tf2"

COPY . /gamesvr/tf2/

RUN rm -f /gamesvr/hl2dm/Dockerfile && \
    rm -f /gamesvr/hl2dm/.dockerignore

WORKDIR /gamesvr/tf2/

#TODO:
#get ftp contents -=> content.lan/fastDownloads/tf2/