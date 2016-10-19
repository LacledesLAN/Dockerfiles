FROM ll/gamesvr-csgo

MAINTAINER Laclede's LAN <contact@lacledeslan.com>

ENV HOME="/gamesvr/csgo/" SERVER_NAME="ll/gamesvr-csgo-tourney"

COPY ./files/ /gamesvr/csgo/

RUN `##Set up container enviorment##` && \
    useradd --home /gamesvr/csgo/ --create-home gamesvr-csgo-tourney

USER gamesvr-csgo-tourney

WORKDIR /gamesvr/csgo/
