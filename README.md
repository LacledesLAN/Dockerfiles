Official Directory Structure Reference 
======================================
```
(parent)
└───gamesvr
|   ├───_util
|   |   └───steamcmd
|   ├───csgo
|   ├───hl2dm
|   ├───tf2
└───websvr
```

Official Server Build Structure
===============================
```
ubuntu:latest
└───gamesvr
    └───gamesvr-csgo
    |   └───gamesvr-csgo-freeplay
    |   └───gamesvr-csgo-tourney
    └───gamesvr-dods    
    └───gamesvr-hl2dm
    |   └───gamesvr-hl2dm-freeplay
    └───gamesvr-tf2
        └───gamesvr-tf2-blindfrag
        └───gamesvr-tf2-freeplay

nginx:latest
└───websvr-contet.lan
└───websvr-kiosk.lan

microsoft/aspnet:latest
└───websvr-lacledes.lan
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



