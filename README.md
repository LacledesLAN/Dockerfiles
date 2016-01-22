Dockerfiles Collection
======================
Library of Dockerfiles for all Dockerized LL Servers

Levels
======
All Laclede's LAN docker images belong to one of three levels.  Ideally the lower level images need to be rebuilt less-frequently than higher level images.

1. Category Level
-----------------
This level provides a "base level" of features, packages, and utilies for the operating system.  Defined categories include:

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

Application-Level images are derived from a LL "Category-Level" docker-image.

3. Configuration Level
----------------------
The Configuration Level should contain all items 



Images at this level are derived from a LL "Application Level" docker image.



Contributors
============

| Name         | GitHub Profile | Twitter       |
|--------------|----------------|---------------|
| James Dudley | jamesd-udley   | @jamesd_udley |
|              |                |               |
