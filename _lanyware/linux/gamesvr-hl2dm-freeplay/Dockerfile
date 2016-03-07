FROM ll/gamesvr-hl2dm

MAINTAINER Laclede's LAN <contact@lacledeslan.com>

ENV HOME="/gamesvr/hl2dm/" SERVER_NAME="ll/gamesvr-hl2dm-freeplay"

COPY ./files/ /gamesvr/hl2dm/

RUN `##Set up container enviorment##` && \
    useradd  -m --home /gamesvr/hl2dm/ gamesvr-hl2dm-freeplay -c "Docker container user for ll/gamesvr-hl2dm-freeplay"

USER gamesvr-hl2dm-freeplay

WORKDIR /gamesvr/hl2dm/