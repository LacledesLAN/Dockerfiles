FROM ll/gamesvr

MAINTAINER Laclede's LAN <contact@lacledeslan.com>

ENV SERVER_MAINTAINER "Laclede's LAN"
ENV SERVER_NAME "ll/gamesvr-tfc"

COPY / /gameservers/tfc

# Install Team Fortress Classic Dedicated Server using SteamCMD
RUN mkdir -p /gameservers/tfc && \
	bash /gameservers/_util/steamcmd/steamcmd.sh +login anonymous +force_install_dir /gameservers/tfc +app_update 90 +quit -validate && \
	sleep 3 `#Give steamcmd time to any handles to files in /tmp/#` && \
	RUN rm -fr /tmp/* `#Clean out temp directory to save space#`

WORKDIR /gameservers/