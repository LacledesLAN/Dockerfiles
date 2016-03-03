FROM ll/gamesvr-tf2

MAINTAINER Laclede's LAN <contact@lacledeslan.com>

ENV DEBIAN_FRONTEND="noninteractive" HOME="/gamesvr/tf2/" SERVER_NAME="ll/gamesvr-tf2-freeplay" 

USER root

COPY . /gamesvr/tf2/

RUN rm -f /gamesvr/tf2/Dockerfile && \
    rm -f /gamesvr/tf2/.dockerignore

USER container

WORKDIR /gamesvr/tf2/