FROM ll/gamesvr-blackmesa

MAINTAINER Laclede's LAN <contact@lacledeslan.com>

ENV HOME="/gamesvr/blackmesa/" SERVER_NAME="ll/gamesvr-blackmesa-freeplay"

COPY ./files/ /gamesvr/blackmesa/

RUN `##Set up container enviorment##` && \
    useradd --home /gamesvr/blackmesa/ --create-home gamesvr-blackmesa-freeplay


USER gamesvr-blackmesa-freeplay

WORKDIR /gamesvr/blackmesa/