FROM ll/gamesvr-dinodday

MAINTAINER Laclede's LAN <contact@lacledeslan.com>

ENV HOME="/gamesvr/dinodday/" SERVER_NAME="ll/gamesvr-dinodday-freeplay"

COPY ./files/ /gamesvr/dinodday/

RUN `##Set up container enviorment##` && \
    useradd  -m --home /gamesvr/dinodday/ gamesvr-dinodday-freeplay -c "Docker container user for ll/gamesvr-dinodday-freeplay"

USER gamesvr-dinodday-freeplay

WORKDIR /gamesvr/dinodday/