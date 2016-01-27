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
echo "  Reset Docker Enviroment? This cannot be undone!";
echo "        y to reset; any other key to exit"

read -n 1 x; while read -n 1 -t .1 y; do x="$x$y"; done
echo "";

if [ $x == "y" ] ; then

	echo "Destroying ALL Docker containers."
	{ docker rm -f $(docker ps -a -q); } &> /dev/null; 
	{ docker rm -f $(docker ps -a -q); } &> /dev/null; 
	
	echo "Destroying ALL Docker images."
	{ docker rmi -f $(docker images -q); } &> /dev/null; 
	{ docker rmi -f $(docker images -q); } &> /dev/null; 
	
	echo "done.";
	echo "";
	echo "";
	echo "";

else
	echo -e "\n\nAborting...\n";
fi