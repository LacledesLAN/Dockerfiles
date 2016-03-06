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
readonly setting_contextualize_steam=true;          # If steam apps will be added via docker build context.


#=============================================================================================================
#===  RUNTIME VARIABLES  =====================================================================================
#=============================================================================================================
declare mode_docker=true;
declare mode_local=false;
declare rebuild_level=0;
declare script_skip_update=false;
declare script_skip_steam_validate=false;

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
    tput setaf 2;
    echo "--=> $1";
    tput sgr0; tput dim; tput setaf 6;

    cd `mktemp -d` && \
        git clone $1 && \
        rm -rf *.git && \
        cd `ls -A | head -1` && \
        rm -f *.md && \
        cp -r * $2;
}


function import_steam_app() {    # APP ID; destination directory
    bash "$script_directory/gamesvr/_util/steamcmd/"steamcmd.sh \
        +login anonymous \
        +force_install_dir $2 \
        +app_update $1 \
        -validate \
        +quit;
}


function import_steam_cmd() { # destination directory
    echo "";

    mkdir -p "$1";

    echo -e -n "\tChecking SteamCMD..";
    
    { bash "$1/"steamcmd.sh +quit; }  &> /dev/null;    

    if [ $? -ne 0 ] ; then
        echo -n ".downloading.."

        #failed to run SteamCMD.  Download
        {
            rm -rf "$1/*";

            wget -qO- -r --tries=10 --waitretry=20 --output-document=tmp.tar.gz http://media.steampowered.com/installer/steamcmd_linux.tar.gz;
            tar -xvzf tmp.tar.gz -C "$1/";
            rm tmp.tar.gz

            bash "$1/"steamcmd.sh +quit;
        } &> /dev/null;
    fi

    echo ".updated...done."
}


function empty_folder() {
    #Header
    tput setaf 1;
    echo "--=> Clearing directory $1 of all contents";
    tput sgr0; tput dim; tput setaf 6;
    
    rm -rf "$1/*"
}


#=============================================================================================================
#===  PROCESS LINE ARGUMENTS  ================================================================================
#=============================================================================================================
while getopts ":z" opt; do
    case $opt in
        s)
            script_skip_steam_validate=true;
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
echo "(build: $script_version)";
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


#==============
#= MENU
#==============

echo "    What do you want to rebuild?";
echo "    ";
echo "    0) Rebuild Everything";
echo "    1) Rebuild Starting with the Category Level (Level 1+)";
echo "    2) Rebuild Starting with the Apllication/Content Level (Level 2+)";
echo "    3) Rebuild Starting with the Configuration Level (Level 3)";
echo "    ";
echo "    x) Exit without doing anything";
echo "    ";

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

    gfx_section_start "nate/dockviz";

    echo "Pulling nate/dockviz:latest from Docker hub";
    echo "This image provides useful tools to analyze docker images";

    docker pull nate/dockviz:latest;

    gfx_section_end;
fi


#              __                     __         
#    __  __   / /_   __  __   ____   / /_  __  __
#   / / / /  / __ \ / / / /  / __ \ / __/ / / / /
#  / /_/ /  / /_/ // /_/ /  / / / // /_  / /_/ / 
#  \__,_/  /_.___/ \__,_/  /_/ /_/ \__/  \__,_/  
#                                                

if [ $selected_rebuild_level -le 0 ] ; then

    gfx_section_start "ubuntu:latest";

    echo "Pulling ubuntu:latest from Docker hub";

    docker pull ubuntu:latest;

    gfx_section_end;
fi


#     ____ _____ _____ ___  ___  ______   _______
#    / __ `/ __ `/ __ `__ \/ _ \/ ___/ | / / ___/
#   / /_/ / /_/ / / / / / /  __(__  )| |/ / /
#   \__, /\__,_/_/ /_/ /_/\___/____/ |___/_/
#  /____/
#

if [ $selected_rebuild_level -le 1 ] ; then

    gfx_section_start "Building ll/gamesvr";

    docker_remove_image "ll/gamesvr";

    destination_directory="$script_directory/gamesvr";

    import_steam_cmd "$destination_directory/_util/steamcmd";

    docker build -t ll/gamesvr "$script_directory/gamesvr/";

    gfx_section_end;
fi


#     ____ _____ _____ ___  ___  ______   _______      ______________ _____
#    / __ `/ __ `/ __ `__ \/ _ \/ ___/ | / / ___/_____/ ___/ ___/ __ `/ __ \
#   / /_/ / /_/ / / / / / /  __(__  )| |/ / /  /_____/ /__(__  ) /_/ / /_/ /
#   \__, /\__,_/_/ /_/ /_/\___/____/ |___/_/         \___/____/\__, /\____/
#  /____/                                                     /____/
#

if [ $selected_rebuild_level -le 2 ] ; then

    gfx_section_start "Building ll/gamesvr-csgo";

    docker_remove_image "ll/gamesvr-csgo";
    
    destination_directory="$script_directory/gamesvr-csgo";
    
    import_steam_app 740 "$destination_directory/"

    docker build -t ll/gamesvr-csgo "$destination_directory/";

    gfx_section_end;
fi


#                                                                                   ____                     __
#     ____ _____ _____ ___  ___  ______   _______      ______________ _____        / __/_______  ___  ____  / /___ ___  __
#    / __ `/ __ `/ __ `__ \/ _ \/ ___/ | / / ___/_____/ ___/ ___/ __ `/ __ \______/ /_/ ___/ _ \/ _ \/ __ \/ / __ `/ / / /
#   / /_/ / /_/ / / / / / /  __(__  )| |/ / /  /_____/ /__(__  ) /_/ / /_/ /_____/ __/ /  /  __/  __/ /_/ / / /_/ / /_/ /
#   \__, /\__,_/_/ /_/ /_/\___/____/ |___/_/         \___/____/\__, /\____/     /_/ /_/   \___/\___/ .___/_/\__,_/\__, /
#  /____/                                                     /____/                              /_/            /____/
#
if [ $selected_rebuild_level -le 3 ] ; then

    gfx_section_start "Building ll/gamesvr-csgo-freeplay";

    docker_remove_image "ll/gamesvr-csgo-freeplay";
    
    destination_directory="$script_directory/gamesvr-csgo-freeplay";

    empty_folder "$script_directory/gamesvr-csgo-freeplay";

    import_github_repo "git://github.com/LacledesLAN/gamesvr-srcds-metamod.linux" "$destination_directory/csgo/";
    
    import_github_repo "git://github.com/LacledesLAN/gamesvr-srcds-sourcemod.linux" "$destination_directory/csgo/";

    import_github_repo "git://github.com/LacledesLAN/gamesvr-srcds-csgo" "$destination_directory/";

    import_github_repo "git://github.com/LacledesLAN/gamesvr-srcds-csgo-freeplay" "$destination_directory/";

    docker build -t ll/gamesvr-csgo-freeplay "$destination_directory/";

    gfx_section_end;
fi


#                                                                                   __
#     ____ _____ _____ ___  ___  ______   _______      ______________ _____        / /_____  __  ___________  ___  __  __
#    / __ `/ __ `/ __ `__ \/ _ \/ ___/ | / / ___/_____/ ___/ ___/ __ `/ __ \______/ __/ __ \/ / / / ___/ __ \/ _ \/ / / /
#   / /_/ / /_/ / / / / / /  __(__  )| |/ / /  /_____/ /__(__  ) /_/ / /_/ /_____/ /_/ /_/ / /_/ / /  / / / /  __/ /_/ /
#   \__, /\__,_/_/ /_/ /_/\___/____/ |___/_/         \___/____/\__, /\____/      \__/\____/\__,_/_/  /_/ /_/\___/\__, /
#  /____/                                                     /____/                                            /____/
#
if [ $selected_rebuild_level -le 3 ] ; then

    gfx_section_start "Building ll/gamesvr-csgo-tourney";

    docker_remove_image "ll/gamesvr-csgo-tourney";
    
    destination_directory="$script_directory/gamesvr-csgo-tourney";
    
    empty_folder "$script_directory/gamesvr-csgo-tourney";
    
    import_github_repo "git://github.com/LacledesLAN/gamesvr-srcds-metamod.linux" "$destination_directory/csgo/";

    import_github_repo "git://github.com/LacledesLAN/gamesvr-srcds-sourcemod.linux" "$destination_directory/csgo/";

    import_github_repo "git://github.com/LacledesLAN/gamesvr-srcds-csgo" "$destination_directory/";

    import_github_repo "git://github.com/LacledesLAN/gamesvr-srcds-csgo-tourney" "$destination_directory/";

    docker build -t ll/gamesvr-csgo-tourney "$destination_directory/";

    gfx_section_end;

fi


#                                                       __    _____      __
#     ____ _____ _____ ___  ___  ______   _______      / /_  / /__ \____/ /___ ___
#    / __ `/ __ `/ __ `__ \/ _ \/ ___/ | / / ___/_____/ __ \/ /__/ / __  / __ `__ \
#   / /_/ / /_/ / / / / / /  __(__  )| |/ / /  /_____/ / / / // __/ /_/ / / / / / /
#   \__, /\__,_/_/ /_/ /_/\___/____/ |___/_/        /_/ /_/_//____|__,_/_/ /_/ /_/
#  /____/
#

if [ $selected_rebuild_level -le 2 ] ; then

    gfx_section_start "Building ll/gamesvr-hl2dm";

    docker_remove_image "ll/gamesvr-hl2dm";

    destination_directory="$script_directory/gamesvr-hl2dm";

    import_steam_app 232370 "$destination_directory/"

    docker build -t ll/gamesvr-hl2dm "$destination_directory/";

    gfx_section_end;
fi


#                                                       __    _____      __                ____                     __
#     ____ _____ _____ ___  ___  ______   _______      / /_  / /__ \____/ /___ ___        / __/_______  ___  ____  / /___ ___  __
#    / __ `/ __ `/ __ `__ \/ _ \/ ___/ | / / ___/_____/ __ \/ /__/ / __  / __ `__ \______/ /_/ ___/ _ \/ _ \/ __ \/ / __ `/ / / /
#   / /_/ / /_/ / / / / / /  __(__  )| |/ / /  /_____/ / / / // __/ /_/ / / / / / /_____/ __/ /  /  __/  __/ /_/ / / /_/ / /_/ /
#   \__, /\__,_/_/ /_/ /_/\___/____/ |___/_/        /_/ /_/_//____|__,_/_/ /_/ /_/     /_/ /_/   \___/\___/ .___/_/\__,_/\__, /
#  /____/                                                                                                /_/            /____/
#
if [ $selected_rebuild_level -le 3 ] ; then

    gfx_section_start "Building ll/gamesvr-hl2dm-freeplay";

    docker_remove_image "ll/gamesvr-hl2dm-freeplay";

    destination_directory="$script_directory/gamesvr-hl2dm-freeplay";

    empty_folder "$script_directory/gamesvr-hl2dm-freeplay";

    import_github_repo "git://github.com/LacledesLAN/gamesvr-srcds-metamod.linux" "$destination_directory/hl2mp/";

    import_github_repo "git://github.com/LacledesLAN/gamesvr-srcds-sourcemod.linux" "$destination_directory/hl2mp/";

    import_github_repo "git://github.com/LacledesLAN/gamesvr-srcds-hl2dm-freeplay" "$destination_directory/";

    docker build -t ll/gamesvr-hl2dm-freeplay "$destination_directory/";

    gfx_section_end;
fi



#    _______________
#   /_  __/ ____/__ \
#    / / / /_   __/ /
#   / / / __/  / __/
#  /_/ /_/    /____/ 
#

if [ $selected_rebuild_level -le 2 ] ; then

    gfx_section_start "Building ll/gamesvr-tf2";

    docker_remove_image "ll/gamesvr-tf2";
    
    destination_directory="$script_directory/gamesvr-tf2";
    
    import_steam_app 232250 "$destination_directory/"

    docker build -t ll/gamesvr-tf2 "$destination_directory/";

    gfx_section_end;
fi


#    _______________      ____  ___           __      ______
#   /_  __/ ____/__ \    / __ )/ (_)___  ____/ /     / ____/________ _____ _
#    / / / /_   __/ /   / __  / / / __ \/ __  /_____/ /_  / ___/ __ `/ __ `/
#   / / / __/  / __/   / /_/ / / / / / / /_/ /_____/ __/ / /  / /_/ / /_/ /
#  /_/ /_/    /____/  /_____/_/_/_/ /_/\__,_/     /_/   /_/   \__,_/\__, /                                                                  
#                                                                  /____/
#
if [ $selected_rebuild_level -le 3 ] ; then

    gfx_section_start "Building ll/gamesvr-tf2-blindfrag";

    docker_remove_image "ll/gamesvr-tf2-blindfrag";
    
    destination_directory="$script_directory/gamesvr-tf2-blindfrag";

    empty_folder "$script_directory/gamesvr-tf2-blindfrag";

    import_github_repo "git://github.com/LacledesLAN/gamesvr-srcds-metamod.linux" "$destination_directory/tf/";

    import_github_repo "git://github.com/LacledesLAN/gamesvr-srcds-sourcemod.linux" "$destination_directory/tf/";

    import_github_repo "git://github.com/LacledesLAN/gamesvr-srcds-tf2-blindfrag" "$destination_directory/";

    docker build -t ll/gamesvr-tf2-blindfrag "$destination_directory/";

    gfx_section_end;

fi


#    _______________      ______                     __
#   /_  __/ ____/__ \    / ____/_______  ___  ____  / /___ ___  __
#    / / / /_   __/ /   / /_  / ___/ _ \/ _ \/ __ \/ / __ `/ / / /
#   / / / __/  / __/   / __/ / /  /  __/  __/ /_/ / / /_/ / /_/ /
#  /_/ /_/    /____/  /_/   /_/   \___/\___/ .___/_/\__,_/\__, /
#                                         /_/            /____/

if [ $selected_rebuild_level -le 3 ] ; then

    gfx_section_start "Building ll/gamesvr-tf2-freeplay";

    docker_remove_image "ll/gamesvr-tf2-freeplay";

    destination_directory="$script_directory/gamesvr-tf2-freeplay";

    empty_folder "$script_directory/gamesvr-tf2-freeplay";

    import_github_repo "git://github.com/LacledesLAN/gamesvr-srcds-metamod.linux" "$destination_directory/tf/";

    import_github_repo "git://github.com/LacledesLAN/gamesvr-srcds-sourcemod.linux" "$destination_directory/tf/";

    import_github_repo "git://github.com/LacledesLAN/gamesvr-srcds-tf2-freeplay" "$destination_directory/";

    docker build -t ll/gamesvr-tf2-freeplay "$destination_directory/";

    gfx_section_end;

fi


#                       _                
#     ____    ____ _   (_)   ____    _  __
#    / __ \  / __ `/  / /   / __ \  | |/_/
#   / / / / / /_/ /  / /   / / / / _>  <  
#  /_/ /_/  \__, /  /_/   /_/ /_/ /_/|_|  
#          /____/                         
#
if [ $selected_rebuild_level -le 0 ] ; then

    gfx_section_start "nginx:latest";

    echo "Pulling nginx:latest from Docker hub";

    docker pull nginx:latest;

    gfx_section_end;
fi


#                      __                                                         __                  __        __                
#   _      __  ___    / /_    _____ _   __   _____         _____  ____    ____   / /_  ___    ____   / /_      / /  ____ _   ____ 
#  | | /| / / / _ \  / __ \  / ___/| | / /  / ___/ ______ / ___/ / __ \  / __ \ / __/ / _ \  / __ \ / __/     / /  / __ `/  / __ \
#  | |/ |/ / /  __/ / /_/ / (__  ) | |/ /  / /    /_____// /__  / /_/ / / / / // /_  /  __/ / / / // /_   _  / /  / /_/ /  / / / /
#  |__/|__/  \___/ /_.___/ /____/  |___/  /_/            \___/  \____/ /_/ /_/ \__/  \___/ /_/ /_/ \__/  (_)/_/   \__,_/  /_/ /_/ 
#
if [ $selected_rebuild_level -le 3 ] ; then

    gfx_section_start "Building ll/websvr-content.lan";

    docker_remove_image "ll/websvr-content.lan";

    docker build -t ll/websvr-content.lan ./websvr-content.lan/;

    gfx_section_end;

fi



tput smul;
echo -e "\n\n\n\n\nFINISHED\n";
tput sgr0;


echo "";
echo "";
gfx_horizontal_rule;
echo "   LL Docker Image Management Tool.  Stop time: $(date)";
gfx_horizontal_rule;
echo "";

echo "Here's what you've got:";
echo "";
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock nate/dockviz images -tl
echo "";
echo "";
