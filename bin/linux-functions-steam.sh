#!/bin/bash


function steam_get_app_name() {
    #List updated 9/2016; Created using "dataFormatter-steam_get_app_name.xlsx" located inside of ".dev" folder
    #source: https://developer.valvesoftware.com/wiki/Dedicated_Servers_List
    case "$1" in
        "90")       echo -n "GoldSource Dedicated Server";
        "205")      echo -n "Source SDK Base 2006 MP Dedicated Server";;
        "310")      echo -n "Source 2007 Dedicated Server";;
        "570")      echo -n "Dota 2 Dedicated Server (Linux)";;
        "635")      echo -n "Alien Swarm Dedicated Server (Windows)";;
        "740")      echo -n "Counter-Strike Global Offensive Dedicated Server";;
        "1273")     echo -n "Killing Floor Beta Dedicated Server (Windows)";;
        "1290")     echo -n "Darkest Hour Dedicated Server (Windows)";;
        "2145")     echo -n "Dark Messiah of Might & Magic Dedicated Server (Windows)";;
        "2403")     echo -n "The Ship Dedicated Server";;
        "4020")     echo -n "Garry's Mod Dedicated Server";;
        "4270")     echo -n "RACE 07 Demo Dedicated Server (Windows)";;
        "4940")     echo -n "Natural Selection 2 Dedicated Server";;
        "8680")     echo -n "RACE 07 Demo - Crowne Plaza Edition Dedicated Server (Windows)";;
        "8710")     echo -n "STCC - The Game Demo Dedicated Server (Windows)";;
        "8730")     echo -n "GTR Evolution Demo Dedicated Server (Windows)";;
        "8770")     echo -n "RACE On - Demo: Dedicated Server (Windows)";;
        "13180")    echo -n "America's Army 3 Dedicated Server (Windows)";;
        "17505")    echo -n "Zombie Panic Source Dedicated Server";;
        "17515")    echo -n "Age of Chivalry Dedicated Server (Windows)";;
        "17525")    echo -n "Synergy Dedicated Server (Windows)";;
        "17535")    echo -n "D.I.P.R.I.P. Dedicated Server (Windows)";;
        "17555")    echo -n "Eternal Silence Dedicated Server (Windows)";;
        "17575")    echo -n "Pirates, Vikings, and Knights II Dedicated Server";;
        "17585")    echo -n "Dystopia Dedicated Server (Windows)";;
        "17705")    echo -n "Insurgency: Modern Infantry Combat Dedicated Server";;
        "34120")    echo -n "Aliens vs Predator Dedicated Server (Windows)";;
        "41005")    echo -n "Serious Sam Classics: Revolution Dedicated Server (Windows)";;
        "41005")    echo -n "Serious Sam HD Dedicated Server (Windows)";;
        "41080")    echo -n "Serious Sam 3 Dedicated Server";;
        "42750")    echo -n "Call of Duty: Modern Warfare 3 Dedicated Server (Windows)";;
        "43210")    echo -n "The Haunted: Hells Reach Dedicated Server (Windows)";;
        "55280")    echo -n "Homefront Dedicated Server (Windows)";;
        "63220")    echo -n "Monday Night Combat Dedicated Server (Windows)";;
        "70010")    echo -n "Dino D-Day Dedicated Server (Windows)";;
        "72310")    echo -n "Breach Dedicated Server (Windows)";;
        "72780")    echo -n "Brink Dedicated Server (Windows)";;
        "91720")    echo -n "E.Y.E - Dedicated Server (Windows)";;
        "96810")    echo -n "Nexuiz Dedicated Server (Windows)";;
        "105600")   echo -n "Terraria Dedicated Server (Linux)";;
        "108600")   echo -n "Project Zomboid Dedicated Server";;
        "111710")   echo -n "Nuclear Dawn Dedicated Server (Windows)";;
        "203300")   echo -n "America's Army: Proving Grounds Dedicated Server (Windows)";;
        "208050")   echo -n "Sniper Elite V2 Dedicated Server (Windows)";;
        "210370")   echo -n "Starvoid Dedicated Server (Windows)";;
        "211820")   echo -n "Starbound Dedicated server";;
        "212542")   echo -n "Red Orchestra 2 Dedicated Server (Windows)";;
        "215350")   echo -n "Killing Floor Dedicated Server (Windows)";;
        "215360")   echo -n "Killing Floor Dedicated Server (Linux)";;
        "220070")   echo -n "Chivalry Medieval Warfare Dedicated Server";;
        "222840")   echo -n "Left 4 Dead Dedicated Server";;
        "222860")   echo -n "Left 4 Dead 2 Dedicated Server";;
        "223160")   echo -n "Ravaged Dedicated Server (Windows)";;
        "223240")   echo -n "Red Orchestra Windows Dedicated Server (Windows)";;
        "223250")   echo -n "Red Orchestra Linux Dedicated Server (Linux)";;
        "224620")   echo -n "Primal Carnage Dedicated Server (Windows)";;
        "228780")   echo -n "Blade Symphony Dedicated Server";;
        "230030")   echo -n "Painkiller Hell & Damnation Dedicated Server (Windows)";;
        "232130")   echo -n "Killing Floor 2 Dedicated Server Windows (Windows)";;
        "232250")   echo -n "Team Fortress 2 Dedicated Server";;
        "232290")   echo -n "Day of Defeat: Source Dedicated Server";;
        "232330")   echo -n "Counter-Strike: Source Dedicated Server";;
        "232370")   echo -n "Half-Life 2: Deathmatch Dedicated Server";;
        "233780")   echo -n "Arma 3 Dedicated Server";;
        "237410")   echo -n "Insurgency 2014 Dedicated Server";;
        "238430")   echo -n "Contagion Dedicated Server (Windows)";;
        "244310")   echo -n "Source SDK Base 2013 Dedicated Server";;
        "255470")   echo -n "Half-Life Deathmatch: Source Dedicated server";;
        "258550")   echo -n "Rust Dedicated Server";;
        "258680")   echo -n "Chivalry: Deadliest Warrior Dedicated server (Windows)";;
        "261020")   echo -n "Takedown: Red Sabre Dedicated Server (Windows)";;
        "261140")   echo -n "Just Cause 2: Multiplayer - Dedicated Server";;
        "265360")   echo -n "Kingdoms Rise Dedicated Server (Windows)";;
        "266910")   echo -n "Sniper Elite 3 Dedicated Server (Windows)";;
        "276060")   echo -n "Sven Co-op Dedicated Server";;
        "294420")   echo -n "7 Days to Die Dedicated Server";;
        "295230")   echo -n "Fistful of Frags Server";;
        "298740")   echo -n "Space Engineers Dedicated Server (Windows)";;
        "299310")   echo -n "Serious Sam HD: The Second Encounter Dedicated Server (Windows)";;
        "302550")   echo -n "Assetto Corsa Dedicated Server (Windows)";;
        "304930")   echo -n "Unturned Dedicated Server (Linux)";;
        "312070")   echo -n "Dark Horizons: Mechanized Corps Dedicated Server (Linux)";;
        "313600")   echo -n "NEOTOKYO Dedicated Server (Windows)";;
        "313900")   echo -n "NS2: Combat Dedicated Server";;
        "317670")   echo -n "No More Room In Hell Dedicated Server";;
        "317800")   echo -n "Double Action Dedicated Server (Windows)";;
        "319060")   echo -n "Lambda Wars Dedicated Server (Windows)";;
        "320850")   echo -n "Life is Feudal: Your Own Dedicated Server (Windows)";;
        "329710")   echo -n "Fortress Forever Dedicated Server (Windows)";;
        "329740")   echo -n "Reflex Dedicated Server (Windows)";;
        "332850")   echo -n "BlazeRush Dedicated Server";;
        "343050")   echo -n "Don't Starve Together Dedicated Server (Linux)";;
        "346110")   echo -n "ARK: Survival Evolved (Windows)";;
        "346330")   echo -n "BrainBread 2 Dedicated Server (Linux)";;
        "346680")   echo -n "Black Mesa: Deathmatch Dedicated Server";;
        "374980")   echo -n "Zombie Grinder Dedicated Server (Windows)";;
        "376030")   echo -n "ARK: Survival Evolved Dedicated Server (Linux)";;
        "381690")   echo -n "Reign Of Kings Dedicated Server (Windows)";;
        "406800")   echo -n "Out of Reach Dedicated Server";;
        "419790")   echo -n "Eden Star Dedicated Server (Windows)";;
        "445400")   echo -n "ARK: Survival of the Fittest Dedicated Server (Windows)";;
        "460040")   echo -n "Empires Dedicated Server (Windows)";;
        "462310")   echo -n "Day of Infamy Dedicated Server";;
        "475370")   echo -n "BrainBread 2 Dedicated Server (Windows)";;
        *)          echo -n "$1";;
    esac
}


function import_steam_app() {    # APP ID; destination directory
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


# Downloads, extracts, and updates SteamCMD to the specified destination
# $1 The full path to the destination for SteamCMD
function import_steamcmd() { # destination directory
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
