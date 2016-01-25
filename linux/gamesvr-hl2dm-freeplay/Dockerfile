FROM ll/gamesvr-hl2dm

MAINTAINER Laclede's LAN <contact@lacledeslan.com>

ENV SERVER_MAINTAINER "Laclede's LAN"
ENV SERVER_NAME "LL Half-Life 2 Deathmatch Freeplay"

#Get and stage from gamesvr GitHub Repo " gamesvr-srcds-metamod.linux"
RUN cd `mktemp -d` && \
	git clone git://github.com/LacledesLAN/gamesvr-srcds-metamod.linux && \
	rm -rf *.git && \
	cd `ls -A | head -1` && \
	rm -f *.md && \
	cp -r * /gameservers/hl2dm/hl2mp
	
#Get and stage from gamesvr GitHub Repo "gamesvr-srcds-sourcemod.linux"
RUN cd `mktemp -d` && \
	git clone git://github.com/LacledesLAN/gamesvr-srcds-sourcemod.linux && \
	rm -rf *.git && \
	cd `ls -A | head -1` && \
	rm -f *.md && \
	cp -r * /gameservers/hl2dm/hl2mp
	
#Get and stage from gamesvr GitHub Repo "gamesvr-srcds-hl2dm-freeplay "
RUN cd `mktemp -d` && \
	git clone git://github.com/LacledesLAN/gamesvr-srcds-hl2dm-freeplay && \
	rm -rf *.git && \
	cd `ls -A | head -1` && \
	rm -f *.md && \
	cp -r * /gameservers/hl2dm/

# Clean out tmp directory
RUN rm -fr /tmp/*

WORKDIR /gameservers/
