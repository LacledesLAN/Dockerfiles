#!/bin/bash

function gfx_allthethings() {
    echo -ne "\n";
    echo -ne "  ─────────────────────────────▄██▄  \n"; sleep 0.020;
    echo -ne "  ─────────────────────────────▀███  \n"; sleep 0.020;
    echo -ne "  ────────────────────────────────█  \n"; sleep 0.020;
    echo -ne "  ───────────────▄▄▄▄▄────────────█  \n"; sleep 0.020;
    echo -ne "  ──────────────▀▄────▀▄──────────█  \n"; sleep 0.020;
    echo -ne "  ──────────▄▀▀▀▄─█▄▄▄▄█▄▄─▄▀▀▀▄──█  \n"; sleep 0.020;
    echo -ne "  ─────────█──▄──█────────█───▄─█─█  \n"; sleep 0.020;
    echo -ne "  ─────────▀▄───▄▀────────▀▄───▄▀─█  \n"; sleep 0.020;
    echo -ne "  ──────────█▀▀▀────────────▀▀▀─█─█  \n"; sleep 0.020;
    echo -ne "  ──────────█───────────────────█─█  \n"; sleep 0.020;
    echo -ne "  ▄▀▄▄▀▄────█──▄█▀█▀█▀█▀█▀█▄────█─█  \n"; sleep 0.020;
    echo -ne "  █▒▒▒▒█────█──█████████████▄───█─█  \n"; sleep 0.020;
    echo -ne "  █▒▒▒▒█────█──██████████████▄──█─█  \n"; sleep 0.020;
    echo -ne "  █▒▒▒▒█────█───██████████████▄─█─█  \n"; sleep 0.020;
    echo -ne "  █▒▒▒▒█────█────██████████████─█─█  \n"; sleep 0.020;
    echo -ne "  █▒▒▒▒█────█───██████████████▀─█─█  \n"; sleep 0.020;
    echo -ne "  █▒▒▒▒█───██───██████████████──█─█  \n"; sleep 0.020;
    echo -ne "  ▀████▀──██▀█──█████████████▀──█▄█  \n"; sleep 0.020;
    echo -ne "  ──██───██──▀█──█▄█▄█▄█▄█▄█▀──▄█▀   \n"; sleep 0.020;
    echo -ne "  ──██──██────▀█─────────────▄▀▓█    \n"; sleep 0.020;
    echo -ne "  ──██─██──────▀█▀▄▄▄▄▄▄▄▄▄▀▀▓▓▓█    \n"; sleep 0.020;
    echo -ne "  ──████────────█▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█    \n"; sleep 0.020;
    echo -ne "  ──███─────────█▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█    \n"; sleep 0.020;
    echo -ne "  ──██──────────█▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█    \n"; sleep 0.020;
    echo -ne "  ──██──────────█▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█    \n"; sleep 0.020;
    echo -ne "  ──██─────────▐█▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█    \n"; sleep 0.020;
    echo -ne "  ──██────────▐█▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█    \n"; sleep 0.020;
    echo -ne "  ──██───────▐█▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█▌    \n"; sleep 0.020;
    echo -ne "  ──██──────▐█▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█▌     \n"; sleep 0.020;
    echo -ne "  ──██─────▐█▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█▌      \n"; sleep 0.020;
    echo -ne "  ──██────▐█▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█▌       \n"; sleep 0.020;
    sleep 0.25;
}

function gfx_fliptable() {
    echo -e "（╯°□°）╯ ┻━┻";
    sleep 0.2;
}

function gfx_horizontal_rule() {
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =;
    return 0;
}

function gfx_section_end() {
    tput sgr0;
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