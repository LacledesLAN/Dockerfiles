FROM ubuntu:latest

MAINTAINER Laclede's LAN <contact@lacledeslan.com>

ENV HOME="/gamesvr/" SERVER_NAME="ll/gamesvr:steamcmd"

# Install required packages and clean up unused dependencies
RUN `##Install dependencies##` && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install libc6-i386 lib32gcc1 lib32stdc++6 lib32tinfo5 lib32z1 wget -y && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    `##PREFORM CLEANUP##` && \
    export DEBIAN_FRONTEND=newt && \
    rm -rf /var/lib/apt/lists/* && \
    rm -fr /tmp/* && \
    rm -f /gamesvr/Dockerfile && \
    rm -f /gamesvr/.dockerignore && \
    mkdir /gamesvr/

COPY ./files/ /gamesvr/

WORKDIR /gamesvr

CMD ["/bin/bash"]