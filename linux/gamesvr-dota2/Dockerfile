FROM ll/gamesvr

MAINTAINER Laclede's LAN <contact@lacledeslan.com>

ENV SERVER_MAINTAINER "Laclede's LAN"
ENV SERVER_NAME "ll/gamesvr-dota2"

COPY . /gamesvr/dota2/

# Install Day of Defeat Source using SteamCMD
RUN mkdir -p /gamesvr/dota2 && \
	bash /gamesvr/_util/steamcmd/steamcmd.sh +login anonymous +force_install_dir /gamesvr/dota2 +app_update 570 +quit -validate && \
	sleep 3 `#Give steamcmd time to any handles to files in /tmp/#`

# Clean out tmp directory
RUN rm -fr /tmp/* `#Clean out temp directory to save space#`

WORKDIR /gamesvr/dota2/