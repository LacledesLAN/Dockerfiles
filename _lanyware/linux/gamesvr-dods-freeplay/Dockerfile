FROM ll/gamesvr-dods

MAINTAINER Laclede's LAN <contact@lacledeslan.com>

ENV HOME="/gamesvr/dods/" SERVER_NAME="ll/gamesvr-dods-freeplay"

COPY ./files/ /gamesvr/dods/

RUN `##Set up container enviorment##` && \
    useradd -M --home /gamesvr/dods/ gamesvr-dods-freeplay -c "Docker container user for ll/gamesvr-dods-freeplay"

USER gamesvr-dods-freeplay

WORKDIR /gamesvr/dods/