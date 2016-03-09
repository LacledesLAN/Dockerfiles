#!/bin/bash
#=============================================================================================================
#
#   FILE:   lanyware.sh
#
#   LINE ARUGMENTS:
#                   -r      Completely reset the Docker enviroment
#                   -s      Skip steamcmd validation of installed applications
#
#   DESCRIPTION:    Linux entry point for lanyware
#
#   REQUIREMENTS:   Distribution: Debian-based Linux
#                   Packges: curl docker git libc6-i386 lib32gcc1 lib32stdc++6 lib32tinfo5 lib32z1 tar wget
#
#=============================================================================================================


#=============================================================================================================
#===  VALIDATE HOST ENVIRONMENT REQUIREMENTS =================================================================
#=============================================================================================================
tput setaf 1; tput bold;
cat /etc/debian_version  > /dev/null 2>&1 || { echo >&2 "Debian-based distribution required."; exit 1; }

command -v curl > /dev/null 2>&1 || { echo >&2 "Package curl required.  Aborting."; exit 1; }
command -v git > /dev/null 2>&1 || { echo >&2 "Package git required.  Aborting."; exit 1; }
dpkg -s lib32gcc1 > /dev/null 2>&1 || { echo >&2 "Library lib32gcc1 required.  Aborting."; exit 1; }
dpkg -s lib32stdc++6  > /dev/null 2>&1 || { echo >&2 "Library lib32stdc++6 required.  Aborting."; exit 1; }
dpkg -s lib32tinfo5  > /dev/null 2>&1 || { echo >&2 "Library lib32tinfo5 required.  Aborting."; exit 1; }
dpkg -s lib32z1  > /dev/null 2>&1 || { echo >&2 "Library lib32z1 required.  Aborting."; exit 1; }
command -v tar > /dev/null 2>&1 || { echo >&2 "Package tar required.  Aborting."; exit 1; }
command -v wget > /dev/null 2>&1 || { echo >&2 "Package wget required.  Aborting."; exit 1; }
tput sgr0;


#=============================================================================================================
#===  RUNTIME VARIABLES  =====================================================================================
#=============================================================================================================
declare lanyware_launcher_skip_self_update=false;
declare lanyware_reset_docker_enviroment=false;


#=============================================================================================================
#===  PROCESS LINE ARGUMENTS  ================================================================================
#=============================================================================================================
while getopts ":z" opt; do
    case $opt in
        r)
            lanyware_reset_docker_enviroment=true;
            ;;
        z)
            lanyware_launcher_skip_self_update=true;
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit;
            ;;
    esac
done


#=============================================================================================================
#===  SELF UPDATE  ===========================================================================================
#=============================================================================================================
echo -e -n "\n\n\nUPDATING SELF FROM GITHUB.....";

if [ $lanyware_launcher_skip_self_update != true ] ; then
    cd `mktemp -d`;
    git clone -b master https://github.com/LacledesLAN/LANYWARE;
    rm -rf *.git;
    cd `ls -A | head -1`;
    rm -f *.md;
    cd linux
    cp -r * "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";

    echo ".done.";
else
    echo "..skipped.";
fi


#=============================================================================================================
#===  RESET DOCKER ENVIRONMENT  ==============================================================================
#=============================================================================================================
if [ $lanyware_reset_docker_enviroment != false ] ; then
    ./_lanyware/linux/reset-docker.sh
fi


##############################################################################################################
####======================================================================================================####
####  SHELL SCRIPT RUNTIME  ==============================================================================####
####======================================================================================================####
##############################################################################################################
./_lanyware/linux/forge.sh

