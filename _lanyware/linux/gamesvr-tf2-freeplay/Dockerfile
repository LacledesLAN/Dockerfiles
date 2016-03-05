FROM ll/gamesvr-tf2

MAINTAINER Laclede's LAN <contact@lacledeslan.com>

ENV HOME="/gamesvr/tf2/" SERVER_NAME="ll/gamesvr-tf2-freeplay" 

COPY . /gamesvr/tf2/

RUN rm -f /gamesvr/tf2/Dockerfile && \
    rm -f /gamesvr/tf2/.dockerignore

WORKDIR /gamesvr/tf2/