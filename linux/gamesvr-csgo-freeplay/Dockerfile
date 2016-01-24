FROM ll/gamesvr-csgo

MAINTAINER Laclede's LAN <contact@lacledeslan.com>

ENV SERVER_MAINTAINER "Laclede's LAN"
ENV SERVER_NAME "LL Counter-Strike GO Freeplay Server"

#Get and stage from gamesvr GitHub Repo "gamesvr-srcds-metamod.linux"
RUN cd `mktemp -d` && \
	git clone git://github.com/LacledesLAN/gamesvr-srcds-metamod.linux && \
	rm -rf *.git && \
	cd `ls -A | head -1` && \
	rm -f *.md && \
	cp -r * /gameservers/csgo/csgo/
	
#Get and stage from gamesvr GitHub Repo "gamesvr-srcds-sourcemod.linux"
RUN cd `mktemp -d` && \
	git clone git://github.com/LacledesLAN/gamesvr-srcds-sourcemod.linux && \
	rm -rf *.git && \
	cd `ls -A | head -1` && \
	rm -f *.md && \
	cp -r * /gameservers/csgo/csgo/

#Get and stage from gamesvr GitHub Repo "gamesvr-srcds-csgo"
RUN cd `mktemp -d` && \
	git clone git://github.com/LacledesLAN/gamesvr-srcds-csgo && \
	rm -rf *.git && \
	cd `ls -A | head -1` && \
	rm -f *.md && \
	cp -r * /gameservers/csgo/
	
#Get and stage from gamesvr GitHub Repo "gamesvr-srcds-free"	
RUN cd `mktemp -d` && \
	git clone git://github.com/LacledesLAN/gamesvr-srcds-csgo-freeplay && \
	rm -rf *.git && \
	cd `ls -A | head -1` && \
	rm -f *.md && \
	cp -r * /gameservers/csgo/

WORKDIR /gameservers/
