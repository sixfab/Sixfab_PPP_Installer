# Sixfab_PPP_Installer
Repository of Sixfab PPP Installer Tool 

Sixfab offers Shields/HATs for Raspberry Pi which provides cellular Internet connection anywhere with the availability of mobile network coverage. These shields are:

* [Raspberry Pi GSM/GPRS Shield](https://www.sixfab.com/product/gsmgprs-shield/)

* [Raspberry Pi 3G-4G/LTE Base Shield V2](https://www.sixfab.com/product/raspberry-pi-3g-4glte-base-shield-v2/)

* [Raspberry Pi Cellular IoT Application Shield](https://www.sixfab.com/product/raspberry-pi-cellular-iot-application-hat/)

* [Raspberry Pi Cellular IoT HAT ](https://sixfab.com/product/raspberry-pi-lte-m-nb-iot-egprs-cellular-hat/) 

* [Raspberry Pi Tracker HAT ](https://sixfab.com/product/raspberry-pi-gprs-gps-tracker-hat/)

* [Raspberry Pi 3G/4G&LTE Base HAT](https://sixfab.com/product/raspberry-pi-base-hat-3g-4g-lte-minipcie-cards/)

Each of these shield can be connected to Internet via PPP(Point to Point Protocol). For this tutorial we have written an script to install and perform required steps.

Without further ado let us jump into the installation process:

There are two method to installation.
1. Standalone installation 
2. Installation by using repository 

You can choose one of them and go on the installation. 

## Standalone Installation

All source files are downloded from internet in this method. It is enough to download **ppp_install_standalone.sh** and run it.

```
wget https://raw.githubusercontent.com/sixfab/Sixfab_PPP_Installer/master/ppp_install_standalone.sh
sudo chmod +x ppp_install_standalone.sh
sudo ./ppp_install_standalone.sh
```

## Installation by using repository 

Clone the repository

`git clone https://github.com/sixfab/Sixfab_PPP_Installer.git` 

Now change the permission of the downloaded script.

```
cd Sixfab_PPP_Installer
chmod +x ppp_install.sh
```

Now install the script

`sudo ./ppp_install.sh`


## After running installation script
It will ask several questions, just answer them accordingly to complete the installation process. The questions are:
`Please choose your Sixfab Shield/HAT`
 
You will be offered to choose among the mentioned four shields/HAT. Then it will fetch required scripts for you. 

Then it installs ppp. 

`What is your carrier APN?`

Here, it asks for your carrier's APN. For me it is `super`. Because I use Sixfab SIM. Please search it on documentations of your SIM provider . You can reach the information by using `WHAT IS [YOUR PROVIDER NAME]'s APN` keywords probably.

`Does your carrier need username and password? [Y/n]`

Then it asks if your carrier needs username and password. 

`Enter username`
If yes then it will ask for user name.

`Enter password`
Then it will ask for password.

`What is your device communication PORT? (ttyS0/ttyUSB3/etc.`

In this step you will enter your PORT. e.g For 3G, 4G/LTE Base Shield it will be ttyUSB3.

`Do you want to activate auto connect/reconnect service at R.Pi boot up?`

This option allows you to connect to Internet via your shield automatically when your Raspberry Pi Starts. If you want to connect to Internet automatically type Y else n. If you have selected n then you will need to run `sudo pon` to connect to internet and `sudo poff` to stop it. 

Enjoy your Internet connection.

Important Links: 
* [Linux PPP HOW TO](https://tldp.org/HOWTO/PPP-HOWTO/index.html)
* [PAP CHAP authentications](https://tldp.org/HOWTO/PPP-HOWTO/pap.html)
