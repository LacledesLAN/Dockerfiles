
Install Instructions (Debian-based)
-----------------------------------

**1. Download repo**

Download this repo and stage to your home directory (~/).

**2. Install misc dependancies**

` sudo apt-get install -y curl discus htop git libc6-i386 lib32gcc1 lib32stdc++6 lib32tinfo5 lib32z1 tar tree wget`

**3. Install Docker**

` sudo curl -sSL https://get.docker.com/ | sh`

**4. Add your linux user account to docker group**

` sudo usermod -aG docker <USER>`
Where "<USER>" is your local account. Log out and back in for change to take affect.

**5. Set permissions**

`chmod +x ~/*.sh;  chmod +x ~/_lanyware/linux/*.sh`





LANYWARE Structure Reference
============================
```
[WORKING DIRECTORY] ("/" inside docker images)
	└───/_lanyware                                    LANWARE directories
	|   └───/linux                                        LANYWARE directories for all linux
	|   |   └───/gamesvr
	|   |   |   └───/_util
	|   |   |       └───/steamcmd
	|   |   └───/gamesvr-blackmesa-freeplay
	|   |   └───/gamesvr-csgo
	|   |   └───/gamesvr-csgo-freeplay
	|   |   └───/gamesvr-csgo-tourney
	|   |   └───/gamesvr-dods
	|   |   └───/gamesvr-hl2dm
	|   |   └───/gamesvr-hl2dm-freeplay
	|   |   └───/gamesvr-tf2
	|   |   └───/gamesvr-tf2-blindfrag
	|   |   └───/gamesvr-tf2-freeplay
	|   |   └───/websvr-content.lan
	|   |   └───/websvr-kiosk.lan
	|   |   └───/websvr-lacledes.lan
	|   |   └───gfx-allthethings.sh
	|   |   └───install.sh
	|   |   └───reset-docker.sh
	|   └───/windows                                      LANYWARE directories for all windows
	└───/gamesvr......................................Output directories for local servers
	|   └───/.svr-bin.....................................Used *only* in docker images. Server folder is just a symlink to this one.
    |   └───/_util........................................Utilities for use with gameservers
	|   |   └───/steamcmd.....................................steamcmd utility for use with source servers
	|   └───/blackmesa-freeplay
	|   └───/csgo-freeplay
	|   └───/csgo-tourney
	|   └───/dods-freeplay
	|   └───/hl2dm-freeplay
    |   └───/tf2-blindfrag
    |   └───/tf2-freeplay
	└───lanyware.ps1                                  windows (POWERSHELL) entry point for LANYWARE suite
	└───lanyware.sh                                   linux (BASH) entry point for LANYWARE suite
```

Docker Image Build
==================
```
** DOCKER IMAGE **                                  ** SOURCES **
ubuntu:latest                                       hub.docker.com
└───ll/gamesvr··········································steamcmd
    └───ll/gamesvr-blackmesa································n/a
    └───ll/gamesvr-csgo·····································steamapp: csgo
    |   |                                                   ftp: content.lan/fastDownloads/csgo
    |   └───ll/gamesvr-csgo-freeplay····························github: gamesvr-srcds-metamod.linux,
    |   |                                                       github: gamesvr-srcds-sourcemod.linux,
    |   |                                                       github: gamesvr-srcds-csgo-freeplay
    |   └───ll/gamesvr-csgo-tourney·····························github: gamesvr-srcds-metamod.linux,
    |                                                           github: gamesvr-srcds-sourcemod.linux,
    |                                                           github: gamesvr-srcds-csgo-tourney
    └───ll/gamesvr-dods·····································steamapp: dods
    |   └───ll/gamesvr-dods-freeplay.............................github: gamesvr-srcds-dods-freeplay
    └───ll/gamesvr-hl2dm····································steamapp: hl2dm
    |   |                                                   ftp: content.lan/fastDownloads/hl2dm
    |   └───ll/gamesvr-hl2dm-freeplay···························github: gamesvr-srcds-hl2dm-freeplay
    └───ll/gamesvr-tf2······································steamapp: TF2
    |   |                                                   ftp: content.lan/fastDownloads/tf2
    |   └───ll/gamesvr-tf2-blindfrag····························github: gamesvr-srcds-metamod.linux
    |   |                                                       github: gamesvr-srcds-sourcemod.linux
    |   |                                                       github: gamescr-srcds-tf2-blindfrag
    |   └───ll/gamesvr-tf2-download·····························github: gamesvr-srcds-tf2-download
    |   └───ll/gamesvr-tf2-freeplay·····························github: gamesvr-srcds-metamod.linux
    |                                                           github: gamesvr-srcds-sourcemod.linux
    |                                                           github: gamesvr-srcds-tf2-freeplay
    └───ll/gamesvr-tfc······································steamapp: tfc
        |                                                   ftp: content.lan/fastDownloads/tfcs
        └───ll/gamesvr-tfc-freeplay..............................github: gamesvr-srcds-tfc-freeplay

nginx:latest
└───ll/websvr
    └───ll/websvr-contet.lan
    └───ll/websvr-kiosk.lan

microsoft/aspnet:latest
└───ll/websvr-lacledes.lan
```



Dockerfiles Collection
======================
Library of Dockerfiles for all Dockerized LL Servers

Why We Use Docker
-----------------

Levels
======
All Laclede's LAN docker images belong to one of three levels.  By design the lower the image level the less-frequently it needs to be rebuild during development and event cycles.  Not all image builds will use all three levels; levels may be skipped if they are not needed.

1. Category Level
-----------------
This level provides a "base level" of features, packages, and utilies for the operating system.  Each category has a standardized LL directory structure that must be followed for all child images for things to work properly. Defined categories include:

* "gamesvr" for all game server images to be built on.
* "websvr" for all webservers to be built on.

Category-Level images are derived from an operating system docker-image.

2. Application Level
---------------------
The Application Level consists of the required application for the docker-image as well as any related content. These images should not contain any configuration values as these are most frequently updated by LL staff.

Examples:

| Category | Application                      | Content                                |
|----------|----------------------------------|----------------------------------------|
| gamesvr  | Counter-Strike: Global Offensive | Community Maps and Texture Packs       |
| websvr   | nginx                            | Static HTML files, Stylesheets, Images |

Application-Level images are derived from a "Category-Level" docker-image.

3. Configuration Level
----------------------
The Configuration Level should configuration files along with any other files that may change frequently.



Images at this level are derived from an "Application Level" docker image.


-------------NOTES FOR FUNCTIONS-------------
Status: Downloaded new image for $
Status: Image is up to date for $
