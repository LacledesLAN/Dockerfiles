FROM ll/gamesvr

MAINTAINER Laclede's LAN <contact@lacledeslan.com>

ENV SERVER_MAINTAINER "Laclede's LAN"
ENV SERVER_NAME "ll/gamesvr-tf2"

COPY . /gamesvr/tf2/

# Install Counter-Strike: Global-Offensive using SteamCMD
RUN mkdir -p /gamesvr/tf2 && \
	bash /gamesvr/_util/steamcmd/steamcmd.sh +login anonymous +force_install_dir /gamesvr/tf2 +app_update 232250 +quit -validate && \
	sleep 3 `#Give steamcmd time to any handles to files in /tmp/#` && \
	rm -fr /tmp/* `#Clean out temp directory to save space#`

WORKDIR /gamesvr/tf2/

#TODO:
#get ftp contents -=> content.lan/fastDownloads/tf2/

#gamesvr-tf2