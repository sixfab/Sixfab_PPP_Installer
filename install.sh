#!/bin/bash

SIXFAB_PATH="/opt/sixfab"
PPP_PATH="/opt/sixfab/ppp_connection_manager"

REPO_PATH="https://raw.githubusercontent.com/sixfab/Sixfab_PPP_Installer"
BRANCH=revision
SOURCE_PATH="$REPO_PATH/$BRANCH/src"
SCRIPT_PATH="$REPO_PATH/$BRANCH/src/reconnect_scripts"
SCRIPT_NAME="ppp_reconnect.sh"
SERVICE_NAME="ppp_connection_manager.service"

YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[1;34m'
SET='\033[0m'

function debug()
{
    echo $(date "+%Y/%m/%d - %H:%M:%S :") "$1"
}

function colored_echo
{
	COLOR=${2:-$YELLOW}
	echo -e "$COLOR $1 ${SET}"
}


# Check Sixfab path 
if [[ -e $SIXFAB_PATH ]]; then
    debug "Path already exist!"
else
    sudo mkdir $SIXFAB_PATH
    debug "Sixfab path is created."
fi

# Check PPP path 
if [[ -e $PPP_PATH ]]; then
    debug "Path already exist!"
else
    sudo mkdir $PPP_PATH
    debug "PPP path is created."
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

if [ $shield_hat -eq 2 ]; then
	if ! (grep -q 'max_usb_current' /boot/config.txt ); then
		echo "max_usb_current=1" >> /boot/config.txt
	fi
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


			if [ $shield_hat -eq 1 ]; then
			  
				wget --no-check-certificate  $SCRIPT_PATH/reconnect_gprsshield -O $SCRIPT_NAME
			  
			elif [ $shield_hat -eq 2 ]; then 
			  
				wget --no-check-certificate   $SCRIPT_PATH/reconnect_baseshield -O $SCRIPT_NAME
				
			elif [ $shield_hat -eq 3 ]; then 
			  
				wget --no-check-certificate   $SCRIPT_PATH/reconnect_cellulariot_app -O $SCRIPT_NAME
			  
			elif [ $shield_hat -eq 4 ]; then 
			  
				wget --no-check-certificate   $SCRIPT_PATH/reconnect_cellulariot -O $SCRIPT_NAME
			
			elif [ $shield_hat -eq 5 ]; then 
			  
				wget --no-check-certificate   $SCRIPT_PATH/reconnect_tracker -O $SCRIPT_NAME

			elif [ $shield_hat -eq 6 ]; then 
			  
				wget --no-check-certificate   $SCRIPT_PATH/reconnect_basehat -O $SCRIPT_NAME

			  fi
			  
			  mv $SCRIPT_NAME $PPP_PATH
			  mv functions.sh $PPP_PATH
			  mv configs.sh $PPP_PATH
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
