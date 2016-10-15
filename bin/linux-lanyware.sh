#!/bin/bash
source "$( cd "${BASH_SOURCE[0]%/*}" && pwd )/linux-functions-docker.sh";
source "$( cd "${BASH_SOURCE[0]%/*}" && pwd )/linux-functions-gfx.sh";
source "$( cd "${BASH_SOURCE[0]%/*}" && pwd )/linux-functions-git.sh";
source "$( cd "${BASH_SOURCE[0]%/*}" && pwd )/linux-functions-misc.sh";
source "$( cd "${BASH_SOURCE[0]%/*}" && pwd )/linux-functions-steam.sh";
#=============================================================================================================
#
#   FILE:   forge.sh
#
#   LINE ARUGMENTS:
#                   -s      Skip steamcmd validation of installed applications
#
#   DESCRIPTION:    Maintain the ll Docker Image repository by building (and rebuilding) Docker images from
#                   origin repositories and sources.
#
#=============================================================================================================

#=============================================================================================================
#===  SETTINGS  ==============================================================================================
#=============================================================================================================
declare LANYWARE_LOGGING_ENABLED=true;


#=============================================================================================================
#===  RUNTIME VARIABLES  =====================================================================================
#=============================================================================================================
declare MODE_DOCKER_LIBRARY=false;
declare MODE_LOCAL_SERVER=false;

declare DOCKER_REBUILD_LEVEL="";

readonly LANYWARE_BIN_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";

readonly LANYWARE_CACHE_PATH=$(realpath "$LANYWARE_BIN_PATH/../cache");
mkdir "$LANYWARE_CACHE_PATH" --parents;

readonly LANYWARE_REPO_PATH=$(realpath "$LANYWARE_BIN_PATH/../repos");
mkdir "$LANYWARE_REPO_PATH" --parents;

if [[ "$LANYWARE_LOGGING_ENABLED" = true ]] ; then
    declare LOGPATH=$(realpath "$LANYWARE_BIN_PATH/../logs");
    readonly LANYWARE_LOGFILE=$(date +"$LOGPATH/linux-%Y.%m.%d-%Hh%Mm%Ss.log");

    mkdir "$LOGPATH" --parents;
    touch $LANYWARE_LOGFILE;
    unset LOGPATH;
else
    readonly LANYWARE_LOGFILE=$(mktemp);
fi

declare -a LANYWARE_GITHUB_IMPORT_HISTORY;
LANYWARE_GITHUB_IMPORT_HISTORY[0]="Array created at $(date)";

declare DOCKER_INSTALLED=true;
command -v docker > /dev/null 2>&1 || { DOCKER_INSTALLED=false; }


#=============================================================================================================
#===  RUNTIME FUNCTIONS  =====================================================================================
#=============================================================================================================
function empty_folder() {
    #Header
    tput setaf 6;
    echo "Clearing folder of all contents";
    echo -e "\t[Target] $1";

    #make sure target folder exists
    mkdir -p "$1";

    find "$1/" -mindepth 1 -delete;

    echo -e "\n";
}


function wget_wrapper() {
    # This simple wget wrapper wraps expects the "--no-verbose" argument
    # The goal is to keep providing updates to the terminal while greatly reducing scroll and log everything in the log file
    script -q --command "$1" | while IFS= read line
        do
            if [[ $line = *".listing\" ["* ]] ; then
                #do nothing; don't show "downloaded" .listing files
                echo -n "";
            elif [[ $line == *"-"*"-"*" "*":"*":"*"URL:"*"["*"] -> "* ]] ; then
                #print only the downloaded file name
                echo -en "\e[0K\r\tdownloaded: $(echo "$line" | sed -n -e 's/^.*-> //p')";
            else
                echo $line;
            fi

            if [[ "$LANYWARE_LOGGING_ENABLED" = true ]] ; then
                echo -e "\t$(date)\t$line" >> $LANYWARE_LOGFILE;
            fi
        done
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
    tput dim;
    echo "      (if new installation select 0)";
    tput sgr0;
    echo "    ";
    echo "    0) Update/Re-Pull base images from hub.docker.com";
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
            gfx_allthethings;
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
    echo "   | |__/ _ \/ _/ _\`| | \__ \/ -_) '_\ V / -_) '_|";
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


##############################################################################################################
####======================================================================================================####
####  SHEll SCRIPT RUNTIME  ==============================================================================####
####======================================================================================================####
##############################################################################################################

# Display version
{
    git status;
} &> /dev/null;
if [ $? -ne 0 ]; then
    declare SCRIPT_FILENAME="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")";
    declare SCRIPT_FUllPATH=$(realpath "$LANYWARE_BIN_PATH/$SCRIPT_FILENAME");
    declare SCRIPT_VERSION=$(stat -c %y "$SCRIPT_FUllPATH");

    unset SCRIPT_FILENAME; unset SCRIPT_FUllPATH;
else
    declare SCRIPT_VERSION=$(git rev-parse --verify HEAD);
fi


echo -e "\n\n\n";
gfx_section_start "LANYWARE (build: $SCRIPT_VERSION)";
tput sgr0;

echo -e "\n" | tee -a "$LANYWARE_LOGFILE";


tput setaf 3; tput bold;
echo "    ██╗      █████╗ ███╗   ██╗██╗   ██╗██╗    ██╗ █████╗ ██████╗ ███████╗ ";
echo "    ██║     ██╔══██╗████╗  ██║╚██╗ ██╔╝██║    ██║██╔══██╗██╔══██╗██╔════╝ ";
echo "    ██║     ███████║██╔██╗ ██║ ╚████╔╝ ██║ █╗ ██║███████║██████╔╝█████╗   ";
echo "    ██║     ██╔══██║██║╚██╗██║  ╚██╔╝  ██║███╗██║██╔══██║██╔══██╗██╔══╝   ";
echo "    ███████╗██║  ██║██║ ╚████║   ██║   ╚███╔███╔╝██║  ██║██║  ██║███████╗ ";
echo "    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝    ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝ ";
tput sgr0; tput dim; tput setaf 6;
echo "                    LAN Party Servers. Anytime. Anywhere.                 ";
echo -e "\n";
tput sgr0;



if [ "$DOCKER_INSTALLED" = true ] ; then
    echo "    What are we managing?";
    echo "    ";
    echo "    D) Docker image library";
    echo "    V) Development Mode (coming soon)";
    echo "    L) Game Server on localhost (coming eventually)";
    echo "    ";
    echo "    X) Exit without doing anything";
    echo "    ";

    until [ "$MODE_DOCKER_LIBRARY" != "$MODE_LOCAL_SERVER" ]; do
        read -n 1 x; while read -n 1 -t .1 y; do x="$x$y"; done

        if [[ $x == "d" || $x == "D" ]] ; then
            MODE_DOCKER_LIBRARY=true;
            menu_docker_library;
        elif [[ $x == "l" || $x == "L" ]] ; then
            MODE_LOCAL_SERVER=true;
            menu_local_server;
        elif [[ $x == "x" || $x == "X" ]] ; then
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

import_steamcmd "$LANYWARE_BIN_PATH/linux-steamcmd";

#=========[ Prep Steam contextualization requirements ]-------------------------------------------------------

tput smul;
echo -e "\nDOCKER CLEAN UP";
tput sgr0;

tput smul; echo -e "\nREBUILDING IMAGES"; tput sgr0;


#         __              __           _
#    ____/ /____   _____ / /__ _   __ (_)____
#   / __  // __ \ / ___// //_/| | / // //_  /
#  / /_/ // /_/ // /__ / ,<   | |/ // /  / /_
#  \__,_/ \____/ \___//_/|_|  |___//_/  /___/
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


#            __                          __
#    __  __ / /_   __  __ ____   __  __ / /_ __  __
#   / / / // __ \ / / / // __ \ / / / // __// / / /
#  / /_/ // /_/ // /_/ // / / // /_/ // /_ / /_/ /
#  \__,_//_.___/ \__,_//_/ /_/ \__,_/ \__/ \__,_/
#
if [ "$MODE_DOCKER_LIBRARY" = true ] ; then
    if [ $DOCKER_REBUILD_LEVEL -le 0 ] ; then

        gfx_section_start "Docker -=> Pulling Image ubuntu:latest";

        echo "Pulling ubuntu:latest from Docker hub";

        docker pull ubuntu:latest;

        gfx_section_end;
    fi;
fi;


#                                                             _
#     ____ _ ____ _ ____ ___   ___   _____ _   __ _____ _    (_)____ _ _   __ ____ _
#    / __ `// __ `// __ `__ \ / _ \ / ___/| | / // ___/(_)  / // __ `/| | / // __ `/
#   / /_/ // /_/ // / / / / //  __/(__  ) | |/ // /   _    / // /_/ / | |/ // /_/ /
#   \__, / \__,_//_/ /_/ /_/ \___//____/  |___//_/   (_)__/ / \__,_/  |___/ \__,_/
#  /____/                                              /___/
if [ "$MODE_DOCKER_LIBRARY" = true ] ; then
    if [ $DOCKER_REBUILD_LEVEL -le 1 ] ; then

        gfx_section_start "Docker -=> Building Image ll/gamesvr:java";

        remove_docker_image "ll/gamesvr:java";

        destination_directory="$LANYWARE_REPO_PATH/ll/gamesvr_java/linux/files";

        mkdir "$destination_directory" --parents;

        docker build -t ll/gamesvr:java "$LANYWARE_REPO_PATH/ll/gamesvr_java/linux/";

        gfx_section_end;
    fi;
fi;


#                                                                 __                                                __
#     ____ _ ____ _ ____ ___   ___   _____ _   __ _____ _  _____ / /_ ___   ____ _ ____ ___   _____ ____ ___   ____/ /
#    / __ `// __ `// __ `__ \ / _ \ / ___/| | / // ___/(_)/ ___// __// _ \ / __ `// __ `__ \ / ___// __ `__ \ / __  /
#   / /_/ // /_/ // / / / / //  __/(__  ) | |/ // /   _  (__  )/ /_ /  __// /_/ // / / / / // /__ / / / / / // /_/ /
#   \__, / \__,_//_/ /_/ /_/ \___//____/  |___//_/   (_)/____/ \__/ \___/ \__,_//_/ /_/ /_/ \___//_/ /_/ /_/ \__,_/
#  /____/
if [ "$MODE_DOCKER_LIBRARY" = true ] ; then
    if [ $DOCKER_REBUILD_LEVEL -le 1 ] ; then

        gfx_section_start "Docker -=> Building Image ll/gamesvr:steamdcmd";

        remove_docker_image "ll/gamesvr:steamcmd";

        destination_directory="$LANYWARE_REPO_PATH/ll/gamesvr_steamcmd/linux/files";

        mkdir "$destination_directory" --parents;

        import_steamcmd "$destination_directory/_steamcmd";

        docker build -t ll/gamesvr:steamcmd "$LANYWARE_REPO_PATH/ll/gamesvr_steamcmd/linux/";

        gfx_section_end;
    fi;
fi;


#                                                               __     __              __
#     ____ _ ____ _ ____ ___   ___   _____ _   __ _____        / /_   / /____ _ _____ / /__ ____ ___   ___   _____ ____ _
#    / __ `// __ `// __ `__ \ / _ \ / ___/| | / // ___/______ / __ \ / // __ `// ___// //_// __ `__ \ / _ \ / ___// __ `/
#   / /_/ // /_/ // / / / / //  __/(__  ) | |/ // /   /_____// /_/ // // /_/ // /__ / ,<  / / / / / //  __/(__  )/ /_/ /
#   \__, / \__,_//_/ /_/ /_/ \___//____/  |___//_/          /_.___//_/ \__,_/ \___//_/|_|/_/ /_/ /_/ \___//____/ \__,_/
#  /____/
if [ "$MODE_DOCKER_LIBRARY" = true ] ; then
    if [ $DOCKER_REBUILD_LEVEL -le 2 ] ; then

        #gfx_section_start "Docker -=> Building Image ll/gamesvr-blackmesa";

        #remove_docker_image "ll/gamesvr-blackmesa";

        destination_directory="$LANYWARE_REPO_PATH/ll/gamesvr-blackmesa/files";

        #mkdir "$destination_directory" --parents;

        #import_steam_app 346680 "$destination_directory";

        #docker build -t ll/gamesvr-blackmesa -f "$LANYWARE_REPO_PATH/ll/gamesvr-blackmesa/Dockerfile.linux" "$LANYWARE_REPO_PATH/ll/gamesvr-blackmesa/";

        #gfx_section_end;
    fi;
fi;


#                                                               __     __              __                                         ____                          __
#     ____ _ ____ _ ____ ___   ___   _____ _   __ _____        / /_   / /____ _ _____ / /__ ____ ___   ___   _____ ____ _        / __/_____ ___   ___   ____   / /____ _ __  __
#    / __ `// __ `// __ `__ \ / _ \ / ___/| | / // ___/______ / __ \ / // __ `// ___// //_// __ `__ \ / _ \ / ___// __ `/______ / /_ / ___// _ \ / _ \ / __ \ / // __ `// / / /
#   / /_/ // /_/ // / / / / //  __/(__  ) | |/ // /   /_____// /_/ // // /_/ // /__ / ,<  / / / / / //  __/(__  )/ /_/ //_____// __// /   /  __//  __// /_/ // // /_/ // /_/ /
#   \__, / \__,_//_/ /_/ /_/ \___//____/  |___//_/          /_.___//_/ \__,_/ \___//_/|_|/_/ /_/ /_/ \___//____/ \__,_/       /_/  /_/    \___/ \___// .___//_/ \__,_/ \__, /
#  /____/                                                                                                                                           /_/               /____/
if [ "$MODE_DOCKER_LIBRARY" = true ] ; then
    if [ $DOCKER_REBUILD_LEVEL -le 3 ] ; then

        #gfx_section_start "Docker -=> Building Image ll/gamesvr-blackmesa-freeplay";

        #remove_docker_image "ll/gamesvr-blackmesa-freeplay";

        destination_directory="$LANYWARE_REPO_PATH/ll/gamesvr-blackmesa-freeplay/linux/files";

        #mkdir "$destination_directory" --parents;

        #empty_folder "$destination_directory";

        #import_github_repo "LacledesLAN/gamesvr-srcds-metamod.linux" "$destination_directory/bms/";

        #import_github_repo "LacledesLAN/gamesvr-srcds-sourcemod.linux" "$destination_directory/bms/";

        #import_github_repo "LacledesLAN/gamesvr-srcds-blackmesa-freeplay" "$destination_directory/";

        #docker build -t ll/gamesvr-blackmesa-freeplay "$LANYWARE_REPO_PATH/ll/gamesvr-blackmesa-freeplay/linux/";

        #gfx_section_end;
    fi;
fi;


#     ____ _ ____ _ ____ ___   ___   _____ _   __ _____        _____ _____ _____ ____   __  __ _____ _____ ___
#    / __ `// __ `// __ `__ \ / _ \ / ___/| | / // ___/______ / ___// ___// ___// __ \ / / / // ___// ___// _ \
#   / /_/ // /_/ // / / / / //  __/(__  ) | |/ // /   /_____// /__ (__  )(__  )/ /_/ // /_/ // /   / /__ /  __/
#   \__, / \__,_//_/ /_/ /_/ \___//____/  |___//_/           \___//____//____/ \____/ \__,_//_/    \___/ \___/
#  /____/
if [ "$MODE_DOCKER_LIBRARY" = true ] ; then
    if [ $DOCKER_REBUILD_LEVEL -le 2 ] ; then

        #gfx_section_start "Docker -=> Building Image ll/gamesvr-cssource";

        #remove_docker_image "ll/gamesvr-cssource";

        destination_directory="$LANYWARE_REPO_PATH/ll/gamesvr-cssource";

        #mkdir "$destination_directory" --parents;

        #import_steam_app 232330 "$destination_directory/files";

        #docker build -t ll/gamesvr-cssource -f "$LANYWARE_REPO_PATH/ll/gamesvr-cssource/Dockerfile.linux" "$LANYWARE_REPO_PATH/ll/gamesvr-cssource/";

        #gfx_section_end;
    fi;
fi;


#     ____ _____ _____ ___  ___  ______   _______      ______________ _____
#    / __ `/ __ `/ __ `__ \/ _ \/ ___/ | / / ___/_____/ ___/ ___/ __ `/ __ \
#   / /_/ / /_/ / / / / / /  __(__  )| |/ / /  /_____/ /__(__  ) /_/ / /_/ /
#   \__, /\__,_/_/ /_/ /_/\___/____/ |___/_/         \___/____/\__, /\____/
#  /____/                                                     /____/
if [ "$MODE_DOCKER_LIBRARY" = true ] ; then
    if [ $DOCKER_REBUILD_LEVEL -le 2 ] ; then

        gfx_section_start "Docker -=> Building Image ll/gamesvr-csgo";

        remove_docker_image "ll/gamesvr-csgo";

        destination_directory="$LANYWARE_REPO_PATH/ll/gamesvr-csgo/files";

        mkdir "$destination_directory" --parents;

        ############ FTP STUFF ############

        # Clear destination to ensure no unintended maps are left.  Eg, if the map is deleted from the repo it should be deleted
        # from the built server
        empty_folder "$destination_directory/csgo/maps";

        # Download all half-life 2 deathmatch maps from the ll repo
        wget_wrapper "wget -m \
            -P $destination_directory/csgo/maps/ \
            ftp://guest:m5lyeREIDy0Zvr2o5wAq@files.lacledeslan.net/content.lan/fastDownloads/csgo/maps \
            -nH --no-verbose --cut-dirs 4";

        # Unzip all bz2 files; extracting the maps and deleting the archives
        echo "bzip2 -f -d $destination_directory/csgo/maps/*.bsp.bz2";

        bzip2 -d $destination_directory/csgo/maps/*.bsp.bz2;

        # Remove .listing file
        rm "$destination_directory/csgo/maps/.listing";

        ############ END OF FTP STUFF ############

        import_steam_app 740 "$destination_directory/files";

        docker build -t ll/gamesvr-csgo -f "$LANYWARE_REPO_PATH/ll/gamesvr-csgo/Dockerfile.linux" "$LANYWARE_REPO_PATH/ll/gamesvr-csgo/";

        gfx_section_end;
    fi;
fi;


#                                                                                                    __                        __                   __
#     ____ _ ____ _ ____ ___   ___   _____ _   __ _____        _____ _____ ____ _ ____          ____/ /____  _      __ ____   / /____   ____ _ ____/ /
#    / __ `// __ `// __ `__ \ / _ \ / ___/| | / // ___/______ / ___// ___// __ `// __ \ ______ / __  // __ \| | /| / // __ \ / // __ \ / __ `// __  /
#   / /_/ // /_/ // / / / / //  __/(__  ) | |/ // /   /_____// /__ (__  )/ /_/ // /_/ //_____// /_/ // /_/ /| |/ |/ // / / // // /_/ // /_/ // /_/ /
#   \__, / \__,_//_/ /_/ /_/ \___//____/  |___//_/           \___//____/ \__, / \____/        \__,_/ \____/ |__/|__//_/ /_//_/ \____/ \__,_/ \__,_/
#  /____/                                                               /____/
if [ "$MODE_DOCKER_LIBRARY" = true ] ; then
    if [ $DOCKER_REBUILD_LEVEL -le 3 ] ; then

        #gfx_section_start "Docker -=> Building Image ll/gamesvr-csgo-download";

        #remove_docker_image "ll/gamesvr-csgo-download";

        destination_directory="$LANYWARE_REPO_PATH/ll/gamesvr-csgo-download/files";

        #mkdir "$destination_directory" --parents;

        #empty_folder "$destination_directory";

        #import_github_repo "LacledesLAN/gamesvr-srcds-csgo-download" "$destination_directory/csgo/";

        #docker build -t ll/gamesvr-csgo-download -f "$LANYWARE_REPO_PATH/ll/gamesvr-csgo-download/Dockerfile.linux" "$LANYWARE_REPO_PATH/ll/gamesvr-csgo-download/";

        #gfx_section_end;

    fi;
fi;


#                                                                                   ____                     __
#     ____ _____ _____ ___  ___  ______   _______      ______________ _____        / __/_______  ___  ____  / /___ ___  __
#    / __ `/ __ `/ __ `__ \/ _ \/ ___/ | / / ___/_____/ ___/ ___/ __ `/ __ \______/ /_/ ___/ _ \/ _ \/ __ \/ / __ `/ / / /
#   / /_/ / /_/ / / / / / /  __(__  )| |/ / /  /_____/ /__(__  ) /_/ / /_/ /_____/ __/ /  /  __/  __/ /_/ / / /_/ / /_/ /
#   \__, /\__,_/_/ /_/ /_/\___/____/ |___/_/         \___/____/\__, /\____/     /_/ /_/   \___/\___/ .___/_/\__,_/\__, /
#  /____/                                                     /____/                              /_/            /____/
if [ "$MODE_DOCKER_LIBRARY" = true ] ; then
    if [ $DOCKER_REBUILD_LEVEL -le 3 ] ; then

        gfx_section_start "Docker -=> Building Image ll/gamesvr-csgo-freeplay";

        remove_docker_image "ll/gamesvr-csgo-freeplay";

        destination_directory="$LANYWARE_REPO_PATH/ll/gamesvr-csgo-freeplay/linux/files";

        mkdir "$destination_directory" --parents;

        empty_folder "$destination_directory";

        import_github_repo "LacledesLAN/gamesvr-srcds-metamod.linux" "$destination_directory/csgo/";

        import_github_repo "LacledesLAN/gamesvr-srcds-sourcemod.linux" "$destination_directory/csgo/";

        import_github_repo "LacledesLAN/gamesvr-srcds-csgo" "$destination_directory/";

        import_github_repo "LacledesLAN/gamesvr-srcds-csgo-freeplay" "$destination_directory/";

        docker build -t ll/gamesvr-csgo-freeplay "$LANYWARE_REPO_PATH/ll/gamesvr-csgo-freeplay/linux/";

        gfx_section_end;
    fi;
fi;


#                                                                                                __               __
#     ____ _ ____ _ ____ ___   ___   _____ _   __ _____        _____ _____ ____ _ ____          / /_ ___   _____ / /_
#    / __ `// __ `// __ `__ \ / _ \ / ___/| | / // ___/______ / ___// ___// __ `// __ \ ______ / __// _ \ / ___// __/
#   / /_/ // /_/ // / / / / //  __/(__  ) | |/ // /   /_____// /__ (__  )/ /_/ // /_/ //_____// /_ /  __/(__  )/ /_
#   \__, / \__,_//_/ /_/ /_/ \___//____/  |___//_/           \___//____/ \__, / \____/        \__/ \___//____/ \__/
#  /____/                                                               /____/
if [ "$MODE_DOCKER_LIBRARY" = true ] ; then
    if [ $DOCKER_REBUILD_LEVEL -le 3 ] ; then

        gfx_section_start "Docker -=> Building Image ll/gamesvr-csgo-test";

        remove_docker_image "ll/gamesvr-csgo-test";

        destination_directory="$LANYWARE_REPO_PATH/ll/gamesvr-csgo-test/linux/files";

        mkdir "$destination_directory" --parents;

        empty_folder "$destination_directory";

        import_github_repo "LacledesLAN/LacledesLAN/gamesvr-srcds-csgo-test" "$destination_directory/csgo/";

        docker build -t ll/gamesvr-csgo-test "$LANYWARE_REPO_PATH/ll/gamesvr-csgo-test/linux/";

        gfx_section_end;

    fi;
fi;


#                                                                                   __
#     ____ _____ _____ ___  ___  ______   _______      ______________ _____        / /_____  __  ___________  ___  __  __
#    / __ `/ __ `/ __ `__ \/ _ \/ ___/ | / / ___/_____/ ___/ ___/ __ `/ __ \______/ __/ __ \/ / / / ___/ __ \/ _ \/ / / /
#   / /_/ / /_/ / / / / / /  __(__  )| |/ / /  /_____/ /__(__  ) /_/ / /_/ /_____/ /_/ /_/ / /_/ / /  / / / /  __/ /_/ /
#   \__, /\__,_/_/ /_/ /_/\___/____/ |___/_/         \___/____/\__, /\____/      \__/\____/\__,_/_/  /_/ /_/\___/\__, /
#  /____/                                                     /____/                                            /____/
if [ "$MODE_DOCKER_LIBRARY" = true ] ; then
    if [ $DOCKER_REBUILD_LEVEL -le 3 ] ; then

        gfx_section_start "Docker -=> Building Image ll/gamesvr-csgo-tourney";

        remove_docker_image "ll/gamesvr-csgo-tourney";

        destination_directory="$LANYWARE_REPO_PATH/ll/gamesvr-csgo-tourney/linux/files";

        mkdir "$destination_directory" --parents;

        empty_folder "$destination_directory";

        import_github_repo "LacledesLAN/gamesvr-srcds-metamod.linux" "$destination_directory/csgo/";

        import_github_repo "LacledesLAN/gamesvr-srcds-sourcemod.linux" "$destination_directory/csgo/";

        import_github_repo "LacledesLAN/gamesvr-srcds-csgo" "$destination_directory/";

        import_github_repo "LacledesLAN/gamesvr-srcds-csgo-tourney" "$destination_directory/";

        docker build -t ll/gamesvr-csgo-tourney "$LANYWARE_REPO_PATH/ll/gamesvr-csgo-tourney/linux/";

        gfx_section_end;

    fi;
fi;


#                                                                   __            __
#     ____ _ ____ _ ____ ___   ___   _____ _   __ _____        ____/ /____   ____/ /_____
#    / __ `// __ `// __ `__ \ / _ \ / ___/| | / // ___/______ / __  // __ \ / __  // ___/
#   / /_/ // /_/ // / / / / //  __/(__  ) | |/ // /   /_____// /_/ // /_/ // /_/ /(__  )
#   \__, / \__,_//_/ /_/ /_/ \___//____/  |___//_/           \__,_/ \____/ \__,_//____/
#  /____/
if [ "$MODE_DOCKER_LIBRARY" = true ] ; then
    if [ $DOCKER_REBUILD_LEVEL -le 2 ] ; then

        #gfx_section_start "Docker -=> Building Image ll/gamesvr-dods";

        #remove_docker_image "ll/gamesvr-dods";

        destination_directory="$LANYWARE_REPO_PATH/ll/gamesvr-dods/files";

        #mkdir "$destination_directory" --parents;

        #import_steam_app 232290 "$destination_directory";

        #docker build -t ll/gamesvr-dods -f "$LANYWARE_REPO_PATH/ll/gamesvr-dods/Dockerfile.linux" "$LANYWARE_REPO_PATH/ll/gamesvr-dods/";

        #gfx_section_end;
    fi;
fi;


#                                                                   __            __              ____                          __
#     ____ _ ____ _ ____ ___   ___   _____ _   __ _____        ____/ /____   ____/ /_____        / __/_____ ___   ___   ____   / /____ _ __  __
#    / __ `// __ `// __ `__ \ / _ \ / ___/| | / // ___/______ / __  // __ \ / __  // ___/______ / /_ / ___// _ \ / _ \ / __ \ / // __ `// / / /
#   / /_/ // /_/ // / / / / //  __/(__  ) | |/ // /   /_____// /_/ // /_/ // /_/ /(__  )/_____// __// /   /  __//  __// /_/ // // /_/ // /_/ /
#   \__, / \__,_//_/ /_/ /_/ \___//____/  |___//_/           \__,_/ \____/ \__,_//____/       /_/  /_/    \___/ \___// .___//_/ \__,_/ \__, /
#  /____/                                                                                                           /_/               /____/
if [ "$MODE_DOCKER_LIBRARY" = true ] ; then
    if [ $DOCKER_REBUILD_LEVEL -le 3 ] ; then

        #gfx_section_start "Docker -=> Building Image ll/gamesvr-dods-freeplay";

        #remove_docker_image "ll/gamesvr-dods-freeplay";

        destination_directory="$LANYWARE_REPO_PATH/ll/gamesvr-dods-freeplay/linux/files";

        #mkdir "$destination_directory" --parents;

        #empty_folder "$destination_directory";

        #import_github_repo "LacledesLAN/gamesvr-srcds-metamod.linux" "$destination_directory/dod/";

        #import_github_repo "LacledesLAN/gamesvr-srcds-sourcemod.linux" "$destination_directory/dod/";

        #import_github_repo "LacledesLAN/gamesvr-srcds-dods-freeplay" "$destination_directory/";

        #docker build -t ll/gamesvr-dods-freeplay "$LANYWARE_REPO_PATH/ll/gamesvr-dods-freeplay/linux/";

        #gfx_section_end;
    fi;
fi;


#                                                       __    _____      __
#     ____ _____ _____ ___  ___  ______   _______      / /_  / /__ \____/ /___ ___
#    / __ `/ __ `/ __ `__ \/ _ \/ ___/ | / / ___/_____/ __ \/ /__/ / __  / __ `__ \
#   / /_/ / /_/ / / / / / /  __(__  )| |/ / /  /_____/ / / / // __/ /_/ / / / / / /
#   \__, /\__,_/_/ /_/ /_/\___/____/ |___/_/        /_/ /_/_//____|__,_/_/ /_/ /_/
#  /____/
if [ "$MODE_DOCKER_LIBRARY" = true ] ; then
    if [ $DOCKER_REBUILD_LEVEL -le 2 ] ; then

        gfx_section_start "Docker -=> Building Image ll/gamesvr-hl2dm";

        remove_docker_image "ll/gamesvr-hl2dm";

        destination_directory="$LANYWARE_REPO_PATH/ll/gamesvr-hl2dm/files";

        mkdir "$destination_directory" --parents;

        ############ FTP STUFF ############

        # Clear destination to ensure no unintended maps are left.  Eg, if the map is deleted from the repo it should be deleted
        # from the built server
        empty_folder "$destination_directory/hl2mp/maps";

        # Download all half-life 2 deathmatch maps from the ll repo
        wget_wrapper "wget -m \
            -P $destination_directory/hl2mp/maps/ \
            ftp://guest:m5lyeREIDy0Zvr2o5wAq@files.lacledeslan.net/content.lan/fastDownloads/hl2dm/maps \
            -nH --no-verbose --cut-dirs 4";

        # Unzip all bz2 files; extracting the maps and deleting the archives
        echo "bzip2 -f -d $destination_directory/hl2mp/maps/*.bsp.bz2";

        bzip2 -d $destination_directory/hl2mp/maps/*.bsp.bz2;

        # Remove .listing file
        rm "$destination_directory/hl2mp/maps/.listing";

        ############ END OF FTP STUFF ############

        import_steam_app 232370 "$destination_directory/";

        docker build -t ll/gamesvr-hl2dm -f "$LANYWARE_REPO_PATH/ll/gamesvr-hl2dm/Dockerfile.linux" "$LANYWARE_REPO_PATH/ll/gamesvr-hl2dm/";

        gfx_section_end;
    fi;
fi;


#                                                               __     __ ___       __                   ____                          __
#     ____ _ ____ _ ____ ___   ___   _____ _   __ _____        / /_   / /|__ \ ____/ /____ ___          / __/_____ ___   ___   ____   / /____ _ __  __
#    / __ `// __ `// __ `__ \ / _ \ / ___/| | / // ___/______ / __ \ / / __/ // __  // __ `__ \ ______ / /_ / ___// _ \ / _ \ / __ \ / // __ `// / / /
#   / /_/ // /_/ // / / / / //  __/(__  ) | |/ // /   /_____// / / // / / __// /_/ // / / / / //_____// __// /   /  __//  __// /_/ // // /_/ // /_/ /
#   \__, / \__,_//_/ /_/ /_/ \___//____/  |___//_/          /_/ /_//_/ /____/\__,_//_/ /_/ /_/       /_/  /_/    \___/ \___// .___//_/ \__,_/ \__, /
#  /____/                                                                                                                  /_/               /____/
if [ "$MODE_DOCKER_LIBRARY" = true ] ; then
    if [ $DOCKER_REBUILD_LEVEL -le 3 ] ; then

        gfx_section_start "Docker -=> Building Image ll/gamesvr-hl2dm-freeplay";

        remove_docker_image "ll/gamesvr-hl2dm-freeplay";

        destination_directory="$LANYWARE_REPO_PATH/ll/gamesvr-hl2dm-freeplay/linux/files";

        mkdir "$destination_directory" --parents;

        empty_folder "$destination_directory";

        import_github_repo "LacledesLAN/gamesvr-srcds-metamod.linux" "$destination_directory/hl2mp/";

        import_github_repo "LacledesLAN/gamesvr-srcds-sourcemod.linux" "$destination_directory/hl2mp/";

        import_github_repo "LacledesLAN/gamesvr-srcds-hl2dm-freeplay" "$destination_directory/";

        docker build -t ll/gamesvr-hl2dm-freeplay "$LANYWARE_REPO_PATH/ll/gamesvr-hl2dm-freeplay/linux/";

        gfx_section_end;
    fi;
fi;


#                                                                                                                            __
#     ____ _ ____ _ ____ ___   ___   _____ _   __ _____        ____ _ ____ _ _____ _____ __  __ _____ ____ ___   ____   ____/ /
#    / __ `// __ `// __ `__ \ / _ \ / ___/| | / // ___/______ / __ `// __ `// ___// ___// / / // ___// __ `__ \ / __ \ / __  /
#   / /_/ // /_/ // / / / / //  __/(__  ) | |/ // /   /_____// /_/ // /_/ // /   / /   / /_/ /(__  )/ / / / / // /_/ // /_/ /
#   \__, / \__,_//_/ /_/ /_/ \___//____/  |___//_/           \__, / \__,_//_/   /_/    \__, //____//_/ /_/ /_/ \____/ \__,_/
#  /____/                                                   /____/                    /____/
if [ "$MODE_DOCKER_LIBRARY" = true ] ; then
    if [ $DOCKER_REBUILD_LEVEL -le 2 ] ; then

        #gfx_section_start "Docker -=> Building Image ll/gamesvr-garrysmod";

        #remove_docker_image "ll/gamesvr-garrysmod";

        destination_directory="$LANYWARE_REPO_PATH/ll/gamesvr-garrysmod/files";

        #import_steam_app 4020 "$destination_directory";

        #docker build -t ll/gamesvr-garrysmod -f "$LANYWARE_REPO_PATH/ll/gamesvr-garrysmod/Dockerfile.linux" "$LANYWARE_REPO_PATH/ll/gamesvr-garrysmod/";

        #gfx_section_end;
    fi;
fi;


#                                                                                                                            __        ____                          __
#     ____ _ ____ _ ____ ___   ___   _____ _   __ _____        ____ _ ____ _ _____ _____ __  __ _____ ____ ___   ____   ____/ /       / __/_____ ___   ___   ____   / /____ _ __  __
#    / __ `// __ `// __ `__ \ / _ \ / ___/| | / // ___/______ / __ `// __ `// ___// ___// / / // ___// __ `__ \ / __ \ / __  /______ / /_ / ___// _ \ / _ \ / __ \ / // __ `// / / /
#   / /_/ // /_/ // / / / / //  __/(__  ) | |/ // /   /_____// /_/ // /_/ // /   / /   / /_/ /(__  )/ / / / / // /_/ // /_/ //_____// __// /   /  __//  __// /_/ // // /_/ // /_/ /
#   \__, / \__,_//_/ /_/ /_/ \___//____/  |___//_/           \__, / \__,_//_/   /_/    \__, //____//_/ /_/ /_/ \____/ \__,_/       /_/  /_/    \___/ \___// .___//_/ \__,_/ \__, /
#  /____/                                                   /____/                    /____/                                                             /_/               /____/
if [ "$MODE_DOCKER_LIBRARY" = true ] ; then
    if [ $DOCKER_REBUILD_LEVEL -le 3 ] ; then

        #gfx_section_start "Docker -=> Building Image ll/gamesvr-garrysmod-freeplay";

        #remove_docker_image "ll/gamesvr-garrysmod-freeplay";

        destination_directory="$LANYWARE_REPO_PATH/ll/gamesvr-garrysmod-freeplay/files";

        #mkdir "$destination_directory" --parents;

        #empty_folder "$destination_directory";

        #import_github_repo "LacledesLAN/gamesvr-srcds-garrysmod-freeplay" "$destination_directory/garrysmod";

        #docker build -t ll/gamesvr-garrysmod-freeplay -f "$LANYWARE_REPO_PATH/ll/gamesvr-garrysmod-freeplay/Dockerfile.linux" "$LANYWARE_REPO_PATH/ll/gamesvr-garrysmod-freeplay/";

        #gfx_section_end;

    fi;
fi;


#                                                                          _                                  ____ __
#     ____ _ ____ _ ____ ___   ___   _____ _   __ _____        ____ ___   (_)____   ___   _____ _____ ____ _ / __// /_
#    / __ `// __ `// __ `__ \ / _ \ / ___/| | / // ___/______ / __ `__ \ / // __ \ / _ \ / ___// ___// __ `// /_ / __/
#   / /_/ // /_/ // / / / / //  __/(__  ) | |/ // /   /_____// / / / / // // / / //  __// /__ / /   / /_/ // __// /_
#   \__, / \__,_//_/ /_/ /_/ \___//____/  |___//_/          /_/ /_/ /_//_//_/ /_/ \___/ \___//_/    \__,_//_/   \__/
#  /____/
if [ "$MODE_DOCKER_LIBRARY" = true ] ; then
    if [ $DOCKER_REBUILD_LEVEL -le 2 ] ; then

        #gfx_section_start "Docker -=> Building Image ll/gamesvr-minecraft";

        #remove_docker_image "ll/gamesvr-minecraft";

        destination_directory="$LANYWARE_REPO_PATH/ll/gamesvr-minecraft/files";

        #mkdir "$destination_directory" --parents;

        #empty_folder "$destination_directory";

        # Download Minecraft
        #curl https://s3.amazonaws.com/Minecraft.Download/versions/1.10.2/minecraft_server.1.10.2.jar \
        #    > "$destination_directory/minecraft_server.1.10.2.jar"

        # Download spigot
        #curl https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar \
        #    > "$destination_directory/BuildTools.jar"

        #docker build -t ll/gamesvr-minecraft -f "$LANYWARE_REPO_PATH/ll/gamesvr-minecraft/Dockerfile.linux" "$LANYWARE_REPO_PATH/ll/gamesvr-minecraft/";

        #gfx_section_end;
    fi;
fi;


#                                                                          _                                  ____ __          __            _  __     __ __
#     ____ _ ____ _ ____ ___   ___   _____ _   __ _____        ____ ___   (_)____   ___   _____ _____ ____ _ / __// /_        / /_   __  __ (_)/ /____/ // /_   ____   _  __
#    / __ `// __ `// __ `__ \ / _ \ / ___/| | / // ___/______ / __ `__ \ / // __ \ / _ \ / ___// ___// __ `// /_ / __/______ / __ \ / / / // // // __  // __ \ / __ \ | |/_/
#   / /_/ // /_/ // / / / / //  __/(__  ) | |/ // /   /_____// / / / / // // / / //  __// /__ / /   / /_/ // __// /_ /_____// /_/ // /_/ // // // /_/ // /_/ // /_/ /_>  <
#   \__, / \__,_//_/ /_/ /_/ \___//____/  |___//_/          /_/ /_/ /_//_//_/ /_/ \___/ \___//_/    \__,_//_/   \__/       /_.___/ \__,_//_//_/ \__,_//_.___/ \____//_/|_|
#  /____/



        #import_github_repo "LacledesLAN/gamesvr-svencoop-freeplay" "$destination_directory/";




#
#     ____ _ ____ _ ____ ___   ___   _____ _   __ _____        _____ _   __ ___   ____   _____ ____   ____   ____
#    / __ `// __ `// __ `__ \ / _ \ / ___/| | / // ___/______ / ___/| | / // _ \ / __ \ / ___// __ \ / __ \ / __ \
#   / /_/ // /_/ // / / / / //  __/(__  ) | |/ // /   /_____/(__  ) | |/ //  __// / / // /__ / /_/ // /_/ // /_/ /
#   \__, / \__,_//_/ /_/ /_/ \___//____/  |___//_/          /____/  |___/ \___//_/ /_/ \___/ \____/ \____// .___/
#  /____/                                                                                                /_/
if [ "$MODE_DOCKER_LIBRARY" = true ] ; then
    if [ $DOCKER_REBUILD_LEVEL -le 2 ] ; then

        #gfx_section_start "Docker -=> Building Image ll/gamesvr-svencoop";

        #remove_docker_image "ll/gamesvr-svencoop";

        destination_directory="$LANYWARE_REPO_PATH/ll/gamesvr-svencoop/files";

        #mkdir "$destination_directory" --parents;

        #empty_folder "$destination_directory";

        #import_steam_app 276060 "$destination_directory/";

        #docker build -t ll/gamesvr-svencoop -f "$LANYWARE_REPO_PATH/ll/gamesvr-svencoop/Dockerfile.linux" "$LANYWARE_REPO_PATH/ll/gamesvr-svencoop/";

        #gfx_section_end;
    fi;
fi;


#                                                                                                                           ____                          __
#     ____ _ ____ _ ____ ___   ___   _____ _   __ _____        _____ _   __ ___   ____   _____ ____   ____   ____          / __/_____ ___   ___   ____   / /____ _ __  __
#    / __ `// __ `// __ `__ \ / _ \ / ___/| | / // ___/______ / ___/| | / // _ \ / __ \ / ___// __ \ / __ \ / __ \ ______ / /_ / ___// _ \ / _ \ / __ \ / // __ `// / / /
#   / /_/ // /_/ // / / / / //  __/(__  ) | |/ // /   /_____/(__  ) | |/ //  __// / / // /__ / /_/ // /_/ // /_/ //_____// __// /   /  __//  __// /_/ // // /_/ // /_/ /
#   \__, / \__,_//_/ /_/ /_/ \___//____/  |___//_/          /____/  |___/ \___//_/ /_/ \___/ \____/ \____// .___/       /_/  /_/    \___/ \___// .___//_/ \__,_/ \__, /
#  /____/                                                                                                /_/                                  /_/               /____/
if [ "$MODE_DOCKER_LIBRARY" = true ] ; then
    if [ $DOCKER_REBUILD_LEVEL -le 3 ] ; then

        #gfx_section_start "Docker -=> Building Image ll/gamesvr-svencoop-freeplay";

        #remove_docker_image "ll/gamesvr-svencoop-freeplay";

        destination_directory="$LANYWARE_REPO_PATH/ll/gamesvr-svencoop-freeplay/files";

        #mkdir "$destination_directory" --parents;

        #empty_folder "$destination_directory";

        #import_github_repo "LacledesLAN/gamesvr-svencoop-freeplay" "$destination_directory/";

        #docker build -t ll/gamesvr-svencoop-freeplay -f "$LANYWARE_REPO_PATH/ll/gamesvr-svencoop-freeplay/Dockerfile.linux" "$LANYWARE_REPO_PATH/ll/gamesvr-svencoop-freeplay/";

        #gfx_section_end;
    fi;
fi;


#                                                             ______ ______ ___
#     ____ _ ____ _ ____ ___   ___   _____ _   __ _____      /_  __// ____/|__ \
#    / __ `// __ `// __ `__ \ / _ \ / ___/| | / // ___/______ / /  / /_    __/ /
#   / /_/ // /_/ // / / / / //  __/(__  ) | |/ // /   /_____// /  / __/   / __/
#   \__, / \__,_//_/ /_/ /_/ \___//____/  |___//_/          /_/  /_/     /____/
#  /____/
if [ "$MODE_DOCKER_LIBRARY" = true ] ; then
    if [ $DOCKER_REBUILD_LEVEL -le 2 ] ; then

        #gfx_section_start "Docker -=> Building Image ll/gamesvr-tf2";

        #remove_docker_image "ll/gamesvr-tf2";

        destination_directory="$LANYWARE_REPO_PATH/ll/gamesvr-tf2/files";

        #mkdir "$destination_directory" --parents;

        #import_steam_app 232250 "$destination_directory/";

        #docker build -t ll/gamesvr-tf2 -f "$LANYWARE_REPO_PATH/ll/gamesvr-tf2/Dockerfile.linux" "$LANYWARE_REPO_PATH/ll/gamesvr-tf2/";

        #gfx_section_end;
    fi;
fi;


#                                                             ______ ______ ___          __     __ _             __ ____
#     ____ _ ____ _ ____ ___   ___   _____ _   __ _____      /_  __// ____/|__ \        / /_   / /(_)____   ____/ // __/_____ ____ _ ____ _
#    / __ `// __ `// __ `__ \ / _ \ / ___/| | / // ___/______ / /  / /_    __/ /______ / __ \ / // // __ \ / __  // /_ / ___// __ `// __ `/
#   / /_/ // /_/ // / / / / //  __/(__  ) | |/ // /   /_____// /  / __/   / __//_____// /_/ // // // / / // /_/ // __// /   / /_/ // /_/ /
#   \__, / \__,_//_/ /_/ /_/ \___//____/  |___//_/          /_/  /_/     /____/      /_.___//_//_//_/ /_/ \__,_//_/  /_/    \__,_/ \__, /
#  /____/                                                                                                                         /____/
#
if [ "$MODE_DOCKER_LIBRARY" = true ] ; then
    if [ $DOCKER_REBUILD_LEVEL -le 3 ] ; then

        #gfx_section_start "Docker -=> Building Image ll/gamesvr-tf2-blindfrag";

        #remove_docker_image "ll/gamesvr-tf2-blindfrag";

        destination_directory="$LANYWARE_REPO_PATH/ll/gamesvr-tf2-blindfrag/linux/files";

        #mkdir "$destination_directory" --parents;

        #empty_folder "$destination_directory";

        #import_github_repo "LacledesLAN/gamesvr-srcds-metamod.linux" "$destination_directory/tf/";

        #import_github_repo "LacledesLAN/gamesvr-srcds-sourcemod.linux" "$destination_directory/tf/";

        #import_github_repo "LacledesLAN/gamesvr-srcds-tf2-blindfrag" "$destination_directory/";

        #docker build -t ll/gamesvr-tf2-blindfrag "$LANYWARE_REPO_PATH/repos/ll/gamesvr-tf2-blindfrag/linux/";

        #gfx_section_end;

    fi;
fi;


#                                                             ______ ______ ___              __                        __                   __
#     ____ _ ____ _ ____ ___   ___   _____ _   __ _____      /_  __// ____/|__ \        ____/ /____  _      __ ____   / /____   ____ _ ____/ /
#    / __ `// __ `// __ `__ \ / _ \ / ___/| | / // ___/______ / /  / /_    __/ /______ / __  // __ \| | /| / // __ \ / // __ \ / __ `// __  /
#   / /_/ // /_/ // / / / / //  __/(__  ) | |/ // /   /_____// /  / __/   / __//_____// /_/ // /_/ /| |/ |/ // / / // // /_/ // /_/ // /_/ /
#   \__, / \__,_//_/ /_/ /_/ \___//____/  |___//_/          /_/  /_/     /____/       \__,_/ \____/ |__/|__//_/ /_//_/ \____/ \__,_/ \__,_/
#  /____/
if [ "$MODE_DOCKER_LIBRARY" = true ] ; then
    if [ $DOCKER_REBUILD_LEVEL -le 3 ] ; then

        #gfx_section_start "Docker -=> Building Image ll/gamesvr-tf2-download";

        #remove_docker_image "ll/gamesvr-tf2-download";

        destination_directory="$LANYWARE_REPO_PATH/ll/gamesvr-tf2-download/files";

        #mkdir "$destination_directory" --parents;

        #empty_folder "$destination_directory";

        #import_github_repo "LacledesLAN/gamesvr-srcds-tf2-download" "$destination_directory/";

        #docker build -t ll/gamesvr-tf2-download -f "$LANYWARE_REPO_PATH/ll/gamesvr-tf2-download/Dockerfile.linux" "$LANYWARE_REPO_PATH/ll/gamesvr-tf2-download/";

        #gfx_section_end;
    fi;
fi;


#                                                             ______ ______ ___          ______                          __
#     ____ _ ____ _ ____ ___   ___   _____ _   __ _____      /_  __// ____/|__ \        / ____/_____ ___   ___   ____   / /____ _ __  __
#    / __ `// __ `// __ `__ \ / _ \ / ___/| | / // ___/______ / /  / /_    __/ /______ / /_   / ___// _ \ / _ \ / __ \ / // __ `// / / /
#   / /_/ // /_/ // / / / / //  __/(__  ) | |/ // /   /_____// /  / __/   / __//_____// __/  / /   /  __//  __// /_/ // // /_/ // /_/ /
#   \__, / \__,_//_/ /_/ /_/ \___//____/  |___//_/          /_/  /_/     /____/      /_/    /_/    \___/ \___// .___//_/ \__,_/ \__, /
#  /____/                                                                                                    /_/               /____/
if [ "$MODE_DOCKER_LIBRARY" = true ] ; then
    if [ $DOCKER_REBUILD_LEVEL -le 3 ] ; then

        #gfx_section_start "Docker -=> Building Image ll/gamesvr-tf2-freeplay";

        #remove_docker_image "ll/gamesvr-tf2-freeplay";

        destination_directory="$LANYWARE_REPO_PATH/ll/gamesvr-tf2-freeplay/linux/files";

        #mkdir "$destination_directory" --parents;

        #empty_folder "$destination_directory";

        #import_github_repo "LacledesLAN/gamesvr-srcds-metamod.linux" "$destination_directory/tf/";

        #import_github_repo "LacledesLAN/gamesvr-srcds-sourcemod.linux" "$destination_directory/tf/";

        #import_github_repo "LacledesLAN/gamesvr-srcds-tf2-freeplay" "$destination_directory/";

        #docker build -t ll/gamesvr-tf2-freeplay "$LANYWARE_REPO_PATH/ll/gamesvr-tf2-freeplay/linux/";

        #gfx_section_end;

    fi;
fi;


#                    _
#     ____   ____ _ (_)____   _  __
#    / __ \ / __ `// // __ \ | |/_/
#   / / / // /_/ // // / / /_>  <
#  /_/ /_/ \__, //_//_/ /_//_/|_|
#         /____/
#
if [ "$MODE_DOCKER_LIBRARY" = true ] ; then
    if [ $DOCKER_REBUILD_LEVEL -le 0 ] ; then

        gfx_section_start "Pulling Docker Image -=> nginx:latest";

        echo "Pulling nginx:latest from Docker hub";

        docker pull nginx:latest;

        gfx_section_end;
    fi;
fi;


#                    __                               __              __           __                __
#   _      __ ___   / /_   _____ _   __ _____        / /____ _ _____ / /___   ____/ /___   _____    / /____ _ ____
#  | | /| / // _ \ / __ \ / ___/| | / // ___/______ / // __ `// ___// // _ \ / __  // _ \ / ___/   / // __ `// __ \
#  | |/ |/ //  __// /_/ /(__  ) | |/ // /   /_____// // /_/ // /__ / //  __// /_/ //  __/(__  )_  / // /_/ // / / /
#  |__/|__/ \___//_.___//____/  |___//_/          /_/ \__,_/ \___//_/ \___/ \__,_/ \___//____/(_)/_/ \__,_//_/ /_/
if [ "$MODE_DOCKER_LIBRARY" = true ] ; then
    if [ $DOCKER_REBUILD_LEVEL -le 3 ] ; then

        #gfx_section_start "Docker -=> Building Image ll/websvr-lacledes.lan";

        #remove_docker_image "ll/websvr-lacledes.lan";

        destination_directory="$LANYWARE_REPO_PATH/ll/websvr-lacledes.lan/files";

        #empty_folder "$destination_directory";

        #import_github_repo "LacledesLAN/websvr-lacledes.lan" "$destination_directory/";

        #docker build -t ll/websvr-lacledes.lan -f "$LANYWARE_REPO_PATH/ll/websvr-lacledes.lan/Dockerfile.linux" "$LANYWARE_REPO_PATH/ll/websvr-lacledes.lan/";

        #gfx_section_end;

    fi;
fi;


#            __
#     _____ / /_ _____ ___   _____ _____        ____   ____ _
#    / ___// __// ___// _ \ / ___// ___/______ / __ \ / __ `/
#   (__  )/ /_ / /   /  __/(__  )(__  )/_____// / / // /_/ /
#  /____/ \__//_/    \___//____//____/       /_/ /_/ \__, /
#                                                   /____/
if [ "$MODE_DOCKER_LIBRARY" = true ] ; then
    if [ $DOCKER_REBUILD_LEVEL -le 0 ] ; then

        gfx_section_start "Docker -=> Building Image duds/stress-ng";

        remove_docker_image "duds/stress-ng";

        docker build -t duds/stress-ng -f "$LANYWARE_REPO_PATH/duds/stress-ng/Dockerfile.linux" "$LANYWARE_REPO_PATH/duds/stress-ng/";

        gfx_section_end;

    fi;
fi;


#=============================================================================================================
#===  WRAP UP  ===============================================================================================
#=============================================================================================================

gfx_section_start "Summary (Finished at $(date))";

{
    if [ "$MODE_DOCKER_LIBRARY" = true ] ; then
        docker images;
    fi;
} 2>&1 | tee -a "$LANYWARE_LOGFILE";

gfx_section_end;


unset LANYWARE_GITHUB_IMPORT_HISTORY;
unset LANYWARE_LOGGING_ENABLED;
unset SCRIPT_VERSION;