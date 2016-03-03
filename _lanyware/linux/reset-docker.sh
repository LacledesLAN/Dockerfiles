#!/bin/bash
#=============================================================================================================

command -v docker > /dev/null 2>&1 || { echo >&2 "Docker required.  Aborting."; exit 1; }

echo "      ____                  __                              ";
echo "     / __ \  ____   _____  / /__  ___    _____              ";
echo "    / / / / / __ \ / ___/ / //_/ / _ \  / ___/              ";
echo "   / /_/ / / /_/ // /__  / ,<   /  __/ / /                  ";
echo "  /_____/  \____/ \___/ /_/|_|  \___/ /_/                   ";
echo "                           ____                        __   ";
echo "                          / __ \  ___    _____  ___   / /_  ";
echo "                         / /_/ / / _ \  / ___/ / _ \ / __/  ";
echo "                        / _, _/ /  __/ (__  ) /  __// /_    ";
echo "                       /_/ |_|  \___/ /____/  \___/ \__/    ";
echo "                                                            ";
echo "";

echo "Destroying ALL Docker containers."
{ docker rm -fv $(docker ps -a -q); } &> /dev/null; 
{ docker rm -fv $(docker ps -a -q); } &> /dev/null; 

echo "Destroying ALL Docker images."
{ docker rmi -f $(docker images -q); } &> /dev/null;
{ docker rmi -f $(docker images -q); } &> /dev/null;

#docker pull spotify/docker-gc:latest
#docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v /etc:/etc spotify/docker-gc
    
{ docker volume rm $(docker volume ls -qf dangling=true); } &> /dev/null;

echo "done.";
echo "";