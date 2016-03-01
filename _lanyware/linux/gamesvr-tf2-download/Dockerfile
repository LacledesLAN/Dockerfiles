FROM ll/gamesvr-tf2

MAINTAINER Laclede's LAN <contact@lacledeslan.com>

ENV DEBIAN_FRONTEND="noninteractive" SERVER_NAME="ll/gamesvr-tf2-download" 

COPY . /gamesvr/tf2/

#Get and stage from gamesvr GitHub Repo "gamesvr-srcds-tf2-download"
RUN cd `mktemp -d` && \
    git clone git://github.com/LacledesLAN/gamesvr-srcds-tf2-download && \
    rm -rf *.git && \
    cd `ls -A | head -1` && \
    rm -f *.md && \
    cp -r * /gamesvr/tf2/

# Clean out tmp directory
RUN rm -fr /tmp/* `#Clean out temp directory to save space#` && \
    mv /gamesvr/tf2 /gamesvr/tf2

WORKDIR /gamesvr/tf2/