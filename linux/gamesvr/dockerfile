FROM ubuntu:latest

MAINTAINER Laclede's LAN <contact@lacledeslan.com>

LABEL description="Base gameserver (e.g. gamesvr) image. Used to build all LL game servers"

RUN apt-get update && \
	apt-get -y clean `#Clean up the apt-get cache#` && \
	apt-get install -y curl git lib32gcc1 libc6-i386 nano wget `#Install required packages#` && \
	apt-get -y autoremove `#Clean up unused dependencies#` && \
	mkdir -p /gameservers/util/steamcmd `#Create destination directories#` && \
	wget -qO-  -r --tries=10 --waitretry=20 --output-document=tmp.tar.gz http://media.steampowered.com/installer/steamcmd_linux.tar.gz `#Get steamcmd tarball#` && \
	tar -xvzf tmp.tar.gz -C /gameservers/util/steamcmd/ `#Unzip steamcmd tarbar in appropriate place#` && \
	rm tmp.tar.gz `#Remove temporary tarball#` && \
	sh /gameservers/util/steamcmd/steamcmd.sh +quit `#Make sure steamcmd is up to date#` && \
	cd `mktemp -d` `#Make a temporary directory#` && \
	git clone https://github.com/LacledesLAN/gamesvr && \
	rm -rf *.git && \
	cd `ls -A | head -1` `#cd into repo directory#` && \
	rm -f *.md && \
	cp -r * /gameservers/ `#copy downloaded files to their destination#`
