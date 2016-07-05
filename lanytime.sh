#!/bin/bash
source "$( cd "${BASH_SOURCE[0]%/*}" && pwd )/bin/linux-functions-gfx.sh"
source "$( cd "${BASH_SOURCE[0]%/*}" && pwd )/bin/linux-functions-misc.sh"
source "$( cd "${BASH_SOURCE[0]%/*}" && pwd )/bin/linux-functions-steam.sh"

tput setaf 3; tput bold;
echo "    ██╗      █████╗ ███╗   ██╗██╗   ██╗████████╗██╗███╗   ███╗███████╗ ";
echo "    ██║     ██╔══██╗████╗  ██║╚██╗ ██╔╝╚══██╔══╝██║████╗ ████║██╔════╝ ";
echo "    ██║     ███████║██╔██╗ ██║ ╚████╔╝    ██║   ██║██╔████╔██║█████╗   ";
echo "    ██║     ██╔══██║██║╚██╗██║  ╚██╔╝     ██║   ██║██║╚██╔╝██║██╔══╝   ";
echo "    ███████╗██║  ██║██║ ╚████║   ██║      ██║   ██║██║ ╚═╝ ██║███████╗ ";
echo "    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝      ╚═╝   ╚═╝╚═╝     ╚═╝╚══════╝ ";
tput sgr0; tput dim; tput setaf 6;
echo "                    LAN Party Servers. Anytime. Anywhere.              ";
echo -e "\n";
tput sgr0;

DOCKER_INSTALLED=true;
command -v docker > /dev/null 2>&1 || { DOCKER_INSTALLED=false; }

if [ "$DOCKER_INSTALLED" = false ] ; then
    echo "DOCKER IS REQUIRED!";
    exit;
fi;

DNS_CONTENT_LAN=`getent hosts content.lan | awk '{ print $1 }'`;
DNS_DOCKER_LAN=`getent hosts docker.lan | awk '{ print $1 }'`;
DNS_LACLEDES_LAN=`getent hosts lacledes.lan | awk '{ print $1 }'`;

MACHINE_IP_ADDRESSES=`ifconfig | awk -F "[: ]+" '/inet addr:/ { if ($4 != "127.0.0.1") print $4 }'`;


if [ -z "$DNS_CONTENT_LAN" ] ; then
    echo "No content.lan dns entry found!  Aborting!";
    exit;
else
    echo "";

    if [[ $DNS_CONTENT_LAN == *"$MACHINE_IP_ADDRESSES"* ]]; then
        echo "YAY!";
    else
        echo "";
        exit;
    fi;
fi;

