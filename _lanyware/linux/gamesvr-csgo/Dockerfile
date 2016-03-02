FROM ll/gamesvr

MAINTAINER Laclede's LAN <contact@lacledeslan.com>

ENV DEBIAN_FRONTEND="noninteractive" HOME="/gamesvr/csgo/" SERVER_NAME="ll/gamesvr-csgo" 

COPY . /gamesvr/csgo/

USER container

WORKDIR /gamesvr/csgo/

CMD ["/bin/bash"]

#TODO:
#get /gamesvr/csgo/ <=- ftp.content.lan/fastDownloads/csgo/