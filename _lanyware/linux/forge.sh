#!/bin/bash
#=============================================================================================================
#
#	FILE:	rebuild-all.sh
#
#	LINE ARUGMENTS:
#					-z		Skip auto-update of self
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
readonly debug_contextual_show_github=true;
readonly debug_contextual_show_steammcd=true;

readonly setting_contextualize_steam=true;			# If steam apps will be added via docker build context.


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
declare mode_docker=true;
declare mode_local=false;
declare rebuild_level=0;
declare script_skip_update=false;

readonly script_directory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
readonly script_filename="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")";
readonly script_fullpath="$script_directory/$script_filename";
readonly script_version=$(stat -c %y "$script_fullpath");


#=============================================================================================================
#===  RUNTIME FUNCTIONS  =====================================================================================
#=============================================================================================================

function docker_remove_image() {
	command -v docker > /dev/null 2>&1 || { echo >&2 "Docker is required.  Aborting."; return 999; }
	
	image_count=$(docker images $1 | grep -o "$1" | wc -l);

	if [ $image_count -ge 1 ] ; then

		if [ $image_count -gt 1 ] ; then
			echo -n "Deleting #$1 existing images and any related containers..";
		else
			echo -n "Deleting existing image and any related containers..";
		fi;

		# Remove Derived containers
		docker ps -a | grep $1 | awk '{print $1}' | xargs docker rm

		# Remove image(s)
		docker rmi -f $1

	else
		echo -n "No existing images to remove.";
	fi

	echo ".done.";
}

function draw_horizontal_rule() {
	printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =;
	return 0;
}

function import_github_repo() { # REPO; destination directory
	cd `mktemp -d` && \
		git clone $1 && \
		rm -rf *.git && \
		cd `ls -A | head -1` && \
		rm -f *.md && \
		cp -r * $2
}

function fliptable() {
	echo "（╯°□°）╯ ┻━┻";
}

function import_steamapp() {	# APP ID; destination directory

	bash /gamesvr/_util/steamcmd/steamcmd.sh \
		+login anonymous \
		+force_install_dir $2 \
		+app_update $1 \
		+quit \
		-validate;
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

function read_key() {
	read -n 1 x; while read -n 1 -t .1 y; do x="$x$y"; done
}

function spinner() {
    local pid=$1
    local delay=0.75
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr";
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay;
        printf "\b\b\b\b\b\b";
    done
    printf "    \b\b\b\b";
}

function update_script() {
	tput smul;
	echo -e -n "\n\nUPDATING SELF FROM GITHUB...";
	tput sgr0;
	
	cd `mktemp -d`;
	git clone https://github.com/LacledesLAN/Dockerfiles;
	rm -rf *.git;
	cd `ls -A | head -1`;
	rm -f *.md;
	cd linux
	cp -r * "$script_directory"
	
	echo ".done."
}

function warning_message() {
	tput setaf 1; tput bold;
	echo ""
	echo "      .-------,      !!! WARNING !!!"
	echo "    .'         '.  "
	echo "  .'  _ ___ _ __ '.      $1"
	echo "  |  (_' | / \|_) |"
	echo "  |  ,_) | \_/|   |      $2"
	echo "  '.             .'"
	echo "    '.         .'  "
	echo "      '-------'    "
	tput sgr0;
	echo "  Press any key to continue..."
	
	read_key;
}


#=============================================================================================================
#===  PROCESS LINE ARGUMENTS  ================================================================================
#=============================================================================================================
while getopts ":z" opt; do
  case $opt in
    z)
      script_skip_update=true;
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
  esac
done


##############################################################################################################
####======================================================================================================####
####  SHELL SCRIPT RUNTIME  ==============================================================================####
####======================================================================================================####
##############################################################################################################
echo -e "\n\n\n";
draw_horizontal_rule;
tput sgr0;
echo -n "   LL Server Build Tool ";
tput setaf 2; tput dim;
echo "(build: $script_version)";
tput sgr0;
draw_horizontal_rule;

echo -e "\n";

tput setaf 3; tput bold;
echo "    ██╗      █████╗ ███╗   ██╗██╗   ██╗██╗    ██╗ █████╗ ██████╗ ███████╗    ";
echo "    ██║     ██╔══██╗████╗  ██║╚██╗ ██╔╝██║    ██║██╔══██╗██╔══██╗██╔════╝    ";
echo "    ██║     ███████║██╔██╗ ██║ ╚████╔╝ ██║ █╗ ██║███████║██████╔╝█████╗      ";
echo "    ██║     ██╔══██║██║╚██╗██║  ╚██╔╝  ██║███╗██║██╔══██║██╔══██╗██╔══╝      ";
echo "    ███████╗██║  ██║██║ ╚████║   ██║   ╚███╔███╔╝██║  ██║██║  ██║███████╗    ";
echo "    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝    ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝    ";
tput sgr0; tput dim; tput setaf 6;
echo "                    LAN Party Servers. Anytime. Anywhere.                    ";
echo -e "\n";
tput sgr0;


#==============
#= MENU
#==============

echo "    What do you want to rebuild?"
echo "    "
echo "    0) Rebuild Everything";
echo "    1) Rebuild Starting with the Category Level (Level 1+)";
echo "    2) Rebuild Starting with the Apllication/Content Level (Level 2+)";
echo "    3) Rebuild Starting with the Configuration Level (Level 3)";
echo "    "
echo "    u) Update script and exit "
echo "    x) Exit without doing anything"

declare selected_rebuild_level=""
until [ ! -z $selected_rebuild_level ]; do
	read -n 1 x; while read -n 1 -t .1 y; do x="$x$y"; done
	
	if [ $x == 0 ] ; then
		selected_rebuild_level="0";
		bash "$script_directory"/gfx-allthethings.sh
	elif [ $x == 1 ] ; then
		selected_rebuild_level="1";
	elif [ $x == 2 ] ; then
		selected_rebuild_level="2";
	elif [ $x == 3 ] ; then
		selected_rebuild_level="3";
	elif [ $x == "u" ] ; then
		selected_rebuild_level="99";
	elif [ $x == "U" ] ; then
		selected_rebuild_level="99";
	elif [ $x == "x" ] ; then
		echo -e "\n\nAborting...\n"
		exit;
	elif [ $x == "X" ] ; then
		echo -e "\n\nAborting...\n"
		exit;
	fi
done

echo "Start time: $(date)";
tput smul;
echo -e "\n\nENVIRONMENT SETUP";
tput sgr0;

#=========[ Prep Steam contextualization requirements ]-------------------------------------------------------
if [ "$setting_contextualize_steam" = true ] ; then

	echo "setting_contextualize_steam is Enabled.";
	echo -e "\tSteam apps will be added through docker build context: reducing bandwidth at the cost of disk space. ";

	echo -e -n "\tVerifying directory structure...";
	mkdir -p "$script_directory/gamesvr/_util/steamcmd";
	echo ".good.";
	
	echo -e -n "\tChecking SteamCMD..";
	
	{ bash "$script_directory/gamesvr/_util/steamcmd/"steamcmd.sh +quit; }  &> /dev/null;

	if [ $? -ne 0 ] ; then
		echo -n ".downloading.."
		
		#failed to run SteamCMD.  Download
		{
			rm -rf "$script_directory/gamesvr/_util/steamcmd/*";
			
			wget -qO- -r --tries=10 --waitretry=20 --output-document=tmp.tar.gz http://media.steampowered.com/installer/steamcmd_linux.tar.gz;
			tar -xvzf tmp.tar.gz -C "$script_directory/gamesvr/_util/steamcmd";
			rm tmp.tar.gz
			
			bash "$script_directory/gamesvr/_util/steamcmd/"steamcmd.sh +quit;
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

echo -n "Destroying all docker dangiling images..";
{
	docker rmi $(docker images -qf "dangling=true")
} &> /dev/null;
echo ".done.";

#DELETE ALL DOCKER IMAGES
#docker rmi $(docker images -q)

tput smul; echo -e "\nREBUILDING IMAGES"; tput sgr0;


#         __                  __             _      
#    ____/ /  ____   _____   / /__ _   __   (_) ____
#   / __  /  / __ \ / ___/  / //_/| | / /  / / /_  /
#  / /_/ /  / /_/ // /__   / ,<   | |/ /  / /   / /_
#  \__,_/   \____/ \___/  /_/|_|  |___/  /_/   /___/
#                                                   
if [ $selected_rebuild_level -le 0 ] ; then

	section_head "nate/dockviz";
	
	echo "Pulling nate/dockviz:latest from Docker hub";
	echo "This image provides useful tools to analyze docker images";
	
	docker pull nate/dockviz:latest;
	
	section_end;
fi


#              __                     __         
#    __  __   / /_   __  __   ____   / /_  __  __
#   / / / /  / __ \ / / / /  / __ \ / __/ / / / /
#  / /_/ /  / /_/ // /_/ /  / / / // /_  / /_/ / 
#  \__,_/  /_.___/ \__,_/  /_/ /_/ \__/  \__,_/  
#                                                
if [ $selected_rebuild_level -le 0 ] ; then

	section_head "ubuntu";
	
	echo "Pulling ubuntu:latest from Docker hub";
	
	docker pull ubuntu:latest;
	
	section_end;
fi


#     ____ _____ _____ ___  ___  ______   _______
#    / __ `/ __ `/ __ `__ \/ _ \/ ___/ | / / ___/
#   / /_/ / /_/ / / / / / /  __(__  )| |/ / /
#   \__, /\__,_/_/ /_/ /_/\___/____/ |___/_/
#  /____/
#

if [ $selected_rebuild_level -le 1 ] ; then

	section_head "Building ll/gamesvr";
	
	docker_remove_image "ll/gamesvr";

	# Ensure any expected context directories exists
	{ mkdir -p "$script_directory/gamesvr/_util/steamcmd"; } &> /dev/null; 

	docker build -t ll/gamesvr "$script_directory/gamesvr/";

	section_end;
fi


#     ____ _____ _____ ___  ___  ______   _______      ______________ _____
#    / __ `/ __ `/ __ `__ \/ _ \/ ___/ | / / ___/_____/ ___/ ___/ __ `/ __ \
#   / /_/ / /_/ / / / / / /  __(__  )| |/ / /  /_____/ /__(__  ) /_/ / /_/ /
#   \__, /\__,_/_/ /_/ /_/\___/____/ |___/_/         \___/____/\__, /\____/
#  /____/                                                     /____/
#
if [ $mode_docker -eq true ] ; then
	if [ $selected_rebuild_level -le 0 ] ; then
		#remove containers made from this image
		docker ps -a | grep nate/dockviz | awk '{print $1}' | xargs docker rm
		#remove image
		docker rmi -f nate/dockviz
	fi

	if [[ "$(docker images -q nate/dockviz 2> /dev/null)" == "" ]]; then
		linked_directory="";
	fi
	
	linked_directory="$script_directory/gamesvr-csgo/";
else
	linked_directory="";
fi


if [ $selected_rebuild_level -le 2 ] ; then

	section_head "Building ll/gamesvr-csgo";
	
	docker_remove_image "ll/gamesvr-csgo";

	if [ "$setting_contextualize_steam" = true ] ; then
		echo "CONTEXTUALIZE_STEAM: Fetching CS:GO Files.."
		
		bash "$script_directory/gamesvr/_util/steamcmd/"steamcmd.sh \
			+login anonymous \
			+force_install_dir "$script_directory/gamesvr-csgo/" \
			+app_update 740 \
			+quit \
			-validate;
	fi
	
	docker build -t ll/gamesvr-csgo "$script_directory/gamesvr-csgo/";

	section_end;
fi


#                                                                                   ____                     __
#     ____ _____ _____ ___  ___  ______   _______      ______________ _____        / __/_______  ___  ____  / /___ ___  __
#    / __ `/ __ `/ __ `__ \/ _ \/ ___/ | / / ___/_____/ ___/ ___/ __ `/ __ \______/ /_/ ___/ _ \/ _ \/ __ \/ / __ `/ / / /
#   / /_/ / /_/ / / / / / /  __(__  )| |/ / /  /_____/ /__(__  ) /_/ / /_/ /_____/ __/ /  /  __/  __/ /_/ / / /_/ / /_/ /
#   \__, /\__,_/_/ /_/ /_/\___/____/ |___/_/         \___/____/\__, /\____/     /_/ /_/   \___/\___/ .___/_/\__,_/\__, /
#  /____/                                                     /____/                              /_/            /____/
#
if [ $selected_rebuild_level -le 3 ] ; then

	section_head "Building ll/gamesvr-csgo-freeplay";
	
	docker_remove_image "ll/gamesvr-csgo-freeplay";

	docker build -t ll/gamesvr-csgo-freeplay "$script_directory/gamesvr-csgo-freeplay/";

	section_end;
fi


exit;


#                                                                                   __
#     ____ _____ _____ ___  ___  ______   _______      ______________ _____        / /_____  __  ___________  ___  __  __
#    / __ `/ __ `/ __ `__ \/ _ \/ ___/ | / / ___/_____/ ___/ ___/ __ `/ __ \______/ __/ __ \/ / / / ___/ __ \/ _ \/ / / /
#   / /_/ / /_/ / / / / / /  __(__  )| |/ / /  /_____/ /__(__  ) /_/ / /_/ /_____/ /_/ /_/ / /_/ / /  / / / /  __/ /_/ /
#   \__, /\__,_/_/ /_/ /_/\___/____/ |___/_/         \___/____/\__, /\____/      \__/\____/\__,_/_/  /_/ /_/\___/\__, /
#  /____/                                                     /____/                                            /____/
#
if [ $selected_rebuild_level -le 3 ] ; then

	section_head "Building ll/gamesvr-csgo-tourney";
	
	docker_remove_image "ll/gamesvr-csgo-tourney";
	
	docker build -t ll/gamesvr-csgo-tourney ./gamesvr-csgo-tourney/;
	
	section_end;
fi


#                                                       __    _____      __
#     ____ _____ _____ ___  ___  ______   _______      / /_  / /__ \____/ /___ ___
#    / __ `/ __ `/ __ `__ \/ _ \/ ___/ | / / ___/_____/ __ \/ /__/ / __  / __ `__ \
#   / /_/ / /_/ / / / / / /  __(__  )| |/ / /  /_____/ / / / // __/ /_/ / / / / / /
#   \__, /\__,_/_/ /_/ /_/\___/____/ |___/_/        /_/ /_/_//____|__,_/_/ /_/ /_/
#  /____/
#

if [ $selected_rebuild_level -le 2 ] ; then

	section_head "Building ll/gamesvr-hl2dm";
	
	docker_remove_image "ll/gamesvr-hl2dm";

	if [ "$setting_contextualize_steam" = true ] ; then

		echo "CONTEXTUALIZE_STEAM: Grabbing HL2DM Files.."
		
		bash "$script_directory/gamesvr/_util/steamcmd/"steamcmd.sh \
			+login anonymous \
			+force_install_dir "$script_directory/gamesvr-hl2dm/" \
			+app_update 232370 \
			+quit \
			-validate;
	fi

	docker build -t ll/gamesvr-hl2dm ./gamesvr-hl2dm/;

	section_end;
fi


#                                                       __    _____      __                ____                     __
#     ____ _____ _____ ___  ___  ______   _______      / /_  / /__ \____/ /___ ___        / __/_______  ___  ____  / /___ ___  __
#    / __ `/ __ `/ __ `__ \/ _ \/ ___/ | / / ___/_____/ __ \/ /__/ / __  / __ `__ \______/ /_/ ___/ _ \/ _ \/ __ \/ / __ `/ / / /
#   / /_/ / /_/ / / / / / /  __(__  )| |/ / /  /_____/ / / / // __/ /_/ / / / / / /_____/ __/ /  /  __/  __/ /_/ / / /_/ / /_/ /
#   \__, /\__,_/_/ /_/ /_/\___/____/ |___/_/        /_/ /_/_//____|__,_/_/ /_/ /_/     /_/ /_/   \___/\___/ .___/_/\__,_/\__, /
#  /____/                                                                                                /_/            /____/
#
if [ $selected_rebuild_level -le 3 ] ; then
	
	section_head "Building ll/gamesvr-hl2dm-freeplay";
	
	docker_remove_image "ll/gamesvr-hl2dm-freeplay";
	
	docker build -t ll/gamesvr-hl2dm-freeplay ./gamesvr-hl2dm-freeplay/;

	section_end;
fi


#    _______________
#   /_  __/ ____/__ \
#    / / / /_   __/ /
#   / / / __/  / __/
#  /_/ /_/    /____/ 
#

if [ $selected_rebuild_level -le 2 ] ; then

	section_head "Building ll/gamesvr-tf2";
	
	docker_remove_image "ll/gamesvr-tf2";
	

	if [ "$setting_contextualize_steam" = true ] ; then

		echo "CONTEXTUALIZE_STEAM: Grabbing TF2 Files.."
		
		bash "$script_directory/gamesvr/_util/steamcmd/"steamcmd.sh \
			+login anonymous \
			+force_install_dir "$script_directory/gamesvr-tf2/" \
			+app_update 232250 \
			+quit \
			-validate;

	fi
		docker build -t ll/gamesvr-tf2 ./gamesvr-tf2/;
	
	section_end;
fi


#    _______________      ____  ___           __      ______
#   /_  __/ ____/__ \    / __ )/ (_)___  ____/ /     / ____/________ _____ _
#    / / / /_   __/ /   / __  / / / __ \/ __  /_____/ /_  / ___/ __ `/ __ `/
#   / / / __/  / __/   / /_/ / / / / / / /_/ /_____/ __/ / /  / /_/ / /_/ /
#  /_/ /_/    /____/  /_____/_/_/_/ /_/\__,_/     /_/   /_/   \__,_/\__, /                                                                  
#                                                                  /____/
#
if [ $selected_rebuild_level -le 3 ] ; then

	section_head "Building ll/gamesvr-tf2-blindfrag";
	
	docker_remove_image "ll/gamesvr-tf2-blindfrag";
	
	docker build -t ll/gamesvr-tf2-blindfrag ./gamesvr-tf2-blindfrag/;
	
	section_end;

fi
	

#    _______________      ______                     __
#   /_  __/ ____/__ \    / ____/_______  ___  ____  / /___ ___  __
#    / / / /_   __/ /   / /_  / ___/ _ \/ _ \/ __ \/ / __ `/ / / /
#   / / / __/  / __/   / __/ / /  /  __/  __/ /_/ / / /_/ / /_/ /
#  /_/ /_/    /____/  /_/   /_/   \___/\___/ .___/_/\__,_/\__, /
#                                         /_/            /____/

if [ $selected_rebuild_level -le 3 ] ; then

	section_head "Building ll/gamesvr-tf2-freeplay";
	
	docker_remove_image "ll/gamesvr-tf2-freeplay";
	
	docker build -t ll/gamesvr-tf2-freeplay ./gamesvr-tf2-freeplay/;

	section_end;

fi


#                       _                
#     ____    ____ _   (_)   ____    _  __
#    / __ \  / __ `/  / /   / __ \  | |/_/
#   / / / / / /_/ /  / /   / / / / _>  <  
#  /_/ /_/  \__, /  /_/   /_/ /_/ /_/|_|  
#          /____/                         
#
if [ $selected_rebuild_level -le 0 ] ; then

	section_head "nginx:latest";
	
	echo "Pulling nginx:latest from Docker hub";
	
	docker pull nginx:latest;
	
	section_end;
fi


#                      __                                                         __                  __        __                
#   _      __  ___    / /_    _____ _   __   _____         _____  ____    ____   / /_  ___    ____   / /_      / /  ____ _   ____ 
#  | | /| / / / _ \  / __ \  / ___/| | / /  / ___/ ______ / ___/ / __ \  / __ \ / __/ / _ \  / __ \ / __/     / /  / __ `/  / __ \
#  | |/ |/ / /  __/ / /_/ / (__  ) | |/ /  / /    /_____// /__  / /_/ / / / / // /_  /  __/ / / / // /_   _  / /  / /_/ /  / / / /
#  |__/|__/  \___/ /_.___/ /____/  |___/  /_/            \___/  \____/ /_/ /_/ \__/  \___/ /_/ /_/ \__/  (_)/_/   \__,_/  /_/ /_/ 
#

if [ $selected_rebuild_level -le 3 ] ; then

	section_head "Building ll/websvr-content.lan";
	
	docker_remove_image "ll/websvr-content.lan";
	
	docker build -t ll/websvr-content.lan ./websvr-content.lan/;

	section_end;

fi


if [ $script_skip_update != true ] ; then
	echo "Updaing self...";
	find $script_directory -name \*dockerfile* -type f -delete	#can be removed once BEan's machines are clean of all instances of improperly-cased "dockerfile"
	#update_script;
	
	#. "$script_fullpath" -z;		#Recursively re-run script; disable auto updating to prevent endless loop
	#exit 0;
fi


tput smul;
echo -e "\n\n\n\n\nFINISHED\n";

tput sgr0;



echo "";
echo "";
draw_horizontal_rule;
echo "   LL Docker Image Management Tool.  Stop time: $(date)";
draw_horizontal_rule;
echo "";

echo "Here's what you've got:";
echo "";
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock nate/dockviz images -tl
echo "";
echo "";

