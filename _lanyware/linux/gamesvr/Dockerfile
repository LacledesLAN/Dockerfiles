FROM ubuntu:latest

MAINTAINER Laclede's LAN <contact@lacledeslan.com>

ENV DEBIAN_FRONTEND="noninteractive" HOME="/gamesvr/" SERVER_NAME="ll/gamesvr"

# Install required packages and clean up unused dependencies
RUN `##Set up container enviorment##` && \
    useradd  -m --home /gamesvr/ container && \
    `##Install dependencies##` && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends curl git libc6-i386 lib32gcc1 lib32stdc++6 lib32tinfo5 lib32z1 tar wget && \
    apt-get -y clean && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/* && \
    sleep 2 && \
    rm -fr /tmp/* && \
    rm -f /gamesvr/Dockerfile && \
    rm -f /gamesvr/.dockerignore

COPY . /gamesvr/

USER container

WORKDIR /gamesvr

CMD ["/bin/bash"]