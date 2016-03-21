FROM ll/gamesvr-tf2

MAINTAINER Laclede's LAN <contact@lacledeslan.com>

ENV HOME="/gamesvr/tf2/" SERVER_NAME="ll/gamesvr-tf2-download" 

COPY ./files/ /gamesvr/tf2/

RUN `##Set up container enviorment##` && \
    useradd  -m --home /gamesvr/tf2/ gamesvr-tf2-download -c "Docker container user for ll/gamesvr-tf2-download"

USER gamesvr-tf2-download

WORKDIR /gamesvr/tf2/