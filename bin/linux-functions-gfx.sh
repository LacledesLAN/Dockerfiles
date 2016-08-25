#!/bin/bash

function gfx_allthethings() {
    echo -ne "\n";
    echo -ne "  ─────────────────────────────▄██▄ \n"; sleep 0.018;
    echo -ne "  ─────────────────────────────▀███ \n"; sleep 0.018;
    echo -ne "  ────────────────────────────────█ \n"; sleep 0.018;
    echo -ne "  ───────────────▄▄▄▄▄────────────█ \n"; sleep 0.018;
    echo -ne "  ──────────────▀▄────▀▄──────────█ \n"; sleep 0.018;
    echo -ne "  ──────────▄▀▀▀▄─█▄▄▄▄█▄▄─▄▀▀▀▄──█ \n"; sleep 0.018;
    echo -ne "  ─────────█──▄──█────────█───▄─█─█ \n"; sleep 0.018;
    echo -ne "  ─────────▀▄───▄▀────────▀▄───▄▀─█ \n"; sleep 0.018;
    echo -ne "  ──────────█▀▀▀────────────▀▀▀─█─█ \n"; sleep 0.018;
    echo -ne "  ──────────█───────────────────█─█ \n"; sleep 0.018;
    echo -ne "  ▄▀▄▄▀▄────█──▄█▀█▀█▀█▀█▀█▄────█─█ \n"; sleep 0.018;
    echo -ne "  █▒▒▒▒█────█──█████████████▄───█─█ \n"; sleep 0.018;
    echo -ne "  █▒▒▒▒█────█──██████████████▄──█─█ \n"; sleep 0.018;
    echo -ne "  █▒▒▒▒█────█───██████████████▄─█─█ \n"; sleep 0.018;
    echo -ne "  █▒▒▒▒█────█────██████████████─█─█ \n"; sleep 0.018;
    echo -ne "  █▒▒▒▒█────█───██████████████▀─█─█ \n"; sleep 0.018;
    echo -ne "  █▒▒▒▒█───██───██████████████──█─█ \n"; sleep 0.018;
    echo -ne "  ▀████▀──██▀█──█████████████▀──█▄█ \n"; sleep 0.018;
    echo -ne "  ──██───██──▀█──█▄█▄█▄█▄█▄█▀──▄█▀  \n"; sleep 0.018;
    echo -ne "  ──██──██────▀█─────────────▄▀▓█   \n"; sleep 0.018;
    echo -ne "  ──██─██──────▀█▀▄▄▄▄▄▄▄▄▄▀▀▓▓▓█   \n"; sleep 0.018;
    echo -ne "  ──████────────█▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█   \n"; sleep 0.018;
    echo -ne "  ──███─────────█▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█   \n"; sleep 0.018;
    echo -ne "  ──██──────────█▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█   \n"; sleep 0.018;
    echo -ne "  ──██──────────█▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█   \n"; sleep 0.018;
    echo -ne "  ──██─────────▐█▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█   \n"; sleep 0.018;
    echo -ne "  ──██────────▐█▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█   \n"; sleep 0.018;
    echo -ne "  ──██───────▐█▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█▌   \n"; sleep 0.018;
    echo -ne "  ──██──────▐█▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█▌    \n"; sleep 0.018;
    echo -ne "  ──██─────▐█▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█▌     \n"; sleep 0.018;
    echo -ne "  ──██────▐█▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█▌      \n"; sleep 0.018;
    sleep 0.30;
    return 0;
}

function gfx_section_end() {
    tput sgr0;
    return 0;
}


# Start a section of output on the screen
# $1 (optional) The section title
# $2 (optional) The foreground color to use during this section
function gfx_section_start() {
    echo -e "\n";   

    tput sgr0; tput bold;

    {
        echo -e "\n";    
        printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =;        # print line across terminal width    

        if [[ -n $1 ]]; then
            echo -e "\t$1";
            printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =;
        fi
    } 2>&1 | tee -a "$LANYWARE_LOGFILE";

    # Set optional foreground color
    if [[ -z "$2" ]]; then
        tput sgr0; tput dim; tput setaf 6;
    elif [[ "$2" = "7" ]]; then
        tput sgr0; tput setaf 7;
    else
        tput sgr0; tput dim; tput setaf "$2";
    fi;

    return 0;
}