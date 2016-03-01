FROM ll/gamesvr

MAINTAINER Laclede's LAN <contact@lacledeslan.com>

ENV DEBIAN_FRONTEND="noninteractive" SERVER_NAME="ll/gamesvr-hl2dm" 


COPY . /gamesvr/hl2dm/

# Install Half-Life 2 Deathmatch using SteamCMD
RUN mkdir -p /gamesvr/hl2dm && \
    bash /gamesvr/_util/steamcmd/steamcmd.sh +login anonymous +force_install_dir /gamesvr/hl2dm +app_update 232370 +quit

# Clean out tmp directory
RUN rm -fr /tmp/* `#Clean out temp directory to save space#`

WORKDIR /gamesvr/hl2dm/

#TODO:
#get ftp contents -=> content.lan/fastDownloads/hl2dm/