#!/bin/bash
#=============================================================================================================
#
#   FILE:   forge.sh
#
#   LINE ARUGMENTS:
#                   -s      Skip steamcmd validation of installed applications
#
#   DESCRIPTION:    Maintain the LL Docker Image repository by building (and rebuilding) Docker images from
#                   origin repositories and sources.
#
#=============================================================================================================


#=============================================================================================================
#===  SETTINGS  ==============================================================================================
#=============================================================================================================


#=============================================================================================================
#===  RUNTIME VARIABLES  =====================================================================================
#=============================================================================================================
declare MODE_DOCKER_LIBRARY=false;
declare MODE_LOCAL_SERVER=false;

declare DOCKER_INSTALLED=false;
declare DOCKER_REBUILD_LEVEL="";

declare OPTION_STEAM_NO_VALIDATE=false;

readonly SCRIPT_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
readonly SCRIPT_FILENAME="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")";
readonly SCRIPT_FULLPATH="$SCRIPT_DIRECTORY/$SCRIPT_FILENAME";
readonly SCRIPT_VERSION=$(stat -c %y "$SCRIPT_FULLPATH");


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
    echo -e "";
}


function gfx_horizontal_rule() {
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =;
    return 0;
}


function gfx_section_start() {
    echo "";
    echo "";
    tput sgr0;
    tput bold;
    gfx_horizontal_rule;
    echo "   $1";
    gfx_horizontal_rule;
    tput sgr0;
    tput dim;
    tput setaf 6;
}


function gfx_section_end() {
    tput sgr0;
}


function import_github_repo() { # REPO url; destination directory
    #Header
    echo "Importing GITHub Repo";
    echo -e "\t[Source] $1";
    echo -e "\t[Destination] $2";
    
    mkdir -p "$2";

    {
        cd `mktemp -d` && \
            git clone "$1" && \
            rm -rf *.git && \
            cd `ls -A | head -1` && \
            rm -f *.md && \
            cp -r * "$2";
    } &> /dev/null;
    
    echo -e "";
}


function import_steam_app() {    # APP ID; destination directory
    mkdir -p "$2";

    bash "$SCRIPT_DIRECTORY/gamesvr/files/_util/steamcmd/"steamcmd.sh \
        +login anonymous \
        +force_install_dir $2 \
        +app_update $1 \
        -validate \
        +quit;
}


function import_steam_cmd() { # destination directory
    #Header
    tput setaf 6;
    echo -e "\tVerifying SteamCMD";
    echo -e "\t[Target Directory] $1";
    tput sgr0; tput dim; tput setaf 6;

    mkdir -p "$1";
    
    { bash "$1/"steamcmd.sh +quit; }  &> /dev/null;    

    if [ $? -ne 0 ] ; then
        echo -n ".downloading.."

        #failed to run SteamCMD.  Download it.
        {
            rm -rf "$1/*";

            wget -qO- -r --tries=10 --waitretry=20 --output-document=tmp.tar.gz http://media.steampowered.com/installer/steamcmd_linux.tar.gz;
            tar -xvzf tmp.tar.gz -C "$1/";
            rm tmp.tar.gz

            bash "$1/"steamcmd.sh +quit;
        } &> /dev/null;
    fi

    echo ".updated...done."
    echo -e "";
}


function empty_folder() {
    #Header
    tput setaf 6;
    echo "Clearing folder of all contents";
    echo -e "\t[Target] $1";
    
    #make sure target folder exists
    mkdir -p "$1";
    
    # Recursively delete all directories in target folder
    { find "$1/" -mindepth 1 -type d -exec rm -R {}; }  &> /dev/null;  
    
    # Delete all files in target folder excep "Dockerfile" and ".dockerignore"
    { find "$1/" -type f -exec rm -f {};  }  &> /dev/null;  

    echo -e "\n";
}


function menu_docker_library() {
    tput setaf 3; tput dim;
    echo "";
    echo "    ___          _             _    _ _                      ";
    echo "   |   \ ___  __| |_____ _ _  | |  (_) |__ _ _ __ _ _ _ _  _ ";
    echo "   | |) / _ \/ _| / / -_) '_| | |__| | '_ \ '_/ _\` | '_| || |";
    echo "   |___/\___/\__|_\_\___|_|   |____|_|_.__/_| \__,_|_|  \_, |";
    echo "                                                        |__/ ";
    echo "";
    tput sgr0;
    
    echo "    What level do you want to rebuild?";
    echo "    ";
    echo "    0) Rebuild Everything";
    echo "    1) Rebuild Starting with the Category Level (Level 1+)";
    echo "    2) Rebuild Starting with the Apllication/Content Level (Level 2+)";
    echo "    3) Rebuild Starting with the Configuration Level (Level 3)";
    echo "    ";
    echo "    x) Exit without doing anything";
    echo "    ";

    until [ ! -z $DOCKER_REBUILD_LEVEL ]; do
        read -n 1 x; while read -n 1 -t .1 y; do x="$x$y"; done

        if [ $x == 0 ] ; then
            DOCKER_REBUILD_LEVEL="0";
            bash "$SCRIPT_DIRECTORY"/gfx-allthethings.sh
        elif [ $x == 1 ] ; then
            DOCKER_REBUILD_LEVEL="1";
        elif [ $x == 2 ] ; then
            DOCKER_REBUILD_LEVEL="2";
        elif [ $x == 3 ] ; then
            DOCKER_REBUILD_LEVEL="3";
        elif [ $x == "x" ] ; then
            echo -e "\n\nAborting...\n"
            exit;
        elif [ $x == "X" ] ; then
            echo -e "\n\nAborting...\n"
            exit;
        fi
    done
}


function menu_local_server() {
    tput setaf 3; tput dim;
    echo "";
    echo "    _                 _   ___                      ";
    echo "   | |   ___  __ __ _| | / __| ___ _ ___ _____ _ _ ";
    echo "   | |__/ _ \/ _/ _\` | | \__ \/ -_) '_\ V / -_) '_|";
    echo "   |____\___/\__\__,_|_| |___/\___|_|  \_/\___|_|  ";
    echo "";
    echo "";
    tput sgr0;
    
    tput setaf 1; tput bold;
    echo "THIS IS EXPERIMENTAL. PRESS ANY KEY TO CONTINUE!"
    tput sgr0;
    echo "";
    echo "";
    read -n 1 x; while read -n 1 -t .1 y; do x="$x$y"; done
}


#=============================================================================================================
#===  SERVER BUILDER FUNCTIONS  ==============================================================================
#=============================================================================================================
function build_gamesvr_hl2dm() {
    echo "";
}

function build_gamesvr_hl2dm_deathmatch() {
    echo "";
}


#=============================================================================================================
#===  PROCESS LINE ARGUMENTS  ================================================================================
#=============================================================================================================
while getopts ":z" opt; do
    case $opt in
        s)
            OPTION_STEAM_NO_VALIDATE=true;
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
gfx_horizontal_rule;
tput sgr0;
echo -n "   LL Server Build Tool ";
tput setaf 2; tput dim;
echo "(build: $SCRIPT_VERSION)";
tput sgr0;
gfx_horizontal_rule;

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



DOCKER_INSTALLED=true;
command -v docker > /dev/null 2>&1 || { DOCKER_INSTALLED=false; }

if [ "$DOCKER_INSTALLED" = true ] ; then
    echo "    What are we managing?";
    echo "    ";
    echo "    D) Docker image library";
    echo "    L) Game Server on localhost";
    echo "    ";
    echo "    X) Exit without doing anything";
    echo "    ";
    
    until [ "$MODE_DOCKER_LIBRARY" != "$MODE_LOCAL_SERVER" ]; do
        read -n 1 x; while read -n 1 -t .1 y; do x="$x$y"; done

        if [ $x == "d" ] ; then
            MODE_DOCKER_LIBRARY=true;
            menu_docker_library;
        elif [ $x == "D" ] ; then
            MODE_DOCKER_LIBRARY=true;
            menu_docker_library;
        elif [ $x == "l" ] ; then
            MODE_LOCAL_SERVER=true;
            menu_local_server;
        elif [ $x == "L" ] ; then
            MODE_LOCAL_SERVER=true;
            menu_local_server;
        elif [ $x == "x" ] ; then
            echo -e "\n\nAborting...\n"
            exit;
        elif [ $x == "X" ] ; then
            echo -e "\n\nAborting...\n"
            exit;
        fi
    done

else
    echo -e "Could not find Docker on this system; can only manage game servers on localhost.\n";
    MODE_LOCAL_SERVER=true;
fi;




echo "Start time: $(date)";
tput smul;
echo -e "\n\nENVIRONMENT SETUP";
tput sgr0;

#=========[ Prep Steam contextualization requirements ]-------------------------------------------------------

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

if [ "$MODE_DOCKER_LIBRARY" = true ] ; then
    if [ $DOCKER_REBUILD_LEVEL -le 0 ] ; then

        gfx_section_start "Pulling Docker Image -=> nate/dockviz";

        echo "Pulling nate/dockviz:latest from Docker hub";
        echo "This image provides useful tools to analyze docker images";

        docker pull nate/dockviz:latest;

        gfx_section_end;
    fi;
fi;
 


#              __                     __         
#    __  __   / /_   __  __   ____   / /_  __  __
#   / / / /  / __ \ / / / /  / __ \ / __/ / / / /
#  / /_/ /  / /_/ // /_/ /  / / / // /_  / /_/ / 
#  \__,_/  /_.___/ \__,_/  /_/ /_/ \__/  \__,_/  
#                                                
if [ "$MODE_DOCKER_LIBRARY" = true ] ; then
    if [ $DOCKER_REBUILD_LEVEL -le 0 ] ; then

        gfx_section_start "Pulling Docker Image -=> ubuntu:latest";

        echo "Pulling ubuntu:latest from Docker hub";

        docker pull ubuntu:latest;

        gfx_section_end;
    fi;
fi;




#     ____ _____ _____ ___  ___  ______   _______
#    / __ `/ __ `/ __ `__ \/ _ \/ ___/ | / / ___/
#   / /_/ / /_/ / / / / / /  __(__  )| |/ / /
#   \__, /\__,_/_/ /_/ /_/\___/____/ |___/_/
#  /____/
#
if [ "$MODE_DOCKER_LIBRARY" = true ] ; then
    if [ $DOCKER_REBUILD_LEVEL -le 1 ] ; then

        gfx_section_start "Docker -=> Building Image ll/gamesvr";

        docker_remove_image "ll/gamesvr";

        destination_directory="$SCRIPT_DIRECTORY/gamesvr/files";

        import_steam_cmd "$destination_directory/_util/steamcmd";

        docker build -t ll/gamesvr "$SCRIPT_DIRECTORY/gamesvr/";

        gfx_section_end;
    fi;
fi;


#     ____ _____ _____ ___  ___  ______   _______      ______________ _____
#    / __ `/ __ `/ __ `__ \/ _ \/ ___/ | / / ___/_____/ ___/ ___/ __ `/ __ \
#   / /_/ / /_/ / / / / / /  __(__  )| |/ / /  /_____/ /__(__  ) /_/ / /_/ /
#   \__, /\__,_/_/ /_/ /_/\___/____/ |___/_/         \___/____/\__, /\____/
#  /____/                                                     /____/
#
if [ "$MODE_DOCKER_LIBRARY" = true ] ; then
    if [ $DOCKER_REBUILD_LEVEL -le 2 ] ; then

        gfx_section_start "Docker -=> Building Image ll/gamesvr-csgo";

        docker_remove_image "ll/gamesvr-csgo";
        
        destination_directory="$SCRIPT_DIRECTORY/gamesvr-csgo/files";
        
        import_steam_app 740 "$destination_directory"

        docker build -t ll/gamesvr-csgo "$SCRIPT_DIRECTORY/gamesvr-csgo/";

        gfx_section_end;
    fi;
fi;


#                                                                                   ____                     __
#     ____ _____ _____ ___  ___  ______   _______      ______________ _____        / __/_______  ___  ____  / /___ ___  __
#    / __ `/ __ `/ __ `__ \/ _ \/ ___/ | / / ___/_____/ ___/ ___/ __ `/ __ \______/ /_/ ___/ _ \/ _ \/ __ \/ / __ `/ / / /
#   / /_/ / /_/ / / / / / /  __(__  )| |/ / /  /_____/ /__(__  ) /_/ / /_/ /_____/ __/ /  /  __/  __/ /_/ / / /_/ / /_/ /
#   \__, /\__,_/_/ /_/ /_/\___/____/ |___/_/         \___/____/\__, /\____/     /_/ /_/   \___/\___/ .___/_/\__,_/\__, /
#  /____/                                                     /____/                              /_/            /____/
#
if [ "$MODE_DOCKER_LIBRARY" = true ] ; then
    if [ $DOCKER_REBUILD_LEVEL -le 3 ] ; then

        gfx_section_start "Docker -=> Building Image ll/gamesvr-csgo-freeplay";

        docker_remove_image "ll/gamesvr-csgo-freeplay";
        
        destination_directory="$SCRIPT_DIRECTORY/gamesvr-csgo-freeplay/files";

        empty_folder "$destination_directory";

        import_github_repo "git://github.com/LacledesLAN/gamesvr-srcds-metamod.linux" "$destination_directory/csgo/";
        
        import_github_repo "git://github.com/LacledesLAN/gamesvr-srcds-sourcemod.linux" "$destination_directory/csgo/";

        import_github_repo "git://github.com/LacledesLAN/gamesvr-srcds-csgo" "$destination_directory/";

        import_github_repo "git://github.com/LacledesLAN/gamesvr-srcds-csgo-freeplay" "$destination_directory/";

        docker build -t ll/gamesvr-csgo-freeplay "$SCRIPT_DIRECTORY/gamesvr-csgo-freeplay/";

        gfx_section_end;
    fi;
fi;


#                                                                                   __
#     ____ _____ _____ ___  ___  ______   _______      ______________ _____        / /_____  __  ___________  ___  __  __
#    / __ `/ __ `/ __ `__ \/ _ \/ ___/ | / / ___/_____/ ___/ ___/ __ `/ __ \______/ __/ __ \/ / / / ___/ __ \/ _ \/ / / /
#   / /_/ / /_/ / / / / / /  __(__  )| |/ / /  /_____/ /__(__  ) /_/ / /_/ /_____/ /_/ /_/ / /_/ / /  / / / /  __/ /_/ /
#   \__, /\__,_/_/ /_/ /_/\___/____/ |___/_/         \___/____/\__, /\____/      \__/\____/\__,_/_/  /_/ /_/\___/\__, /
#  /____/                                                     /____/                                            /____/
#
if [ "$MODE_DOCKER_LIBRARY" = true ] ; then
    if [ $DOCKER_REBUILD_LEVEL -le 3 ] ; then

        gfx_section_start "Docker -=> Building Image ll/gamesvr-csgo-tourney";

        docker_remove_image "ll/gamesvr-csgo-tourney";
        
        destination_directory="$SCRIPT_DIRECTORY/gamesvr-csgo-tourney/files";
        
        empty_folder "$destination_directory";
        
        import_github_repo "git://github.com/LacledesLAN/gamesvr-srcds-metamod.linux" "$destination_directory/csgo/";
        
        import_github_repo "git://github.com/LacledesLAN/gamesvr-srcds-sourcemod.linux" "$destination_directory/csgo/";

        import_github_repo "git://github.com/LacledesLAN/gamesvr-srcds-csgo" "$destination_directory/";

        import_github_repo "git://github.com/LacledesLAN/gamesvr-srcds-csgo-tourney" "$destination_directory/";

        docker build -t ll/gamesvr-csgo-tourney "$SCRIPT_DIRECTORY/gamesvr-csgo-tourney/";

        gfx_section_end;

    fi;
fi;


#                                                       __    _____      __
#     ____ _____ _____ ___  ___  ______   _______      / /_  / /__ \____/ /___ ___
#    / __ `/ __ `/ __ `__ \/ _ \/ ___/ | / / ___/_____/ __ \/ /__/ / __  / __ `__ \
#   / /_/ / /_/ / / / / / /  __(__  )| |/ / /  /_____/ / / / // __/ /_/ / / / / / /
#   \__, /\__,_/_/ /_/ /_/\___/____/ |___/_/        /_/ /_/_//____|__,_/_/ /_/ /_/
#  /____/
#
if [ "$MODE_DOCKER_LIBRARY" = true ] ; then
    if [ $DOCKER_REBUILD_LEVEL -le 2 ] ; then

        gfx_section_start "Docker -=> Building Image ll/gamesvr-hl2dm";

        docker_remove_image "ll/gamesvr-hl2dm";

        destination_directory="$SCRIPT_DIRECTORY/gamesvr-hl2dm/files";

        import_steam_app 232370 "$destination_directory/"

        docker build -t ll/gamesvr-hl2dm "$SCRIPT_DIRECTORY/gamesvr-hl2dm/";

        gfx_section_end;
    fi;
fi;


#                                                       __    _____      __                ____                     __
#     ____ _____ _____ ___  ___  ______   _______      / /_  / /__ \____/ /___ ___        / __/_______  ___  ____  / /___ ___  __
#    / __ `/ __ `/ __ `__ \/ _ \/ ___/ | / / ___/_____/ __ \/ /__/ / __  / __ `__ \______/ /_/ ___/ _ \/ _ \/ __ \/ / __ `/ / / /
#   / /_/ / /_/ / / / / / /  __(__  )| |/ / /  /_____/ / / / // __/ /_/ / / / / / /_____/ __/ /  /  __/  __/ /_/ / / /_/ / /_/ /
#   \__, /\__,_/_/ /_/ /_/\___/____/ |___/_/        /_/ /_/_//____|__,_/_/ /_/ /_/     /_/ /_/   \___/\___/ .___/_/\__,_/\__, /
#  /____/                                                                                                /_/            /____/
#
if [ "$MODE_DOCKER_LIBRARY" = true ] ; then
    if [ $DOCKER_REBUILD_LEVEL -le 3 ] ; then

        gfx_section_start "Docker -=> Building Image ll/gamesvr-hl2dm-freeplay";

        docker_remove_image "ll/gamesvr-hl2dm-freeplay";

        destination_directory="$SCRIPT_DIRECTORY/gamesvr-hl2dm-freeplay/files";

        empty_folder "$destination_directory";

        import_github_repo "git://github.com/LacledesLAN/gamesvr-srcds-metamod.linux" "$destination_directory/hl2mp/";

        import_github_repo "git://github.com/LacledesLAN/gamesvr-srcds-sourcemod.linux" "$destination_directory/hl2mp/";

        import_github_repo "git://github.com/LacledesLAN/gamesvr-srcds-hl2dm-freeplay" "$destination_directory/";

        docker build -t ll/gamesvr-hl2dm-freeplay "$SCRIPT_DIRECTORY/gamesvr-hl2dm-freeplay/";

        gfx_section_end;
    fi;
fi;


#    _______________
#   /_  __/ ____/__ \
#    / / / /_   __/ /
#   / / / __/  / __/
#  /_/ /_/    /____/ 
#
if [ "$MODE_DOCKER_LIBRARY" = true ] ; then
    if [ $DOCKER_REBUILD_LEVEL -le 2 ] ; then

        gfx_section_start "Docker -=> Building Image ll/gamesvr-tf2";

        docker_remove_image "ll/gamesvr-tf2";
        
        destination_directory="$SCRIPT_DIRECTORY/gamesvr-tf2/files";
        
        import_steam_app 232250 "$destination_directory/"

        docker build -t ll/gamesvr-tf2 "$SCRIPT_DIRECTORY/gamesvr-tf2/";

        gfx_section_end;
    fi;
fi;


#    _______________      ____  ___           __      ______
#   /_  __/ ____/__ \    / __ )/ (_)___  ____/ /     / ____/________ _____ _
#    / / / /_   __/ /   / __  / / / __ \/ __  /_____/ /_  / ___/ __ `/ __ `/
#   / / / __/  / __/   / /_/ / / / / / / /_/ /_____/ __/ / /  / /_/ / /_/ /
#  /_/ /_/    /____/  /_____/_/_/_/ /_/\__,_/     /_/   /_/   \__,_/\__, /                                                                  
#                                                                  /____/
#
if [ "$MODE_DOCKER_LIBRARY" = true ] ; then
    if [ $DOCKER_REBUILD_LEVEL -le 3 ] ; then

        gfx_section_start "Docker -=> Building Image ll/gamesvr-tf2-blindfrag";

        docker_remove_image "ll/gamesvr-tf2-blindfrag";
        
        destination_directory="$SCRIPT_DIRECTORY/gamesvr-tf2-blindfrag/files";

        empty_folder "$destination_directory";

        import_github_repo "git://github.com/LacledesLAN/gamesvr-srcds-metamod.linux" "$destination_directory/tf/";

        import_github_repo "git://github.com/LacledesLAN/gamesvr-srcds-sourcemod.linux" "$destination_directory/tf/";

        import_github_repo "git://github.com/LacledesLAN/gamesvr-srcds-tf2-blindfrag" "$destination_directory/";

        docker build -t ll/gamesvr-tf2-blindfrag "$SCRIPT_DIRECTORY/gamesvr-tf2-blindfrag/";

        gfx_section_end;

    fi;
fi;


#    _______________      ______                     __
#   /_  __/ ____/__ \    / ____/_______  ___  ____  / /___ ___  __
#    / / / /_   __/ /   / /_  / ___/ _ \/ _ \/ __ \/ / __ `/ / / /
#   / / / __/  / __/   / __/ / /  /  __/  __/ /_/ / / /_/ / /_/ /
#  /_/ /_/    /____/  /_/   /_/   \___/\___/ .___/_/\__,_/\__, /
#                                         /_/            /____/
#
if [ "$MODE_DOCKER_LIBRARY" = true ] ; then
    if [ $DOCKER_REBUILD_LEVEL -le 3 ] ; then

        gfx_section_start "Docker -=> Building Image ll/gamesvr-tf2-freeplay";

        docker_remove_image "ll/gamesvr-tf2-freeplay";

        destination_directory="$SCRIPT_DIRECTORY/gamesvr-tf2-freeplay/files";

        empty_folder "$destination_directory";

        import_github_repo "git://github.com/LacledesLAN/gamesvr-srcds-metamod.linux" "$destination_directory/tf/";

        import_github_repo "git://github.com/LacledesLAN/gamesvr-srcds-sourcemod.linux" "$destination_directory/tf/";

        import_github_repo "git://github.com/LacledesLAN/gamesvr-srcds-tf2-freeplay" "$destination_directory/";

        docker build -t ll/gamesvr-tf2-freeplay "$SCRIPT_DIRECTORY/gamesvr-tf2-freeplay/";

        gfx_section_end;

    fi;
fi;


#                       _                
#     ____    ____ _   (_)   ____    _  __
#    / __ \  / __ `/  / /   / __ \  | |/_/
#   / / / / / /_/ /  / /   / / / / _>  <  
#  /_/ /_/  \__, /  /_/   /_/ /_/ /_/|_|  
#          /____/                         
#
if [ "$MODE_DOCKER_LIBRARY" = true ] ; then
    if [ $DOCKER_REBUILD_LEVEL -le 0 ] ; then

        gfx_section_start "Pulling Docker Image -=> nginx:latest";

        echo "Pulling nginx:latest from Docker hub";

        docker pull nginx:latest;

        gfx_section_end;
    fi;
fi;


#                      __                                                         __                  __        __                
#   _      __  ___    / /_    _____ _   __   _____         _____  ____    ____   / /_  ___    ____   / /_      / /  ____ _   ____ 
#  | | /| / / / _ \  / __ \  / ___/| | / /  / ___/ ______ / ___/ / __ \  / __ \ / __/ / _ \  / __ \ / __/     / /  / __ `/  / __ \
#  | |/ |/ / /  __/ / /_/ / (__  ) | |/ /  / /    /_____// /__  / /_/ / / / / // /_  /  __/ / / / // /_   _  / /  / /_/ /  / / / /
#  |__/|__/  \___/ /_.___/ /____/  |___/  /_/            \___/  \____/ /_/ /_/ \__/  \___/ /_/ /_/ \__/  (_)/_/   \__,_/  /_/ /_/ 
#                                                                                                                                 
#
if [ "$MODE_DOCKER_LIBRARY" = true ] ; then
    if [ $DOCKER_REBUILD_LEVEL -le 3 ] ; then

        gfx_section_start "Docker -=> Building Image ll/websvr-content.lan";

        docker_remove_image "ll/websvr-content.lan";
        
        destination_directory="$SCRIPT_DIRECTORY/websvr-content.lan/files";

        empty_folder "$destination_directory";
        
        import_github_repo "git://github.com/LacledesLAN/websvr-content.lan" "$destination_directory/";

        docker build -t ll/websvr-content.lan "$SCRIPT_DIRECTORY/websvr-content.lan/";

        gfx_section_end;

    fi;
fi;




tput smul;
echo -e "\n\n\n\n\nFINISHED\n";
tput sgr0;


echo "";
echo "";
gfx_horizontal_rule;
echo "   LL Docker Image Management Tool.  Stop time: $(date)";
gfx_horizontal_rule;
echo "";

if [ "$MODE_DOCKER_LIBRARY" = true ] ; then
    echo "Here's what you've got:";
    echo "";
    docker run --rm -v /var/run/docker.sock:/var/run/docker.sock nate/dockviz images -tl
    echo "";
    echo "";
    docker images;
fi;

