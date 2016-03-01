FROM ll/gamesvr

MAINTAINER Laclede's LAN <contact@lacledeslan.com>

ENV DEBIAN_FRONTEND="noninteractive" SERVER_NAME="ll/gamesvr-blackmesa" 

COPY . /gamesvr/blackmesa/

# Install Black Mesa Dedicated Server using SteamCMD
RUN mkdir -p /gamesvr/blackmesa && \
    bash /gamesvr/_util/steamcmd/steamcmd.sh +login anonymous +force_install_dir /gamesvr/blackmesa +app_update 570 +quit -validate && \
    sleep 3 `#Give steamcmd time to any handles to files in /tmp/#`

# Clean out tmp directory
RUN rm -fr /tmp/* `#Clean out temp directory to save space#`

WORKDIR /gamesvr/blackmesa/