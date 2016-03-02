FROM ll/gamesvr-csgo

MAINTAINER Laclede's LAN <contact@lacledeslan.com>

ENV DEBIAN_FRONTEND="noninteractive" SERVER_NAME="ll/gamesvr-csgo-tourney" 

COPY . /gamesvr/csgo/

RUN rm -f /gamesvr/csgo/Dockerfile && \
    rm -f /gamesvr/csgo/.dockerignore

#Get and stage from gamesvr GitHub Repo "gamesvr-srcds-metamod.linux"
RUN cd `mktemp -d` && \
    git clone git://github.com/LacledesLAN/gamesvr-srcds-metamod.linux && \
    rm -rf *.git && \
    cd `ls -A | head -1` && \
    rm -f *.md && \
    cp -r * /gamesvr/csgo/csgo/

#Get and stage from gamesvr GitHub Repo "gamesvr-srcds-sourcemod.linux"
RUN cd `mktemp -d` && \
    git clone git://github.com/LacledesLAN/gamesvr-srcds-sourcemod.linux && \
    rm -rf *.git && \
    cd `ls -A | head -1` && \
    rm -f *.md && \
    cp -r * /gamesvr/csgo/csgo/

#Get and stage from gamesvr GitHub Repo "gamesvr-srcds-csgo"
RUN cd `mktemp -d` && \
    git clone git://github.com/LacledesLAN/gamesvr-srcds-csgo && \
    rm -rf *.git && \
    cd `ls -A | head -1` && \
    rm -f *.md && \
    cp -r * /gamesvr/csgo/

#Get and stage from gamesvr GitHub Repo "gamesvr-srcds-csgo-tourney"	
RUN cd `mktemp -d` && \
    git clone git://github.com/LacledesLAN/gamesvr-srcds-csgo-tourney && \
    rm -rf *.git && \
    cd `ls -A | head -1` && \
    rm -f *.md && \
    cp -r * /gamesvr/csgo/

# Clean out tmp directory
RUN rm -fr /tmp/*

USER container

ENV HOME /gamesvr/csgo/

WORKDIR /gamesvr/csgo/