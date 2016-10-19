FROM ll/gamesvr-csgo

MAINTAINER Laclede's LAN <contact@lacledeslan.com>

ENV HOME="/gamesvr/csgo/" SERVER_NAME="ll/gamesvr-csgo-test"

COPY ./files/ /gamesvr/csgo/

RUN `##Set up container enviorment##` && \
    useradd --home /gamesvr/csgo/ --create-home gamesvr-csgo-test

USER gamesvr-csgo-test

WORKDIR /gamesvr/csgo/