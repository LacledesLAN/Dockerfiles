FROM ll/gamesvr

MAINTAINER Laclede's LAN <contact@lacledeslan.com>

ENV SERVER_MAINTAINER "Laclede's LAN"
ENV SERVER_NAME "ll/gamesvr-blackmesa"

COPY / /gameservers/blackmesa/

# Install Black Mesa Dedicated Server using SteamCMD
RUN mkdir -p /gameservers/blackmesa && \
	bash /gameservers/_util/steamcmd/steamcmd.sh +login anonymous +force_install_dir /gameservers/blackmesa +app_update 570 +quit -validate && \
	sleep 3 `#Give steamcmd time to any handles to files in /tmp/#`

# Clean out tmp directory
RUN rm -fr /tmp/* `#Clean out temp directory to save space#`

WORKDIR /gameservers/