FROM ll/gamesvr-tf2

MAINTAINER Laclede's LAN <contact@lacledeslan.com>

ENV SERVER_MAINTAINER "Laclede's LAN"
ENV SERVER_NAME "ll/gamesvr-tf2-blindfrag"

#Get and stage from gamesvr GitHub Repo "gamesvr-srcds-metamod.linux"
RUN cd `mktemp -d` && \
	git clone git://github.com/LacledesLAN/gamesvr-srcds-metamod.linux && \
	rm -rf *.git && \
	cd `ls -A | head -1` && \
	rm -f *.md && \
	cp -r * /gameservers/tf2/tf/

#Get and stage from gamesvr GitHub Repo "gamesvr-srcds-sourcemod.linux"
RUN cd `mktemp -d` && \
	git clone git://github.com/LacledesLAN/gamesvr-srcds-sourcemod.linux && \
	rm -rf *.git && \
	cd `ls -A | head -1` && \
	rm -f *.md && \
	cp -r * /gameservers/tf2/tf/

#Get and stage from gamesvr GitHub Repo "gamesvr-srcds-tf2-blindfrag"
RUN cd `mktemp -d` && \
	git clone git://github.com/LacledesLAN/gamesvr-srcds-tf2-blindfrag && \
	rm -rf *.git && \
	cd `ls -A | head -1` && \
	rm -f *.md && \
	cp -r * /gameservers/tf2/

# Clean out tmp directory
RUN rm -fr /tmp/* `#Clean out temp directory to save space#`

WORKDIR /gameservers/
