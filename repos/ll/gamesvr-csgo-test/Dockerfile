FROM ll/gamesvr-csgo

MAINTAINER Laclede's LAN <contact@lacledeslan.com>

ENV HOME="/gamesvr/csgo/" SERVER_NAME="ll/gamesvr-csgo-test" 

COPY ./files/ /gamesvr/csgo/

RUN `##Set up container enviorment##` && \
    useradd -M --home /gamesvr/csgo/ gamesvr-csgo-test -c "Docker container user for ll/gamesvr-csgo-test"

USER gamesvr-csgo-test

WORKDIR /gamesvr/csgo/