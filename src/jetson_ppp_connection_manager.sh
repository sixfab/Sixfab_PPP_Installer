#!/bin/bash

source functions.sh

for i in {1..4}; do
    bash jetson_configure_modem.sh
    WAS_SUCCESSFUL=$?
    
    
    if [[ $WAS_SUCCESSFUL -eq 0 ]]; then
        debug "Jetson configure modem successful"
    else
        debug "Jetson configure modem failed: Exit code = $WAS_SUCCESSFUL"
        exit 1
    fi
    
    if [[ $MODEM_CONFIG -eq 0 ]]; then
        break
    fi
    sleep 1
done
