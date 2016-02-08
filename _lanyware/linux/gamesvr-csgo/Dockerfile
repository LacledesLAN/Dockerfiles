FROM ll/gamesvr

MAINTAINER Laclede's LAN <contact@lacledeslan.com>

ENV SVR_MAINTAINER="Laclede's LAN" SERVER_NAME="ll/gamesvr-csgo"

COPY . /gamesvr/.svr-bin/

# Install Counter-Strike: Global-Offensive using SteamCMD
RUN mkdir -p /gamesvr/.svr-bin && \
	bash /gamesvr/_util/steamcmd/steamcmd.sh +login anonymous +force_install_dir /gamesvr/.svr-bin +app_update 740 +quit -validate && \
	sleep 3 `#Give steamcmd time to release file handles#` && \
	rm -fr /tmp/*

WORKDIR /gamesvr/.svr-bin/

#TODO:
#get /gamesvr/.svr-bin/ <=- ftp.content.lan/fastDownloads/csgo/