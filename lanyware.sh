#!/bin/bash
source "$( cd "${BASH_SOURCE[0]%/*}" && pwd )/bin/linux-functions-gfx.sh"
source "$( cd "${BASH_SOURCE[0]%/*}" && pwd )/bin/linux-functions-misc.sh"
source "$( cd "${BASH_SOURCE[0]%/*}" && pwd )/bin/linux-functions-steam.sh"
#=============================================================================================================
#
#   DESCRIPTION:    Linux entry point for lanyware
#
#   FILE:   lanyware.sh
#
#   LINE ARUGMENTS:
#           -r    Completely reset the Docker enviroment
#           -s    Skip steamcmd validation of installed applications
#           -z    Skip self updating of lanyware
#
#=============================================================================================================

#=============================================================================================================
#===  VALIDATE HOST ENVIRONMENT REQUIREMENTS =================================================================
#=============================================================================================================
tput setaf 1; tput bold;
cat /etc/debian_version  > /dev/null 2>&1 || { echo >&2 "Debian-based distribution required."; exit 1; }

command -v curl > /dev/null 2>&1 || { echo >&2 "Package curl required.  Aborting."; tput sgr0; exit 1; }
command -v git > /dev/null 2>&1 || { echo >&2 "Package git required.  Aborting."; tput sgr0; exit 1; }
command -v realpath > /dev/null 2>&1 || { echo >&2 "Package realpath required.  Aborting."; tput sgr0; exit 1; }
command -v tar > /dev/null 2>&1 || { echo >&2 "Package tar required.  Aborting."; tput sgr0; exit 1; }
command -v wget > /dev/null 2>&1 || { echo >&2 "Package wget required.  Aborting."; tput sgr0; exit 1; }
tput sgr0;


#=============================================================================================================
#===  RUNTIME VARIABLES  =====================================================================================
#=============================================================================================================
declare lanyware_launcher_skip_self_update=false;
declare lanyware_reset_docker_enviroment=false;
declare lanyware_steamcmd_skip_validation=false;


#=============================================================================================================
#===  PROCESS LINE ARGUMENTS  ================================================================================
#=============================================================================================================
while getopts ":z" opt; do
    case $opt in
        r)
            lanyware_reset_docker_enviroment=true;
            ;;
        s)
            lanyware_steamcmd_skip_validation=true;
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
    #cd `mktemp -d`;
    #git clone -b master --single-branch https://github.com/LacledesLAN/LANYWARE;
    #rm -rf *.git;
    #cd `ls -A | head -1`;
    #rm -f *.md;
    #cd linux
    #cp -r * "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";

    echo ".not implemented :(";
else
    echo "..skipped.";
fi


#=============================================================================================================
#===  RESET DOCKER ENVIRONMENT  ==============================================================================
#=============================================================================================================
if [ $lanyware_reset_docker_enviroment != false ] ; then
    ./bin/linux-reset-docker.sh
fi


##############################################################################################################
####======================================================================================================####
####  SHELL SCRIPT RUNTIME  ==============================================================================####
####======================================================================================================####
##############################################################################################################
./bin/linux-lanyware.sh