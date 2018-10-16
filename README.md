# Sixfab_PPP_Installer
Repository of Sixfab PPP Installer Tool 

Sixfab offers Shields for Raspberry Pi which provides cellular Internet connection anywhere with the availability of mobile network coverage. These shields are:

* Raspberry Pi GSM/GPRS Shield

* Raspberry Pi 3G-4G/LTE Base Shield V2

* Raspberry Pi Cellular IoT Application Shield



Each of these shield can be connected to Internet via PPP(Point to Point Protocol). For this tutorial we have written an script to install and perform required steps.

Without further ado let us jump into the installation process:

Clone the repository

`git clone https://github.com/sixfab/Sixfab_PPP_Installer.git` 

Now change the permission of the downloaded script.

```
cd Sixfab_PPP_Installer/ppp_installer
chmod +x install.sh
```

Now install the script

`sudo ./install.sh`
  
It will ask several questions, just answer them accordingly to complete the installation process. The questions are:
`Please choose your Sixfab Shield`

You will be offered to choose among the mentioned three shields. Then it will fetch required scripts for you. 
`Do you have updated kernel`

It asks if your kernel is up-to-date. If no[n] it updates the kernel else it skips the update. Then it installs ppp. 

`What is your carrier APN?`

Here, it asks for your carrier's APN. For me it is hologram. 

`Enter your PORT name`

In this step you will enter your PORT. For 3G, 4G/LTE Base Shield it will be ttyUSB3. 

`Do you want to activate auto connect/reconnect service at R.Pi boot up?`

This option allows you to connect to Internet via your shield automatically when your Raspberry Pi Starts. If you want to connect to Internet automatically type Y else n. If you have selected n then you will need to run `sudo pon` to connect to internet and `sudo poff` to stop it. 

Enjoy your Internet connection.
