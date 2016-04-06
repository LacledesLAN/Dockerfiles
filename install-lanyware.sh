#!/bin/bash
#Docker user in case you want to run this as a different user.
echo "Enter docker user: "
read dckeruser 
clear

#Determine operating system. 
#Cent will return centos
#Ubuntu will return ubuntu.
os=$(cat /etc/os-release | grep ID= | head -1 | cut -d = -f2|tr -d \")
echo $os
#CentOS installation
if [ $os="centos" ]; 
then	
	echo "Detected CentOS as running operating system"
	echo "Yum is now installing packages"
	echo "Installation log is available in yum-installation.log"
	sudo yum -y install bridge-utils curl discus git htop libc6-i386 lib32gcc1 lib32stdc++6 lib32tinfo5 lib32z1 realpath screen tar tree util-linux wget >> yum-installation.log
fi

#Ubuntu installation
if [ $os="ubuntu" ];
then
	echo "Detected Ubuntu as running operating system"
	echo "Aptitude is now installing packages"
	echo "Installation log is available in apt-get-installation.log"
	sudo apt-get install -y bridge-utils curl discus git htop libc6-i386 lib32gcc1 lib32stdc++6 lib32tinfo5 lib32z1 realpath screen tar tree util-linux wget >> apt-get-installation.log
fi

#Legacy LANYWARE code
sudo curl -sSL https://get.docker.com/ | sh
sudo usermod -aG docker $dckeruser
cd /home/$dkceruser
git clone git://github.com/LacledesLAN/LANYWARE
rm -rf /home/$dckeruser/.git
chmod +x /home/$dckeruser/*.sh +x /home/$dckeruser/_lanyware/linux/*.sh
