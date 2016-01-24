FROM ll/gamesvr

MAINTAINER Laclede's LAN <contact@lacledeslan.com>

ENV SERVER_MAINTAINER "Laclede's LAN"
ENV SERVER_NAME "LL Half-Life 2 Deathmatch Server Base"

ADD context_steamapp /gameservers/hl2dm

# Install Half-Life 2 Deathmatch using SteamCMD
RUN mkdir -p /gameservers/hl2dm && \
	bash /gameservers/_util/steamcmd/steamcmd.sh +login anonymous +force_install_dir /gameservers/hl2dm +app_update 232370 +quit

# Clean out tmp directory
RUN rm -fr /tmp/* `#Clean out temp directory to save space#`

WORKDIR /gameservers/

#TODO:
#get ftp contents -=> content.lan/fastDownloads/hl2dm/
