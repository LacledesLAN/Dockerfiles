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
readonly setting_contextualize_steam=true;		# If steam apps will be added via docker build context.


#=============================================================================================================
#===  VALIDATE HOST ENVIRONMENT REQUIREMENTS =================================================================
#=============================================================================================================
tput setaf 3; tput bold;
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

function draw_linebreaks() {
	#todo
	echo "";
}


##############################################################################################################
####======================================================================================================####
####  SHELL SCRIPT RUNTIME  ==============================================================================####
####======================================================================================================####
##############################################################################################################

clear;
draw_horizontal_rule;
draw_horizontal_rule;

for tvar in 1 .. 2
do 
	echo -e "\n";
done;

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

	echo -e -n "\tDirectory structure...";
	mkdir -p "$script_directory/gamesvr/context_steamcmd";
	echo ".good.";

	echo -e -n "\tDownloading and staging SteamCMD.."
	{
		wget -qO- -r --tries=10 --waitretry=20 --output-document=tmp.tar.gz http://media.steampowered.com/installer/steamcmd_linux.tar.gz;
		tar -xvzf tmp.tar.gz -C "$script_directory/gamesvr/context_steamcmd";
		rm tmp.tar.gz
	} &> /dev/null;
	echo ".done."

	echo -e -n "\tUpdating SteamCMD.."
	{
		sh "$script_directory/gamesvr/context_steamcmd/"steamcmd.sh +quit;
	} &> /dev/null;
	echo ".done."
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
} &> /dev/null;
echo ".done.";


tput smul;
echo -e "\nREBUILD";
tput sgr0;
draw_horizontal_rule;

#   #####                        #####                
#  #     #   ##   #    # ###### #     # #    # #####  
#  #        #  #  ##  ## #      #       #    # #    # 
#  #  #### #    # # ## # #####   #####  #    # #    # 
#  #     # ###### #    # #            # #    # #####  
#  #     # #    # #    # #      #     #  #  #  #   #  
#   #####  #    # #    # ######  #####    ##   #    # 

	echo "Building ll/gamesvr";
	mkdir -p "$script_directory/gamesvr/context_steamcmd";		# Ensure expected context directory exists

	docker build -t ll/gamesvr ./gamesvr/;
	draw_horizontal_rule;


##############################################################################################################
##############################################################################################################
##############################################################################################################
exit;
##############################################################################################################
##############################################################################################################
##############################################################################################################

#   #####   #####   #####  ####### 
#  #     # #     # #     # #     # 
#  #       #       #       #     # 
#  #        #####  #  #### #     # 
#  #             # #     # #     # 
#  #     # #     # #     # #     # 
#   #####   #####   #####  ####### 

echo "Building ll/gamesvr-csgo...";
if [ "$setting_contextualize_steam" = true ] ; then
	if [ ! -d "./gamesvr-csgo/steamcmd_cache" ]; then
		mkdir $script_directory/gamesvr-csgo/steamcmd_cache/
	fi

	echo -n "CONTEXTUALIZE_STEAM: Pre-Caching CS:GO Files.."
	./_util/steamcmd/steamcmd.sh +login anonymous +force_install_dir $script_directory/gamesvr-csgo/steamcmd_cache/ +app_update 740 +quit -validate
	echo ".done."
fi

docker build -t ll/gamesvr-csgo ./gamesvr-csgo/;

draw_horizontal_rule;

#   #####   #####   #####  #######       #######                                                 
#  #     # #     # #     # #     #       #       #####  ###### ###### #####  #        ##   #   # 
#  #       #       #       #     #       #       #    # #      #      #    # #       #  #   # #  
#  #        #####  #  #### #     # ##### #####   #    # #####  #####  #    # #      #    #   #   
#  #             # #     # #     #       #       #####  #      #      #####  #      ######   #   
#  #     # #     # #     # #     #       #       #   #  #      #      #      #      #    #   #   
#   #####   #####   #####  #######       #       #    # ###### ###### #      ###### #    #   #   

echo "Building ll/gamesvr-csgo-freeplay...";
docker build -t ll/gamesvr-csgo-freeplay ./gamesvr-csgo-freeplay/
draw_horizontal_rule

#   #####   #####   #####  #######       #######                                          
#  #     # #     # #     # #     #          #     ####  #    # #####  #    # ###### #   # 
#  #       #       #       #     #          #    #    # #    # #    # ##   # #       # #  
#  #        #####  #  #### #     # #####    #    #    # #    # #    # # #  # #####    #   
#  #             # #     # #     #          #    #    # #    # #####  #  # # #        #   
#  #     # #     # #     # #     #          #    #    # #    # #   #  #   ## #        #   
#   #####   #####   #####  #######          #     ####   ####  #    # #    # ######   #   

echo "Building ll/gamesvr-csgo-tourney...";
docker build -t ll/gamesvr-csgo-tourney ./gamesvr-csgo-tourney/
draw_horizontal_rule

#  #     # #        #####  ######  #     #
#  #     # #       #     # #     # ##   ##
#  #     # #             # #     # # # # #
#  ####### #        #####  #     # #  #  #
#  #     # #       #       #     # #     #
#  #     # #       #       #     # #     #
#  #     # ####### ####### ######  #     #

echo "Building ll/gamesvr-hl2dm"
if [ "$setting_contextualize_steam" = true ] ; then
	if [ ! -d "./gamesvr-hl2dm/steamcmd_cache" ]; then
		mkdir $script_directory/gamesvr-hl2dm/steamcmd_cache/
	fi

	echo -n "CONTEXTUALIZE_STEAM: Pre-Caching HL2DM Files.."
	./_util/steamcmd/steamcmd.sh +login anonymous +force_install_dir $script_directory/gamesvr-hl2dm/steamcmd_cache/ +app_update 232370 +quit
	echo ".done."
fi

docker build -t ll/gamesvr-hl2dm ./gamesvr-hl2dm/
draw_horizontal_rule;


#  #     # #        #####  ######  #     #       #######                                                 
#  #     # #       #     # #     # ##   ##       #       #####  ###### ###### #####  #        ##   #   # 
#  #     # #             # #     # # # # #       #       #    # #      #      #    # #       #  #   # #  
#  ####### #        #####  #     # #  #  # ##### #####   #    # #####  #####  #    # #      #    #   #   
#  #     # #       #       #     # #     #       #       #####  #      #      #####  #      ######   #   
#  #     # #       #       #     # #     #       #       #   #  #      #      #      #      #    #   #   
#  #     # ####### ####### ######  #     #       #       #    # ###### ###### #      ###### #    #   #



#  ####### #######  #####  
#     #    #       #     # 
#     #    #             # 
#     #    #####    #####  
#     #    #       #       
#     #    #       #       
#     #    #       ####### 



#  ####### #######  #####     ######                            #######                      
#     #    #       #     #    #     # #      # #    # #####     #       #####    ##    ####  
#     #    #             #    #     # #      # ##   # #    #    #       #    #  #  #  #    # 
#     #    #####    #####     ######  #      # # #  # #    #    #####   #    # #    # #      
#     #    #       #          #     # #      # #  # # #    #    #       #####  ###### #  ### 
#     #    #       #          #     # #      # #   ## #    #    #       #   #  #    # #    # 
#     #    #       #######    ######  ###### # #    # #####     #       #    # #    #  ####  




#  ####### #######  #####     #######                                                 
#     #    #       #     #    #       #####  ###### ###### #####  #        ##   #   # 
#     #    #             #    #       #    # #      #      #    # #       #  #   # #  
#     #    #####    #####     #####   #    # #####  #####  #    # #      #    #   #   
#     #    #       #          #       #####  #      #      #####  #      ######   #   
#     #    #       #          #       #   #  #      #      #      #      #    #   #   
#     #    #       #######    #       #    # ###### ###### #      ###### #    #   #   



#  #     #                #####                
#  #  #  # ###### #####  #     # #    # #####  
#  #  #  # #      #    # #       #    # #    # 
#  #  #  # #####  #####   #####  #    # #    # 
#  #  #  # #      #    #       # #    # #####  
#  #  #  # #      #    # #     #  #  #  #   #  
#   ## ##  ###### #####   #####    ##   #    # 


#   #####                                              #          #    #     # 
#  #     #  ####  #    # ##### ###### #    # #####     #         # #   ##    # 
#  #       #    # ##   #   #   #      ##   #   #       #        #   #  # #   # 
#  #       #    # # #  #   #   #####  # #  #   #       #       #     # #  #  # 
#  #       #    # #  # #   #   #      #  # #   #   ### #       ####### #   # # 
#  #     # #    # #   ##   #   #      #   ##   #   ### #       #     # #    ## 
#   #####   ####  #    #   #   ###### #    #   #   ### ####### #     # #     # 


#  #                                                            #          #    #     # 
#  #         ##    ####  #      ###### #####  ######  ####      #         # #   ##    # 
#  #        #  #  #    # #      #      #    # #      #          #        #   #  # #   # 
#  #       #    # #      #      #####  #    # #####   ####      #       #     # #  #  # 
#  #       ###### #      #      #      #    # #           # ### #       ####### #   # # 
#  #       #    # #    # #      #      #    # #      #    # ### #       #     # #    ## 
#  ####### #    #  ####  ###### ###### #####  ######  ####  ### ####### #     # #     # 


tput smul;
echo -e "\nFINISHED\n";
tput sgr0;