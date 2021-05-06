#!/bin/bash

source functions.sh

for i in {1..4}; do
    bash jetson_configure_modem.sh
    
    if [[ $MODEM_CONFIG -eq 0 ]]; then
        break
    fi
    sleep 1
done