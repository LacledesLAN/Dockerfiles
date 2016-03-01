FROM ll/gamesvr

MAINTAINER Laclede's LAN <contact@lacledeslan.com>

ENV DEBIAN_FRONTEND="noninteractive" SERVER_NAME="ll/gamesvr-csgo" 

COPY . /gamesvr/.csgo/

# Install Counter-Strike: Global-Offensive using SteamCMD
RUN rm /gamesvr/Dockerfile -f

WORKDIR /gamesvr/.csgo/

#TODO:
#get /gamesvr/.csgo/ <=- ftp.content.lan/fastDownloads/csgo/