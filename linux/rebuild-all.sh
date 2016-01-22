
function horizontalRule {
	printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
}

clear

tput setaf 3
tput bold
echo "         __    __       ____             __            "
echo "        / /   / /      / __ \____  _____/ /_____  _____"
echo "       / /   / /      / / / / __ \/ ___/ //_/ _ \/ ___/"
echo "      / /___/ /___   / /_/ / /_/ / /__/ ,< /  __/ /    "
echo "     /___________/  ______/\_____\___/_/__|\___/_/     "
echo "        / __ \___  / __ )__  __(_) /___/ /__  _____    "
echo "       / /_/ / _ \/ __  / / / / / / __  / _ \/ ___/    "
echo "      / _, _/  __/ /_/ / /_/ / / / /_/ /  __/ /        "
echo "     /_/ |_|\___/_____/\__,_/_/_/\__,_/\___/_/         "
echo "                                                       "
tput sgr0

tput smul
echo -e "\nCLEAN UP";
tput sgr0

echo -n "Destroying all LL docker containers.."
{
	docker rm -f $(docker ps -a -q);   #todo: add filter for ll/*
} &> /dev/null
echo ".done."

echo -n "Destroying all LL docker images.."
{
	docker rmi -f $(docker images -q);   #todo: add filter for ll/*
} &> /dev/null
echo ".done.";

################################################################################
################################################################################
################################################################################

tput smul
echo -e "\nREBUILD";
tput sgr0

echo "Building ll/gamesvr"
docker build -t ll/gamesvr ./gamesvr/
horizontalRule


echo "Building ll/gamesvr-csgo...";
docker build -t ll/gamesvr-csgo ./gamesvr-csgo/
horizontalRule

echo "Building ll/gamesvr-csgo-freeplay...";
docker build -t ll/gamesvr-csgo-freeplay ./gamesvr-csgo-freeplay/
horizontalRule

echo "Building ll/gamesvr-csgo-tourney...";
docker build -t ll/gamesvr-csgo-tourney ./gamesvr-csgo-tourney/
horizontalRule

tput smul
echo -e "\nFINISHED\n";
tput sgr0