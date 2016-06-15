Install Instructions (Debian-based)
-----------------------------------

**1. Install Dependancies**

` sudo apt-get install -y curl discus git htop libc6-i386 lib32gcc1 lib32stdc++6 lib32tinfo5 lib32z1 realpath screen tar tree util-linux wget; `

**2. Install Docker**

` sudo curl -sSL https://get.docker.com/ | sh `

**3. Add your linux user account to docker group**

` sudo usermod -aG docker <USER> `
Where "<USER>" is your local account. Log out and back in for change to take affect.

**4. Download repo into your home directory**

` cd ~; rm -rf ~/.git; git clone git://github.com/LacledesLAN/LANYWARE; rm -rf ~/.git; `

**5. Set permissions**

`cd ~/LANYWARE; chmod +x *.sh; chmod +x ./bin/*.sh; `


Execution
---------

` cd ~/LANYWARE; ./lanyware.sh; `



[INCOMPLETE SCRIPT] Install Instructions (CentOS / Ubunutu)
-----------------------------------------------------------
**1. Download install-lanyware.sh

**2. Add the execute permission to the install script

` chmod 755 ./install-lanyware.sh`

**3. Execute the install script and follow the prompts.

` ./install-lanyware.sh `




DEV NOTES
=========

<LANYWARE>

    [PRE CHECKS]
    pre-reqs are installed / available
    check directories are writable

    [USER MENU OPTIONS]
    
    
    [MAIN LOOP]
    parse repo tags in alphabetical order    
        parse repos in alphabetical order
            Execute Lanywarefile
            
            if (DOCKER)
                if contains "-"
            
                try for /*kernel*/Dockerfile
                try for Dockerfile.kernel
                try for Dockerfile
                <FAIL OUT>
                
                if clear-cache; clear the cache
            
            else if (RAW)
                try (cp || mv) -=> /kernel/files
                try (cp || mv) -=> files
                <failure>
            else ()
                FAIL

    [WIND DOWN]
    
    
<UPDATE>
    Update all files
    remove files that were removed from github repo


Directory Structure
===================
```
    LANYWARE/                                       LANYWARE project directory (created by git repo)
    |   └───bin/                                        Binary and script files that make lanyware work
    |   |   └───linux-steamcmd/¹                            Linux version of steamcmd
    |   |   └───windows-steamcmd/¹                          Windows version of steamcmd
    |   └───logs/                                       Where log files are dumped
    |   └───repos/                                      Contains server build repositories
    |   └───install-linux.sh                            Linux install script
    |   └───install-windows.ps1                         Windows install script
    └───lanyware.ps1                                Windows entry point
    └───lanyware.sh                                 Linux entry point

¹created as-needed by runtime
```


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
