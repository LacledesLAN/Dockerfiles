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

function gfx_horizontal_rule() {
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =;
    return 0;
}

function gfx_section_end() {
    tput sgr0;
    return 0;
}

function gfx_section_start() {
    
    echo -e "\n\n";   

    tput sgr0; tput bold;

    {
        echo -e "\n";    
        gfx_horizontal_rule;
        echo -e "\t$1";
        gfx_horizontal_rule;
    } 2>&1 | tee "$LANYWARE_LOGFILE";

    tput sgr0; tput dim; tput setaf 6;

    return 0;
}
