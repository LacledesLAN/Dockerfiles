FROM ubuntu:latest

MAINTAINER Laclede's LAN <contact@lacledeslan.com>

ENV DEBIAN_FRONTEND="noninteractive" HOME="/gamesvr/" SERVER_NAME="ll/gamesvr"

# Install required packages and clean up unused dependencies
RUN `##Set up container enviorment##` && \
    useradd  -m --home /gamesvr/ container -c "Docker image user" && \
    `##Install dependencies##` && \
    apt-get update && \
    apt-get install -y --no-install-recommends tree libc6-i386 lib32gcc1 lib32stdc++6 lib32tinfo5 lib32z1 && \
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -fr /tmp/* && \
    rm -f /gamesvr/Dockerfile && \
    rm -f /gamesvr/.dockerignore

COPY . /gamesvr/

USER container

WORKDIR /gamesvr

CMD ["/bin/bash"]