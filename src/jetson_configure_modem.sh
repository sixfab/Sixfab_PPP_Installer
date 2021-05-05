#!/bin/bash

source functions.sh

# only for "2: 3G, 4G/LTE Base Shield"

# default arguments
APN=${SIM_APN:-super}

### Modem configuration for RMNET/PPP mode ##################################
debug "Checking APN and Modem Modem..."

# APN Configuration
# -----------------
atcom "AT+CGDCONT?" | grep $APN > /dev/null

if [[ $? -ne 0 ]]; then
    atcom "AT+CGDCONT=1,\"IPV4V6\",\"$APN\""
    debug "APN is updated."
fi

# Check the vendor 
# ON JETSON ONLY THE vendor:product ID is SHOWN
lsusb | grep 2c7c >> /dev/null
IS_QUECTEL=$?


# Modem Mode Configuration
# ------------------------
# For Quectel
if [[ $IS_QUECTEL -eq 0 ]]; then

    # Quectel EC25-E
    lsusb | grep 0125 > /dev/null
    MODEL_EC25E=$?

    if [[ $MODEL_EC25E -eq 0 ]]; then
        
        # EC25 or derives.
        atcom "AT+QCFG=\"usbnet\"" | grep 0 > /dev/null

        if [[ $? -ne 0 ]]; then
            atcom "AT+QCFG=\"usbnet\",0"
            debug "PPP mode is activated."
            debug "Modem restarting..."
            
            sleep 20
            
            # Check modem is started
            route -n | grep wwan0 >> /dev/null
            if [[ $? -eq 0 ]]; then
                echo 
            else
                # If modem don't reboot automatically, reset manually 
                atcom "AT+CFUN=1,1" # rebooting modem
                sleep 20
            fi

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
    fi

# Unknown
else
    debug "The cellular module couldn't be detected!"
    exit 1
fi
### End of Modem configuration for RMNET/PPP mode ############################


# Check the network is ready
# --------------------------
if check_network -eq 0; then exit 0; else debug "Network registration is failed!. Modem configuration is unsuccesfully ended!"; exit 1; fi

