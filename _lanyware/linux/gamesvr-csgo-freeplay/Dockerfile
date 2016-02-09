FROM ll/gamesvr-csgo

MAINTAINER Laclede's LAN <contact@lacledeslan.com>

ENV SVR_MAINTAINER="Laclede's LAN" SERVER_NAME="ll/gamesvr-csgo-freeplay"

COPY . /gamesvr/.svr-bin/

#Get and stage from gamesvr GitHub Repo "gamesvr-srcds-metamod.linux"
RUN cd `mktemp -d` && \
	git clone git://github.com/LacledesLAN/gamesvr-srcds-metamod.linux && \
	rm -rf *.git && \
	cd `ls -A | head -1` && \
	rm -f *.md && \
	cp -r * /gamesvr/.svr-bin/

#Get and stage from gamesvr GitHub Repo "gamesvr-srcds-sourcemod.linux"
RUN cd `mktemp -d` && \
	git clone git://github.com/LacledesLAN/gamesvr-srcds-sourcemod.linux && \
	rm -rf *.git && \
	cd `ls -A | head -1` && \
	rm -f *.md && \
	cp -r * /gamesvr/.svr-bin/

#Get and stage from gamesvr GitHub Repo "gamesvr-srcds-csgo"
RUN cd `mktemp -d` && \
	git clone git://github.com/LacledesLAN/gamesvr-srcds-csgo && \
	rm -rf *.git && \
	cd `ls -A | head -1` && \
	rm -f *.md && \
	cp -r * /gamesvr/.svr-bin/

#Get and stage from gamesvr GitHub Repo "gamesvr-srcds-freeplay"	
RUN cd `mktemp -d` && \
	git clone git://github.com/LacledesLAN/gamesvr-srcds-csgo-freeplay && \
	rm -rf *.git && \
	cd `ls -A | head -1` && \
	rm -f *.md && \
	cp -r * /gamesvr/.svr-bin/

WORKDIR /gamesvr/.svr-bin/