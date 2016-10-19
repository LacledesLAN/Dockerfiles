FROM ll/gamesvr-tf2

MAINTAINER Laclede's LAN <contact@lacledeslan.com>

ENV HOME="/gamesvr/tf2/" SERVER_NAME="ll/gamesvr-tf2-blindfrag"

COPY ./files/ /gamesvr/tf2/

RUN `##Set up container enviorment##` && \
    useradd --home /gamesvr/tf2/ --create-home gamesvr-tf2-blindfrag


USER gamesvr-tf2-blindfrag

WORKDIR /gamesvr/tf2/