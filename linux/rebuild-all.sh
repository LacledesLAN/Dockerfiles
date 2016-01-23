#!/bin/bash
#=============================================================================================================
#
#	FILE:	rebuild-all.sh
#
#	DESCRIPTION:	Maintain the LL Docker Image repository by building (and rebuilding) Docker images from
#					origin repositories and sources.
#
#	REQUIREMENTS:	Distribution: Debian-based Linux
#					Packges: curl docker git libc6-i386 lib32gcc1 lib32stdc++6 lib32tinfo5 lib32z1 tar wget
#
#=============================================================================================================


#=============================================================================================================
#===  SETTINGS  ==============================================================================================
#=============================================================================================================
readonly debug_show_docker=true;
readonly debug_contextual_show_ftp=true;
readonly debug_contextual_show_steammcd=true;

readonly setting_contextualize_steam=true;		# If steam apps will be added via docker build context.

#=============================================================================================================
#===  VALIDATE HOST ENVIRONMENT REQUIREMENTS =================================================================
#=============================================================================================================
tput setaf 1; tput bold;
cat /etc/debian_version  > /dev/null 2>&1 || { echo >&2 "Debian-based distribution required."; exit 1; }
command -v curl > /dev/null 2>&1 || { echo >&2 "Package curl required.  Aborting."; exit 1; }
command -v docker > /dev/null 2>&1 || { echo >&2 "Package docker required.  Aborting."; exit 1; }
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
declare rebuild_level=0;
readonly script_directory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
readonly script_filename="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")";
readonly script_fullpath="$script_directory/$script_filename";
readonly script_version=$(stat -c %y "$script_fullpath");


#=============================================================================================================
#===  RUNTIME FUNCTIONS  =====================================================================================
#=============================================================================================================
function draw_horizontal_rule() {
	printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =;
	return 0;
}

function section_head() {
	echo "";
	echo "";
	tput bold
	draw_horizontal_rule;
	echo "   $1";
	draw_horizontal_rule;
	tput sgr0;
	tput dim;
	tput setaf 6;
}

function section_end() {
	tput sgr0;
}

spinner() {
    local pid=$1
    local delay=0.75
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}


##############################################################################################################
####======================================================================================================####
####  SHELL SCRIPT RUNTIME  ==============================================================================####
####======================================================================================================####
##############################################################################################################

clear;
draw_horizontal_rule;
echo "   LL Docker Image Management Tool.  Start time: $(date)";
draw_horizontal_rule;

tput setaf 3; tput bold;
echo "                                                                                         ";
echo "          ██╗     ██╗         ██████╗  ██████╗  ██████╗██╗  ██╗███████╗██████╗           ";
echo "          ██║     ██║         ██╔══██╗██╔═══██╗██╔════╝██║ ██╔╝██╔════╝██╔══██╗          ";
echo "          ██║     ██║         ██║  ██║██║   ██║██║     █████╔╝ █████╗  ██████╔╝          ";
echo "          ██║     ██║         ██║  ██║██║   ██║██║     ██╔═██╗ ██╔══╝  ██╔══██╗          ";
echo "          ███████╗███████╗    ██████╔╝╚██████╔╝╚██████╗██║  ██╗███████╗██║  ██║          ";
echo "          ╚══════╝╚══════╝    ╚═════╝  ╚═════╝  ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝          ";
echo "                                                                                         ";
echo "   ██╗███╗   ███╗ █████╗  ██████╗ ███████╗    ███╗   ███╗ ██████╗ ███╗   ███╗████████╗   ";
echo "   ██║████╗ ████║██╔══██╗██╔════╝ ██╔════╝    ████╗ ████║██╔════╝ ████╗ ████║╚══██╔══╝   ";
echo "   ██║██╔████╔██║███████║██║  ███╗█████╗      ██╔████╔██║██║  ███╗██╔████╔██║   ██║      ";
echo "   ██║██║╚██╔╝██║██╔══██║██║   ██║██╔══╝      ██║╚██╔╝██║██║   ██║██║╚██╔╝██║   ██║      ";
echo "   ██║██║ ╚═╝ ██║██║  ██║╚██████╔╝███████╗    ██║ ╚═╝ ██║╚██████╔╝██║ ╚═╝ ██║   ██║      ";
echo "   ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝    ╚═╝     ╚═╝ ╚═════╝ ╚═╝     ╚═╝   ╚═╝      ";
tput sgr0; tput dim; tput setaf 6;
echo "                                             build: $script_version";
tput sgr0;

tput smul;
echo -e "\n\nENVIRONMENT SETUP";
tput sgr0;

#=========[ Prep Steam contextualization requirements ]-------------------------------------------------------
if [ "$setting_contextualize_steam" = true ] ; then

	echo "setting_contextualize_steam is Enabled.";
	echo -e "\tSteam apps will be added through docker build context: reducing bandwidth at the cost of disk space. ";

	echo -e -n "\tVerifying directory structure...";
	mkdir -p "$script_directory/gamesvr/context_steamcmd";
	echo ".good.";
	
	echo -e -n "\tChecking SteamCMD.."
	
	{ bash "$script_directory/gamesvr/context_steamcmd/"steamcmd.sh +quit; }  &> /dev/null;

	if [ $? -ne 0 ]
	then
		echo -n ".downloading.."
		
		#failed to run SteamCMD.  Download
		{
			rm -rf "$script_directory/gamesvr/context_steamcmd/*";
			
			wget -qO- -r --tries=10 --waitretry=20 --output-document=tmp.tar.gz http://media.steampowered.com/installer/steamcmd_linux.tar.gz;
			tar -xvzf tmp.tar.gz -C "$script_directory/gamesvr/context_steamcmd";
			rm tmp.tar.gz
			
			bash "$script_directory/gamesvr/context_steamcmd/"steamcmd.sh +quit;
		} &> /dev/null;
	fi
	
	echo ".updated...done."
else
	echo "setting_contextualize_steam is Disabled.";
fi

echo "";

tput smul
echo -e "\nDOCKER CLEAN UP";
tput sgr0

echo -n "Destroying all LL docker containers..";
{
	docker rm -f $(docker ps -a -q);   #todo: add filter for ll/*
} &> /dev/null;
echo ".done.";

echo -n "Destroying all LL docker images..";
{
	docker rmi -f $(docker images -q);   #todo: add filter for ll/*

	docker rmi -f ll/gamesvr;
	docker rmi -f ll/gamesvr-csgo;
	docker rmi -f ll/gamesvr-csgo-freeplay;
	docker rmi -f ll/gamesvr-csgo-tourney;
	docker rmi -f ll/gamesvr-hl2dm;
	docker rmi -f ll/gamesvr-tf2;
	docker rmi -f ll/gamesvr-tf2-blindfrag;
	docker rmi -f ll/gamesvr-tf2-download;
	docker rmi -f ll/gamesvr-tf2-freeplay;
} &> /dev/null;
echo ".done.";

tput smul; echo -e "\nREBUILDING IMAGES"; tput sgr0;

#           __                __
#    __  __/ /_  __  ______  / /___  __
#   / / / / __ \/ / / / __ \/ __/ / / /
#  / /_/ / /_/ / /_/ / / / / /_/ /_/ /
#  \__,_/_.___/\__,_/_/ /_/\__/\__,_/
#
	section_head "ubuntu:latest";
	
	echo "Pulling ubuntu:latest from Docker hub";
	docker pull ubuntu:latest

	section_end;

#     ____ _____ _____ ___  ___  ______   _______
#    / __ `/ __ `/ __ `__ \/ _ \/ ___/ | / / ___/
#   / /_/ / /_/ / / / / / /  __(__  )| |/ / /
#   \__, /\__,_/_/ /_/ /_/\___/____/ |___/_/
#  /____/
#
	section_head "Building ll/gamesvr";

	# Ensure any expected context directories exists
	{ mkdir -p "$script_directory/gamesvr/context_steamcmd"; } &> /dev/null; 

	docker build -t ll/gamesvr ./gamesvr/;
	
	section_end;


#     ____ _____ _____ ___  ___  ______   _______      ______________ _____
#    / __ `/ __ `/ __ `__ \/ _ \/ ___/ | / / ___/_____/ ___/ ___/ __ `/ __ \
#   / /_/ / /_/ / / / / / /  __(__  )| |/ / /  /_____/ /__(__  ) /_/ / /_/ /
#   \__, /\__,_/_/ /_/ /_/\___/____/ |___/_/         \___/____/\__, /\____/
#  /____/                                                     /____/
#
	section_head "Building ll/gamesvr-csgo";
	
	# Ensure any expected context directories exists
	mkdir -p "$script_directory/gamesvr-csgo/context_steamapp";

	if [ "$setting_contextualize_steam" = true ] ; then
	
		echo "CONTEXTUALIZE_STEAM: Fetching CS:GO Files.."
		
		bash "$script_directory/gamesvr/context_steamcmd/"steamcmd.sh \
			+login anonymous \
			+force_install_dir "$script_directory/gamesvr-csgo/context_steamapp/" \
			+app_update 740 \
			+quit \
			-validate

	fi

	docker build -t ll/gamesvr-csgo ./gamesvr-csgo/;

	section_end;

#                                                                                   ____                     __
#     ____ _____ _____ ___  ___  ______   _______      ______________ _____        / __/_______  ___  ____  / /___ ___  __
#    / __ `/ __ `/ __ `__ \/ _ \/ ___/ | / / ___/_____/ ___/ ___/ __ `/ __ \______/ /_/ ___/ _ \/ _ \/ __ \/ / __ `/ / / /
#   / /_/ / /_/ / / / / / /  __(__  )| |/ / /  /_____/ /__(__  ) /_/ / /_/ /_____/ __/ /  /  __/  __/ /_/ / / /_/ / /_/ /
#   \__, /\__,_/_/ /_/ /_/\___/____/ |___/_/         \___/____/\__, /\____/     /_/ /_/   \___/\___/ .___/_/\__,_/\__, /
#  /____/                                                     /____/                              /_/            /____/
#
	section_head "Building ll/gamesvr-csgo-freeplay";
	
	docker build -t ll/gamesvr-csgo-freeplay ./gamesvr-csgo-freeplay/

	section_end;


#                                                                                   __
#     ____ _____ _____ ___  ___  ______   _______      ______________ _____        / /_____  __  ___________  ___  __  __
#    / __ `/ __ `/ __ `__ \/ _ \/ ___/ | / / ___/_____/ ___/ ___/ __ `/ __ \______/ __/ __ \/ / / / ___/ __ \/ _ \/ / / /
#   / /_/ / /_/ / / / / / /  __(__  )| |/ / /  /_____/ /__(__  ) /_/ / /_/ /_____/ /_/ /_/ / /_/ / /  / / / /  __/ /_/ /
#   \__, /\__,_/_/ /_/ /_/\___/____/ |___/_/         \___/____/\__, /\____/      \__/\____/\__,_/_/  /_/ /_/\___/\__, /
#  /____/                                                     /____/                                            /____/
#
	section_head "Building ll/gamesvr-csgo-tourney";
	
	docker build -t ll/gamesvr-csgo-tourney ./gamesvr-csgo-tourney/
	
	section_end;


#                                                       __    _____      __
#     ____ _____ _____ ___  ___  ______   _______      / /_  / /__ \____/ /___ ___
#    / __ `/ __ `/ __ `__ \/ _ \/ ___/ | / / ___/_____/ __ \/ /__/ / __  / __ `__ \
#   / /_/ / /_/ / / / / / /  __(__  )| |/ / /  /_____/ / / / // __/ /_/ / / / / / /
#   \__, /\__,_/_/ /_/ /_/\___/____/ |___/_/        /_/ /_/_//____|__,_/_/ /_/ /_/
#  /____/
#
	section_head "Building ll/gamesvr-hl2dm";
	
	# Ensure any expected context directories exists
	mkdir -p "$script_directory/gamesvr-hl2dm/context_steamapp";

	if [ "$setting_contextualize_steam" = true ] ; then

		echo "CONTEXTUALIZE_STEAM: Grabbing HL2DM Files.."
		
		bash "$script_directory/gamesvr/context_steamcmd/"steamcmd.sh \
			+login anonymous \
			+force_install_dir "$script_directory/gamesvr-hl2dm/context_steamapp/" \
			+app_update 232370 \
			+quit \
			-validate

	fi

	docker build -t ll/gamesvr-hl2dm ./gamesvr-hl2dm/

	section_end;


#                                                       __    _____      __                ____                     __
#     ____ _____ _____ ___  ___  ______   _______      / /_  / /__ \____/ /___ ___        / __/_______  ___  ____  / /___ ___  __
#    / __ `/ __ `/ __ `__ \/ _ \/ ___/ | / / ___/_____/ __ \/ /__/ / __  / __ `__ \______/ /_/ ___/ _ \/ _ \/ __ \/ / __ `/ / / /
#   / /_/ / /_/ / / / / / /  __(__  )| |/ / /  /_____/ / / / // __/ /_/ / / / / / /_____/ __/ /  /  __/  __/ /_/ / / /_/ / /_/ /
#   \__, /\__,_/_/ /_/ /_/\___/____/ |___/_/        /_/ /_/_//____|__,_/_/ /_/ /_/     /_/ /_/   \___/\___/ .___/_/\__,_/\__, /
#  /____/                                                                                                /_/            /____/
#
	section_head "Building ll/gamesvr-hl2dm-freeplay";

	docker build -t ll/gamesvr-hl2dm-freeplay ./gamesvr-hl2dm-freeplay/

	section_end;


#    _______________
#   /_  __/ ____/__ \
#    / / / /_   __/ /
#   / / / __/  / __/
#  /_/ /_/    /____/ 
#
	section_head "Building ll/gamesvr-tf2";
	
	# Ensure any expected context directories exists
	mkdir -p "$script_directory/gamesvr-tf2/context_steamapp";

	if [ "$setting_contextualize_steam" = true ] ; then

		echo "CONTEXTUALIZE_STEAM: Grabbing TF2 Files.."
		
		bash "$script_directory/gamesvr/context_steamcmd/"steamcmd.sh \
			+login anonymous \
			+force_install_dir "$script_directory/gamesvr-tf2/context_steamapp/" \
			+app_update 232250 \
			+quit \
			-validate

	fi

	docker build -t ll/gamesvr-tf2 ./gamesvr-tf2/

	echo "Not yet implemented.";
	section_end;


#    _______________      ____  ___           __      ______
#   /_  __/ ____/__ \    / __ )/ (_)___  ____/ /     / ____/________ _____ _
#    / / / /_   __/ /   / __  / / / __ \/ __  /_____/ /_  / ___/ __ `/ __ `/
#   / / / __/  / __/   / /_/ / / / / / / /_/ /_____/ __/ / /  / /_/ / /_/ /
#  /_/ /_/    /____/  /_____/_/_/_/ /_/\__,_/     /_/   /_/   \__,_/\__, /                                                                  
#                                                                  /____/
#
	section_head "";
	
	docker build -t ll/gamesvr-tf2-blindfrag ./gamesvr-tf2-blindfrag/
	
	section_end;
	

#    _______________      ______                     __
#   /_  __/ ____/__ \    / ____/_______  ___  ____  / /___ ___  __
#    / / / /_   __/ /   / /_  / ___/ _ \/ _ \/ __ \/ / __ `/ / / /
#   / / / __/  / __/   / __/ / /  /  __/  __/ /_/ / / /_/ / /_/ /
#  /_/ /_/    /____/  /_/   /_/   \___/\___/ .___/_/\__,_/\__, /
#                                         /_/            /____/
	section_head "";
	
	docker build -t ll/gamesvr-tf2-freeplay ./gamesvr-tf2-freeplay/
	
	section_end;


tput smul;
echo -e "\n\n\nFINISHED\n";

tput sgr0;

echo "";
echo "";
draw_horizontal_rule
draw_horizontal_rule
echo "";