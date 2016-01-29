FROM nginx

MAINTAINER Laclede's LAN <contact@lacledeslan.com>

ENV SERVER_MAINTAINER "Laclede's LAN"
ENV SERVER_NAME "ll/websvr-content.lan"

#Get and stage from gamesvr GitHub Repo "websvr-content.lan"
RUN cd `mktemp -d` && \
	git clone git://github.com/LacledesLAN/websvr-content.lan && \
	rm -rf *.git && \
	cd `ls -A | head -1` && \
	rm -f *.md && \
	cp -r * /usr/share/nginx/html/

WORKDIR /usr/share/nginx/html/