#!/bin/bash

SIXFAB_PATH="/opt/sixfab"
PPP_PATH="/opt/sixfab/ppp_connection_manager"

REPO_PATH="https://raw.githubusercontent.com/sixfab/Sixfab_PPP_Installer"
BRANCH=revision
SOURCE_PATH="$REPO_PATH/$BRANCH/src"
SCRIPT_PATH="$REPO_PATH/$BRANCH/src/reconnect_scripts"
RECONNECT_SCRIPT_NAME="ppp_reconnect.sh"
MANAGER_SCRIPT_NAME="ppp_connection_manager.sh"
SERVICE_NAME="ppp_connection_manager.service"

YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[1;34m'
SET='\033[0m'


function colored_echo
{
	COLOR=${2:-$YELLOW}
	echo -e "$COLOR $1 ${SET}"
}


# Check Sixfab path 
if [[ -e $SIXFAB_PATH ]]; then
    colored_echo "Sixfab path already exist!" ${SET}
else
    sudo mkdir $SIXFAB_PATH
    colored_echo "Sixfab path is created." ${SET}
fi

# Check PPP path 
if [[ -e $PPP_PATH ]]; then
    colored_echo "PPP path already exist!" ${SET}
else
    sudo mkdir $PPP_PATH
    colored_echo "PPP path is created." ${SET}
fi

colored_echo "Installing PPP for Sixfab Cellular IoT Shield/HAT with Twilio Super SIM"

colored_echo "Downloading setup files..."
wget --no-check-certificate  $SOURCE_PATH/chat-connect -O chat-connect

if [ $? -ne 0 ]; then
    colored_echo "Download failed" ${RED}
    exit 1; 
fi

wget --no-check-certificate  $SOURCE_PATH/chat-disconnect -O chat-disconnect

if [ $? -ne 0 ]; then
    colored_echo "Download failed" ${RED}
    exit 1; 
fi

wget --no-check-certificate  $SOURCE_PATH/provider -O provider

if [ $? -ne 0 ]; then
    colored_echo "Download failed" ${RED}
    exit 1; 
fi

colored_echo "ppp and wiringpi (gpio tool) installing..."
apt-get install ppp wiringpi -y

mkdir -p /etc/chatscripts

mv chat-connect /etc/chatscripts/
mv chat-disconnect /etc/chatscripts/

mkdir -p /etc/ppp/peers
sed -i "s/#APN/super/" provider
sed -i "s/#DEVICE/ttyUSB3/" provider
mv provider /etc/ppp/peers/provider

if ! (grep -q 'sudo route' /etc/ppp/ip-up ); then
    echo "sudo route add default ppp0" >> /etc/ppp/ip-up
fi

while [ 1 ]
do
	colored_echo "Do you want to activate auto connect/reconnect service at R.Pi boot up? [Y/n]"
	read auto_reconnect

	case $auto_reconnect in
		[Yy]* )    colored_echo "Downloading setup file..."
			  
			wget --no-check-certificate $SOURCE_PATH/$SERVICE_NAME
			wget --no-check-certificate $SOURCE_PATH/functions.sh
			wget --no-check-certificate $SOURCE_PATH/configs.sh
			wget --no-check-certificate $SOURCE_PATH/configure_modem.sh
			wget --no-check-certificate $SOURCE_PATH/$MANAGER_SCRIPT_NAME
			wget --no-check-certificate $SCRIPT_PATH/reconnect_cellulariot -O $RECONNECT_SCRIPT_NAME

			mv functions.sh $PPP_PATH
			mv configs.sh $PPP_PATH
			mv configure_modem.sh $PPP_PATH
			mv $RECONNECT_SCRIPT_NAME $PPP_PATH
			mv $MANAGER_SCRIPT_NAME $PPP_PATH
			mv $SERVICE_NAME /etc/systemd/system/
			  
			systemctl daemon-reload
			systemctl enable $SERVICE_NAME
			  
			break;;
			  
		[Nn]* )    echo -e "${YELLOW}To connect to internet run ${BLUE}\"sudo pon\"${YELLOW} and to disconnect run ${BLUE}\"sudo poff\" ${SET}"
			  break;;
		*)   colored_echo "Wrong Selection, Select among Y or n" ${RED};;
	esac
done

read -p "Press ENTER key to reboot" ENTER
reboot
