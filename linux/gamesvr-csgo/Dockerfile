FROM ll/gamesvr

MAINTAINER Laclede's LAN <contact@lacledeslan.com>

ENV SERVER_MAINTAINER "Laclede's LAN"
ENV SERVER_NAME "ll/gamesvr-csgo"

COPY / /gameservers/csgo/

# Install Counter-Strike: Global-Offensive using SteamCMD
RUN mkdir -p /gameservers/csgo && \
	bash /gameservers/_util/steamcmd/steamcmd.sh +login anonymous +force_install_dir /gameservers/csgo +app_update 740 +quit -validate && \
	sleep 3 `#Give steamcmd time to any handles to files in /tmp/#`

# Clean out tmp directory
RUN rm -fr /tmp/* `#Clean out temp directory to save space#`

WORKDIR /gameservers/

#TODO:
#get ftp contents -=> content.lan/fastDownloads/csgo/