###### SETTINGS ######
declare SETTING_STEAM_PRECACHE=true;

###### Build Variables ######
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

###### Functions ######
function horizontalRule {
	printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
}

###### Shell Script ######
echo -e "\n\n\n"
horizontalRule
echo -e "\n"

tput setaf 3
tput bold
echo "                                                                                      "
echo "          ██╗     ██╗         ██████╗  ██████╗  ██████╗██╗  ██╗███████╗██████╗        "
echo "          ██║     ██║         ██╔══██╗██╔═══██╗██╔════╝██║ ██╔╝██╔════╝██╔══██╗       "
echo "          ██║     ██║         ██║  ██║██║   ██║██║     █████╔╝ █████╗  ██████╔╝       "
echo "          ██║     ██║         ██║  ██║██║   ██║██║     ██╔═██╗ ██╔══╝  ██╔══██╗       "
echo "          ███████╗███████╗    ██████╔╝╚██████╔╝╚██████╗██║  ██╗███████╗██║  ██║       "
echo "          ╚══════╝╚══════╝    ╚═════╝  ╚═════╝  ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝       "
echo "                                                                                      "
echo "   ██╗███╗   ███╗ █████╗  ██████╗ ███████╗    ███╗   ███╗ ██████╗ ███╗   ███╗████████╗"
echo "   ██║████╗ ████║██╔══██╗██╔════╝ ██╔════╝    ████╗ ████║██╔════╝ ████╗ ████║╚══██╔══╝"
echo "   ██║██╔████╔██║███████║██║  ███╗█████╗      ██╔████╔██║██║  ███╗██╔████╔██║   ██║   "
echo "   ██║██║╚██╔╝██║██╔══██║██║   ██║██╔══╝      ██║╚██╔╝██║██║   ██║██║╚██╔╝██║   ██║   "
echo "   ██║██║ ╚═╝ ██║██║  ██║╚██████╔╝███████╗    ██║ ╚═╝ ██║╚██████╔╝██║ ╚═╝ ██║   ██║   "
echo "   ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝    ╚═╝     ╚═╝ ╚═════╝ ╚═╝     ╚═╝   ╚═╝   "
echo "                                                                                      "
tput sgr0

tput smul
echo -e "\nENVIRONMENT SETUP";
tput sgr0

# Check that docker is installed
command -v docker > /dev/null 2>&1 || { echo >&2 "I require docker but it's not installed.  Aborting."; exit 1; }
# Check that git is installed
command -v git > /dev/null 2>&1 || { echo >&2 "I require git but it's not installed.  Aborting."; exit 1; }

if [ "$SETTING_STEAM_PRECACHE" = true ] ; then
	echo "STEAM_PRECACHE: Enabled"

	if [ ! -d "./_utils" ]; then
		mkdir ./_utils
	fi

	if [ ! -d "./_utils/steamcmd" ]; then
		mkdir ./_utils/steamcmd
	fi

	#Download and unzip steamcmd#
	echo -n "STEAM_PRECACHE: Downloading and staging SteamCMD.."
	{
		wget -qO- -r --tries=10 --waitretry=20 --output-document=tmp.tar.gz http://media.steampowered.com/installer/steamcmd_linux.tar.gz;
		tar -xvzf tmp.tar.gz -C ./_utils/steamcmd/;
		rm tmp.tar.gz
	} &> /dev/null
	echo ".done."

	#Make sure steamcmd is up to date#
	echo -n "STEAM_PRECACHE: Updating SteamCMD.."
	{
		sh ./_utils/steamcmd/steamcmd.sh +quit;
	} &> /dev/null
	echo ".done."
else
	echo "STEAM_PRECACHE: Disabled"
fi

tput smul
echo -e "\nCLEAN UP";
tput sgr0

echo -n "Destroying all LL docker containers.."
{
	docker rm -f $(docker ps -a -q);   #todo: add filter for ll/*
} &> /dev/null
echo ".done."

echo -n "Destroying all LL docker images.."
{
	docker rmi -f $(docker images -q);   #todo: add filter for ll/*
} &> /dev/null
echo ".done.";

################################################################################
################################################################################
################################################################################

tput smul
echo -e "\nREBUILD";
tput sgr0
horizontalRule

#   #####                        #####                
#  #     #   ##   #    # ###### #     # #    # #####  
#  #        #  #  ##  ## #      #       #    # #    # 
#  #  #### #    # # ## # #####   #####  #    # #    # 
#  #     # ###### #    # #            # #    # #####  
#  #     # #    # #    # #      #     #  #  #  #   #  
#   #####  #    # #    # ######  #####    ##   #    # 

echo "Building ll/gamesvr"
docker build -t ll/gamesvr ./gamesvr/
horizontalRule

#   #####   #####   #####  ####### 
#  #     # #     # #     # #     # 
#  #       #       #       #     # 
#  #        #####  #  #### #     # 
#  #             # #     # #     # 
#  #     # #     # #     # #     # 
#   #####   #####   #####  ####### 

echo "Building ll/gamesvr-csgo...";
if [ "$SETTING_STEAM_PRECACHE" = true ] ; then
	echo -n "STEAM_PRECACHE: Pre-Caching CS:GO Files.."
	./_utils/steamcmd/steamcmd.sh +login anonymous +force_install_dir $SCRIPTDIR/gamesvr-csgo/steamcmd_cache/ +app_update 740 +quit -validate
	echo ".done."
fi

docker build -t ll/gamesvr-csgo ./gamesvr-csgo/

horizontalRule

#   #####   #####   #####  #######       #######                                                 
#  #     # #     # #     # #     #       #       #####  ###### ###### #####  #        ##   #   # 
#  #       #       #       #     #       #       #    # #      #      #    # #       #  #   # #  
#  #        #####  #  #### #     # ##### #####   #    # #####  #####  #    # #      #    #   #   
#  #             # #     # #     #       #       #####  #      #      #####  #      ######   #   
#  #     # #     # #     # #     #       #       #   #  #      #      #      #      #    #   #   
#   #####   #####   #####  #######       #       #    # ###### ###### #      ###### #    #   #   

echo "Building ll/gamesvr-csgo-freeplay...";
docker build -t ll/gamesvr-csgo-freeplay ./gamesvr-csgo-freeplay/
horizontalRule

#   #####   #####   #####  #######       #######                                          
#  #     # #     # #     # #     #          #     ####  #    # #####  #    # ###### #   # 
#  #       #       #       #     #          #    #    # #    # #    # ##   # #       # #  
#  #        #####  #  #### #     # #####    #    #    # #    # #    # # #  # #####    #   
#  #             # #     # #     #          #    #    # #    # #####  #  # # #        #   
#  #     # #     # #     # #     #          #    #    # #    # #   #  #   ## #        #   
#   #####   #####   #####  #######          #     ####   ####  #    # #    # ######   #   

echo "Building ll/gamesvr-csgo-tourney...";
docker build -t ll/gamesvr-csgo-tourney ./gamesvr-csgo-tourney/
horizontalRule

#  #     # #        #####  ######  #     #
#  #     # #       #     # #     # ##   ##
#  #     # #             # #     # # # # #
#  ####### #        #####  #     # #  #  #
#  #     # #       #       #     # #     #
#  #     # #       #       #     # #     #
#  #     # ####### ####### ######  #     #

echo "Building ll/gamesvr-hl2dm"
if [ "$SETTING_STEAM_PRECACHE" = true ] ; then
	echo -n "STEAM_PRECACHE: Pre-Caching HL2DM Files.."
	./_utils/steamcmd/steamcmd.sh +login anonymous +force_install_dir $SCRIPTDIR/gamesvr-hl2dm/steamcmd_cache/ +app_update 232370 +quit
	echo ".done."
fi

docker build -t ll/gamesvr-hl2dm ./gamesvr-hl2dm/
horizontalRule


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


tput smul
echo -e "\nFINISHED\n";
tput sgr0