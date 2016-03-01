FROM ll/gamesvr

MAINTAINER Laclede's LAN <contact@lacledeslan.com>

ENV DEBIAN_FRONTEND="noninteractive" SERVER_NAME="ll/gamesvr-dods" 

COPY . /gamesvr/dods/

# Install Day of Defeat Source using SteamCMD
RUN mkdir -p /gamesvr/dods && \
    bash /gamesvr/_util/steamcmd/steamcmd.sh +login anonymous +force_install_dir /gamesvr/dods +app_update 232290 +quit -validate && \
    sleep 3 `#Give steamcmd time to any handles to files in /tmp/#`

# Clean out tmp directory
RUN rm -fr /tmp/* `#Clean out temp directory to save space#`

WORKDIR /gamesvr/dods/