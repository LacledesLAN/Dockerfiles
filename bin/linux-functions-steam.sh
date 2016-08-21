#!/bin/bash


function steam_get_app_name() {
    #list last updated 3/22/2016
    #source: https://developer.valvesoftware.com/wiki/Dedicated_Servers_List#Linux_Dedicated_Servers
    case "$1" in
        "294420")   echo -n "7 Days to Die Dedicated Server"; ;;
        "233780")   echo -n "Arma 3 Dedicated Server"; ;;
        "346680")   echo -n "Black Mesa: Deathmatch Dedicated Server"; ;;
        "346330")   echo -n "BrainBread 2 Dedicated Server";;
        "228780")   echo -n "Blade Symphony Dedicated Server";;
        "332850")   echo -n "BlazeRush Dedicated Server ";;
        "740")      echo -n "Counter-Strike Global Offensive Dedicated Server";;
        "232330")   echo -n "Counter-Strike: Source Dedicated Server";;
        "220070")   echo -n "Chivalry Medieval Warfare Dedicated Server";;
        "312070")   echo -n "Dark Horizons: Mechanized Corps Dedicated Server";;
        "232290")   echo -n "Day of Defeat: Source Dedicated Server";;
        "570")      echo -n "Dota 2 Dedicated Server";;
        "343050")   echo -n "Don't Starve Together Dedicated Server";;
        "295230")   echo -n "Fistful of Frags Server ";;
        "4020")     echo -n "Garry's Mod Dedicated Server";;
        "232370")   echo -n "Half-Life 2: Deathmatch Dedicated Server";;
        "255470")   echo -n "Half-Life Deathmatch: Source Dedicated server";;
        "90")       echo -n "Half-Life Gold-Source Dedicated Server";;
        "237410")   echo -n "Insurgency 2014 Dedicated Server";;
        "17705")    echo -n "Insurgency: Modern Infantry Combat Dedicated Server";;
        "261140")   echo -n "Just Cause 2: Multiplayer - Dedicated Server";;
        "215360")   echo -n "Killing Floor Dedicated Server - Linux";;
        "222860")   echo -n "Left 4 Dead 2 Dedicated Server";;
        "222840")   echo -n "Left 4 Dead Dedicated Server";;
        "4940")     echo -n "Natural Selection 2 Dedicated Server";;
        "313900")   echo -n "NS2: Combat Dedicated Server";;
        "317670")   echo -n "No More Room In Hell Dedicated Server";;
        "17575")    echo -n "Pirates, Vikings, and Knights II Dedicated Server";;
        "108600")   echo -n "Project Zomboid Dedicated Server";;
        "223250")   echo -n "Red Orchestra Linux Dedicated Server";;
        "258550")   echo -n "Rust Dedicated Server";;
        "41080")    echo -n "Serious Sam 3 Dedicated Server";;
        "276060")   echo -n "Sven Co-op Dedicated Server";;
        "205")      echo -n "Source SDK Base 2006 MP Dedicated Server";;
        "310")      echo -n "Source 2007 Dedicated Server";;
        "205")      echo -n "Source Dedicated Server";;
        "244310")   echo -n "Source SDK Base 2013 Dedicated Server";;
        "211820")   echo -n "Starbound Dedicated server";;
        "232250")   echo -n "Team Fortress 2 Dedicated Server";;
        "2403")     echo -n "The Ship Dedicated Server";;
        "105600")   echo -n "Terraria Dedicated Server";;
        "304930")   echo -n "Unturned Dedicated Server";;
        "17505")    echo -n "Zombie Panic Source Dedicated Server";;
        *)          echo -n "$1";;
    esac
}


function steam_import_app() {    # APP ID; destination directory
    mkdir -p "$2";

    local loc_prev_line="thisValueWillNeverOccurNormally";
    local loc_counter=1;

    echo "Getting and verifying Steam App '$(steam_get_app_name $1)'";
    if [[ "$LANYWARE_LOGGING_ENABLED" = true ]] ; then
        echo "Getting and verifying Steam App '$(steam_get_app_name $1)'" >> $LANYWARE_LOGFILE;
    fi

    script -q --command "bash $LANYWARE_BIN_PATH/linux-steamcmd/steamcmd.sh \
        +login anonymous \
        +force_install_dir $2 \
        +app_update $1 \
        -validate \
        +quit" | while IFS= read line
        do
                if [[ $line == *"type 'quit' to exit --"* || -z "${line// }" ]] ; then
                    echo -n ""; #don't display on terminal
                elif [[ $line == *"Update state ("*")"* || $line = *"["*"]"* ]] ; then
                    # Remove any leading whitespace
                    line="$(echo -e "${line}" | sed -e 's/^[[:space:]]*//')";

                    if [[ $line = "$loc_prev_line" ]] ; then
                        loc_prev_line=line;
                        loc_counter=$((loc_counter+1))
                        line="$line - x$loc_counter";
                    else
                        loc_counter=1;
                        loc_prev_line=line;
                    fi

                    echo -en "\e[0K\r\t$line   ";
                else
                    echo -e "\t$line   ";
                fi
            if [[ "$LANYWARE_LOGGING_ENABLED" = true ]] ; then
                echo -e "\t$(date)\t$line" >> $LANYWARE_LOGFILE;
            fi
        done
    if [[ $? != 0 ]] ; then
        echo "TODO: PROCESS FAILED DOWNLOAD"
    else
        echo -n ""; #do nothing
  fi

  touch "$2/@steamapp-$1.has";

  echo "";
}


function steam_import_tool() { # destination directory
    #Header
    tput setaf 6;
    echo -e "\tVerifying SteamCMD";
    echo -e "\t[Target Directory] $1";
    tput sgr0; tput dim; tput setaf 6;

    mkdir -p "$1";
    
    {
        chmod "$1/*.sh" +x;
        bash "$1/"steamcmd.sh +quit;
    }  &> /dev/null;
    
    if [ $? -ne 0 ] ; then
        echo -n ".downloading.."

        #failed to run SteamCMD.  Download it.
        {
            rm -rf "${1:?}/*";
            
            echo $?;
            
            wget -qO- -r --tries=10 --waitretry=20 --output-document=tmp.tar.gz http://media.steampowered.com/installer/steamcmd_linux.tar.gz;
            tar -xvzf tmp.tar.gz -C "$1/";
            rm tmp.tar.gz;

            chmod "$1/*.sh" +x;

            bash "$1/"steamcmd.sh +quit;
        } &> /dev/null;
    fi

    echo ".updated...done."
    echo -e "";
}
