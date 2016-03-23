FROM ll/gamesvr-csgo

MAINTAINER Laclede's LAN <contact@lacledeslan.com>

ENV HOME="/gamesvr/csgo/" SERVER_NAME="ll/gamesvr-csgo-tourney" 

COPY ./files/ /gamesvr/csgo/

RUN `##Set up container enviorment##` && \
    useradd -M --home /gamesvr/csgo/ gamesvr-csgo-tourney -c "Docker container user for ll/gamesvr-csgo-tourney"

USER gamesvr-csgo-tourney

WORKDIR /gamesvr/csgo/