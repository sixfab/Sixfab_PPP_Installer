#!/bin/bash

# Created on July 12, 2019 by Saeed Johar (saeedjohar)
# Revised on November 19, 2020 by Yasin Kaya (selengalp) 

source src/functions.sh

SIXFAB_PATH="/opt/sixfab"
PPP_PATH="/opt/sixfab/ppp_connection_manager"

# NEEDS TO BE CHANGED TO SIXFAB IF PULLED
REPO_PATH="https://raw.githubusercontent.com/bzt/Sixfab_PPP_Installer"
BRANCH=master
SOURCE_PATH="$REPO_PATH/$BRANCH/src"
SCRIPT_PATH="$REPO_PATH/$BRANCH/src/reconnect_scripts"
MANAGER_SCRIPT_NAME="jetson_ppp_connection_manager.sh"
SERVICE_NAME="jetson_ppp_connection_manager.service"
UDEV_RULE_NAME="20-usb-bus.rules"

YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[1;34m'
SET='\033[0m'


function colored_echo
{
	COLOR=${2:-$YELLOW}
	echo -e "$COLOR$1 ${SET}"
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

colored_echo "Please choose your Sixfab Shield/HAT:"
colored_echo "1: GSM/GPRS Shield"
colored_echo "2: 3G, 4G/LTE Base Shield"
colored_echo "3: Cellular IoT App Shield"
colored_echo "4: Cellular IoT HAT"
colored_echo "5: Tracker HAT"
colored_echo "6: 3G/4G Base HAT"

read shield_hat
case $shield_hat in
    1)    colored_echo "You chose GSM/GPRS Shield";;
    2)    colored_echo "You chose Base Shield";;
    3)    colored_echo "You chose CellularIoT Shield";;
    4)    colored_echo "You chose CellularIoT HAT";;
	5)    colored_echo "You chose Tracker HAT";;
	6)    colored_echo "You chose 3G/4G Base HAT";;
    *)    colored_echo "Wrong Selection, exiting" ${RED}; exit 1;
esac

colored_echo "Checking requiremments..."

colored_echo "Installing python3 if it is required..."
if ! [ -x "$(command -v python3)" ]; then
  sudo apt-get install python3 -y >/dev/null
fi

colored_echo "Installing pip3 if it is required..."
if ! [ -x "$(command -v pip3)" ]; then
  sudo apt-get install python3-pip -y >/dev/null
fi

colored_echo "Installing or upgrading atcom if it is required..."
pip3 install -U atcom && source ~/.profile


colored_echo "Downloading setup files..."
wget --no-check-certificate  $SOURCE_PATH/chat-connect -O chat-connect
if [[ $? -ne 0 ]]; then colored_echo "Download failed" ${RED}; exit 1; fi

wget --no-check-certificate  $SOURCE_PATH/chat-disconnect -O chat-disconnect
if [[ $? -ne 0 ]]; then colored_echo "Download failed" ${RED}; exit 1; fi

wget --no-check-certificate  $SOURCE_PATH/provider -O provider
if [[ $? -ne 0 ]]; then colored_echo "Download failed" ${RED}; exit 1; fi

colored_echo "ppp installing"
apt-get install ppp -y

colored_echo "What is your carrier APN?"
read carrierapn 

while [ 1 ]
do
	colored_echo "Does your carrier need username and password? [Y/n]"
	read usernpass
	
	case $usernpass in
		[Yy]* )  while [ 1 ] 
        do 
        
        colored_echo "Enter username"
        read username

        colored_echo "Enter password"
        read password
        sed -i "s/noauth/#noauth\nuser \"$username\"\npassword \"$password\"/" provider
        break 
        done

        break;;
		
		[Nn]* )  break;;
		*)  colored_echo "Wrong Selection, Select among Y or n" ${RED};;
	esac
done

colored_echo "What is your device communication PORT? (ttyS0/ttyUSB3/etc.)"
read devicename 

mkdir -p /etc/chatscripts

mv chat-connect /etc/chatscripts/
mv chat-disconnect /etc/chatscripts/

mkdir -p /etc/ppp/peers
sed -i "s/#APN/$carrierapn/" provider
sed -i "s/#DEVICE/$devicename/" provider
mv provider /etc/ppp/peers/provider


if ! (grep -q 'sudo route' /etc/ppp/ip-up ); then	
    echo "sudo route add default ppp0" >> /etc/ppp/ip-up	
fi

while [ 1 ]
do
	colored_echo "Do you want to activate auto connect service at boot up? [Y/n]"
	read auto_reconnect

	colored_echo "You chose $auto_connect" ${GREEN} 

	case $auto_reconnect in
		[Yy]* )    colored_echo "Copying setup file..."
			  
			wget --no-check-certificate  $SOURCE_PATH/$SERVICE_NAME -O $SERVICE_NAME
			if [[ $? -ne 0 ]]; then colored_echo "Download failed" ${RED}; exit 1; fi
			
			wget --no-check-certificate  $SOURCE_PATH/functions.sh -O functions.sh
			if [[ $? -ne 0 ]]; then colored_echo "Download failed" ${RED}; exit 1; fi
			
			wget --no-check-certificate  $SOURCE_PATH/configs.sh -O configs.sh
			if [[ $? -ne 0 ]]; then colored_echo "Download failed" ${RED}; exit 1; fi
			
			wget --no-check-certificate  $SOURCE_PATH/jetson_configure_modem.sh -O jetson_configure_modem.sh
			if [[ $? -ne 0 ]]; then colored_echo "Download failed" ${RED}; exit 1; fi
			
			wget --no-check-certificate  $SOURCE_PATH/$MANAGER_SCRIPT_NAME -O $MANAGER_SCRIPT_NAME
			if [[ $? -ne 0 ]]; then colored_echo "Download failed" ${RED}; exit 1; fi

			wget --no-check-certificate  $SOURCE_PATH/$UDEV_RULE_NAME -O $UDEV_RULE_NAME
			if [[ $? -ne 0 ]]; then colored_echo "Download failed" ${RED}; exit 1; fi
			
			# APN Configuration
			sed -i "s/SIM_APN/$carrierapn/" jetson_configure_modem.sh

			# Devicename
			sed -i "s/DEVICE/$devicename/" jetson_configure_modem.sh
			sed -i "s/DEVICE/$devicename/" functions.sh
  
			mv functions.sh $PPP_PATH
			mv configs.sh $PPP_PATH
			mv jetson_configure_modem.sh $PPP_PATH
			mv $MANAGER_SCRIPT_NAME $PPP_PATH
			mv $SERVICE_NAME /etc/systemd/system/
			mv $UDEV_RULE_NAME /etc/udev/rules.d/

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
