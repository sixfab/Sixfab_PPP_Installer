#!/bin/sh

YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[1;34m'
SET='\033[0m'

echo "${YELLOW}Please choose your Sixfab Shield/HAT:${SET}"
echo "${YELLOW}1: GSM/GPRS Shield${SET}"
echo "${YELLOW}2: 3G, 4G/LTE Base Shield${SET}"
echo "${YELLOW}3: Cellular IoT App Shield${SET}"
echo "${YELLOW}4: Cellular IoT HAT${SET}"

read shield_hat
case $shield_hat in
    1)    echo "${YELLOW}You chose GSM/GPRS Shield${SET}";;
    2)    echo "${YELLOW}You chose Base Shield${SET}";;
    3)    echo "${YELLOW}You chose CellularIoT Shield${SET}";;
    4)    echo "${YELLOW}You chose CellularIoT HAT${SET}";;
    *)    echo "${RED}Wrong Selection, exiting${SET}"; exit 1;
esac

if [ $shield_hat -eq 3 ] || [ $shield_hat -eq 4 ];	then
	echo "${YELLOW}Please choose LTE Technology:${SET}"
	echo "${YELLOW}1: GPRS/EDGE${SET}"
	echo "${YELLOW}2: CATM1${SET}"
	echo "${YELLOW}3: NB-IoT${SET}"

	read network_technology
	case $network_technology in
		1)    echo "${YELLOW}You chose GPRS/EDGE${SET}"
				EXTRA='OK AT+QCFG="band",F,400A0E189F,A0E189F,1\nOK AT+QCFG="nwscanseq",01,1\nOK AT+QCFG="nwscanmode",1,1\nOK AT+QCFG="iotopmode",2,1';;
		2)    echo "${YELLOW}You chose CATM1${SET}"
				EXTRA='OK AT+QCFG="band",F,400A0E189F,A0E189F,1\nOK AT+QCFG="nwscanseq",02,1\nOK AT+QCFG="nwscanmode",3,1\nOK AT+QCFG="iotopmode",0,1';;
		3)    echo "${YELLOW}You chose NB-IoT${SET}"
				EXTRA='OK AT+QCFG="band",F,400A0E189F,A0E189F,1\nOK AT+QCFG="nwscanseq",03,1\nOK AT+QCFG="nwscanmode",3,1\nOK AT+QCFG="iotopmode",1,1';;
		*) 	  echo "{RED}Wrong Selection, exiting${SET}"; exit 1;
	esac
fi

echo "${YELLOW}Downloading setup files${SET}"
wget --no-check-certificate  https://raw.githubusercontent.com/sixfab/Sixfab_PPP_Installer/master/ppp_installer/chat-connect -O chat-connect

if [ $? -ne 0 ]; then
    echo "${RED}Download failed${SET}"
    exit 1; 
fi

wget --no-check-certificate  https://raw.githubusercontent.com/sixfab/Sixfab_PPP_Installer/master/ppp_installer/chat-disconnect -O chat-disconnect

if [ $? -ne 0 ]; then
    echo "${RED}Download failed${SET}"
    exit 1;
fi

wget --no-check-certificate  https://raw.githubusercontent.com/sixfab/Sixfab_PPP_Installer/master/ppp_installer/provider -O provider

if [ $? -ne 0 ]; then
    echo "${RED}Download failed${SET}"
    exit 1;
fi

while [ 1 ]
do
	echo "${YELLOW}Do you have updated kernel? [Y/n] ${SET}"
	read kernelUpdate
	
	case $kernelUpdate in
		[Yy]* )  break;;
		
		[Nn]* )  echo "${YELLOW}rpi-update${SET}"
			rpi-update
		    break;;
		*)  echo "${RED}Wrong Selection, Select among Y or n${SET}";;
	esac
done

echo "${YELLOW}ppp install${SET}"
apt-get install ppp

echo "${YELLOW}What is your carrier APN?${SET}"
read carrierapn 

while [ 1 ]
do
	echo "${YELLOW}Does your carrier need username and password? [Y/n]${SET}"
	read usernpass
	
	case $usernpass in
		[Yy]* )  while [ 1 ] 
        do 
        
        echo "${YELLOW}Enter username${SET}"
        read username

        echo "${YELLOW}Enter password${SET}"
        read password
        sed -i "s/noauth/#noauth\nuser \"$username\"\npassword \"$password\"/" provider
        break 
        done

        break;;
		
		[Nn]* )  break;;
		*)  echo "${RED}Wrong Selection, Select among Y or n${SET}";;
	esac
done

echo "${YELLOW}What is your device communication PORT? (ttyS0/ttyUSB3/etc.)${SET}"
read devicename 

mkdir -p /etc/chatscripts
if [ $shield_hat -eq 3 ] || [ $shield_hat -eq 4 ]; then
  sed -i "s/#EXTRA/$EXTRA/" chat-connect
else
  sed -i "/#EXTRA/d" chat-connect
fi

mv chat-connect /etc/chatscripts/
mv chat-disconnect /etc/chatscripts/

mkdir -p /etc/ppp/peers
sed -i "s/#APN/$carrierapn/" provider
sed -i "s/#DEVICE/$devicename/" provider
mv provider /etc/ppp/peers/provider

if ! (grep -q 'route' /etc/ppp/ip-up ); then
    echo "sudo route del default" >> /etc/ppp/ip-up
    echo "sudo route add default ppp0" >> /etc/ppp/ip-up
fi

if [ $shield_hat -eq 2 ]; then
	if ! (grep -q 'max_usb_current' /boot/config.txt ); then
		echo "max_usb_current=1" >> /boot/config.txt
	fi
fi

while [ 1 ]
do
	echo "${YELLOW}Do you want to activate auto connect/reconnect service at R.Pi boot up? [Y/n] ${SET}"
	read auto_reconnect

	case $auto_reconnect in
		[Yy]* )    echo "${YELLOW}Downloading setup file${SET}"
			  
			  wget --no-check-certificate https://raw.githubusercontent.com/sixfab/Sixfab_PPP_Installer/master/ppp_installer/reconnect_service -O reconnect.service
			  
			  if [ $shield_hat -eq 1 ]; then
			  
				wget --no-check-certificate  https://raw.githubusercontent.com/sixfab/Sixfab_PPP_Installer/master/ppp_installer/reconnect_gprsshield -O reconnect.sh
			  
			  elif [ $shield_hat -eq 2 ]; then 
			  
				wget --no-check-certificate  https://raw.githubusercontent.com/sixfab/Sixfab_PPP_Installer/master/ppp_installer/reconnect_baseshield -O reconnect.sh
				
			  elif [ $shield_hat -eq 3 ]; then 
			  
				wget --no-check-certificate  https://raw.githubusercontent.com/sixfab/Sixfab_PPP_Installer/master/ppp_installer/reconnect_cellulariot_app -O reconnect.sh
			  
			  elif [ $shield_hat -eq 4 ]; then 
			  
				wget --no-check-certificate  https://raw.githubusercontent.com/sixfab/Sixfab_PPP_Installer/master/ppp_installer/reconnect_cellulariot -O reconnect.sh
			  fi
			  
			  mv reconnect.sh /usr/src/
			  mv reconnect.service /etc/systemd/system/
			  
			  
			  systemctl daemon-reload
			  systemctl enable reconnect.service
			  
			  break;;
			  
		[Nn]* )    echo "${YELLOW}To connect to internet run ${BLUE}\"sudo pon\"${YELLOW} and to disconnect run ${BLUE}\"sudo poff\" ${SET}"
			  break;;
		*)   echo "${RED}Wrong Selection, Select among Y or n${SET}";;
	esac
done

read -p "Press ENTER key to reboot" ENTER
reboot