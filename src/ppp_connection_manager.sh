#!/bin/bash

source functions.sh

LOG_FOLDER="./logs"
LOG_FILE_NAME=$(date "+%Y_%m_%d_%H:%M:%S")

if [[ -e $LOG_FOLDER ]]; then
    debug "Log folder already exist!"
else
    sudo mkdir $LOG_FOLDER
    debug "Log folder is created."
fi

for i in {1..4}; do
    bash configure_modem.sh |& sudo tee -a ./logs/$LOG_FILE_NAME.log
    MODEM_CONFIG=${PIPESTATUS[0]}   # compatible with only bash

    if [[ $MODEM_CONFIG -eq 0 ]]; then
        break
    fi
    sleep 1
done

if [[ $MODEM_CONFIG -eq 0 ]]; then
    bash ppp_reconnect.sh |& sudo tee -a ./logs/$LOG_FILE_NAME.log
else
    debug "Modem configuration is failed multiple times!" 
    debug "Checkout other troubleshooting steps on docs.sixfab.com."
    exit 1
fi
