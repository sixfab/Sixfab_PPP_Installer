#!/bin/bash

source functions.sh

### Modem configuration for RMNET/PPP mode ##################################
debug "Checking APN and Modem Mode..."

# APN
atcom "AT+CGDCONT?" | grep super >> /dev/null

if [[ $? -ne 0 ]]; then
    atcom "AT+CGDCONT=1,\"IP\",\"super\""
    debug "APN is updated."
fi

atcom "AT#USBCFG?" | grep 0 >> /dev/null

if [[ $? -ne 0 ]]; then
    atcom "AT#USBCFG=0"
    debug "RMNET/PPP mode is activated."
    debug "Modem restarting..."

    sleep 20
    
    # Check modem is started!
    for i in {1..120}; do
        route -n | grep wwan0 >> /dev/null
        if [[ $? -eq 0 ]]; then
            echo
            debug "Modem is restarted."
            break
        fi
        sleep 1
        printf "*"
    done
    sleep 5 # wait until modem is ready 
fi
### End of Modem configuration for RMNET/PPP mode ############################