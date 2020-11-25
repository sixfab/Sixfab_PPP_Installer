#!/bin/bash

source functions.sh

# Check the vendor
lsusb | grep Quectel >> /dev/null
IS_QUECTEL=$?

lsusb | grep Telit >> /dev/null
IS_TELIT=$?


### Modem configuration for RMNET/PPP mode ##################################
debug "Checking APN and Modem Mode..."

# APN Configuration
# -----------------
atcom "AT+CGDCONT?" | grep super >> /dev/null

if [[ $? -ne 0 ]]; then
    atcom "AT+CGDCONT=1,\"IPV4V6\",\"super\""
    debug "APN is updated."
fi

# Modem Mode Configuration
# ------------------------
# For Quectel
if [[ $IS_QUECTEL -eq 0 ]]; then

    lsusb | grep BG9 > /dev/null
    MODEL_BG9X=$?

    if [[ $MODEL_BG9X -eq 0 ]]; then
        # BG95 and BG96

        # RAT Searching Sequence
        atcom "AT+QCFG=\"nwscanseq\"" | grep 000201 >> /dev/null

        if [[ $? -ne 0 ]]; then
            atcom "AT+QCFG=\"nwscanseq\",00"
            debug "Configure RAT Searching Sequence is updated."
        fi

        # RAT(s) to be Searched
        atcom "AT+QCFG=\"nwscanmode\"" | grep 0 >> /dev/null

        if [[ $? -ne 0 ]]; then
            atcom "AT+QCFG=\"nwscanmode\",0"
            debug "RAT(s) to be Searched is updated."
        fi

        # Network Category to be Searched under LTE RAT
        atcom "AT+QCFG=\"iotopmode\"" | grep 0 >> /dev/null

        if [[ $? -ne 0 ]]; then
            atcom "AT+QCFG=\"iotopmode\",0"
            debug "Network Category to be Searched under LTE RAT is updated."
        fi

        # end of configuraiton for BG95/6
    else
        # EC25 or derives.
        atcom "AT+QCFG=\"usbnet\"" | grep 0 >> /dev/null

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

# For Telit 
elif [[ $IS_TELIT -eq 0 ]]; then
    atcom "AT#USBCFG?" | grep 0 >> /dev/null

    if [[ $? -ne 0 ]]; then
        atcom "AT#USBCFG=0"
        debug "PPP mode is activated."
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

# Unknown
else
    debug "The cellular module couldn't be detected!"
    exit 1
fi
### End of Modem configuration for ECM mode ############################


# Check the network is ready
# --------------------------
if check_network -eq 0; then exit 0; else debug "Network registeration is failed!"; exit 1; fi

