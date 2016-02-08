FROM ubuntu:latest

MAINTAINER Laclede's LAN <contact@lacledeslan.com>

ENV SERVER_MAINTAINER "Laclede's LAN"
ENV SERVER_NAME "ll/gamesvr"

COPY . /gamesvr/

# Install required packages and clean up unused dependencies
RUN apt-get update && \
	apt-get install -y --no-install-recommends curl git libc6-i386 lib32gcc1 lib32stdc++6 lib32tinfo5 lib32z1 tar wget && \
	apt-get -y clean && \
	apt-get -y autoremove && \
	rm -rf /var/lib/apt/lists/* && \
	`##Stage SteamCMD to /gamesvr/_util/steamcmd/##` && \
	mkdir -p /gamesvr/_util/steamcmd  && \
	wget -qO- -r --tries=10 --waitretry=20 --output-document=tmp.tar.gz http://media.steampowered.com/installer/steamcmd_linux.tar.gz && \
	tar -xvzf tmp.tar.gz -C /gamesvr/_util/steamcmd/ && \
	rm tmp.tar.gz && \
	sh /gamesvr/_util/steamcmd/steamcmd.sh +quit && \
	sleep 2 && \
	rm -fr /tmp/*

WORKDIR /gamesvr/