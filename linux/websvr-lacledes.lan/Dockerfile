FROM microsoft/aspnet:latest

MAINTAINER Laclede's LAN <contact@lacledeslan.com>

ENV SERVER_MAINTAINER "Laclede's LAN"
ENV SERVER_NAME "ll/websvr-lacledes.lan"

COPY . /app/

#Get and stage from gamesvr GitHub Repo "websvr-lacledes.lan"
#RUN cd `mktemp -d` && \
#	git clone git://github.com/LacledesLAN/websvr-lacledes.lan && \
#	rm -rf *.git && \
#	cd `ls -A | head -1` && \
#	rm -f *.md
#	cp -r * /usr/share/nginx/html/

WORKDIR /app

ENTRYPOINT ["./approot/kestrel"]