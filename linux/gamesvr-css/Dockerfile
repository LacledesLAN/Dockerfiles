FROM ll/gamesvr

MAINTAINER Laclede's LAN <contact@lacledeslan.com>

ENV SERVER_MAINTAINER "Laclede's LAN"
ENV SERVER_NAME "ll/gamesvr-css"

COPY . /gamesvr/css/

# Install Counter-Strike Source using SteamCMD
RUN mkdir -p /gamesvr/css && \
	bash /gamesvr/_util/steamcmd/steamcmd.sh +login anonymous +force_install_dir /gamesvr/css +app_update 232330 +quit -validate && \
	sleep 3 `#Give steamcmd time to any handles to files in /tmp/#`

# Clean out tmp directory
RUN rm -fr /tmp/* `#Clean out temp directory to save space#`

WORKDIR /gamesvr/css/