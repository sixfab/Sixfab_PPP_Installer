#!/bin/bash

source configs.sh

YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[1;34m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
SET='\033[0m'

function debug
{
    ECHO_PARAM=${2:-''}
    echo -e $ECHO_PARAM ${GREEN}$(date "+%Y/%m/%d->${BLUE}%H:%M:%S") ${SET} "$1"
}

function check_network()
{   
    # Check the network is ready
    debug "Checking the network is ready..."

    for i in {1..$NETWORK_CHECK_TIMEOUT}; do
        NETWORK_OK=0

        debug "SIM Status: " "-n" # no line break
        atcom AT+CPIN? | grep "CPIN: READY"
        SIM_READY=$?

        if [[ $SIM_READY -ne 0 ]]; then  atcom AT+CPIN? | grep "CPIN:"; fi


        debug "Network Registeration Status: " "-n" # no line break
        # For super SIM
        atcom AT+CREG? | grep "CREG: 0,5" > /dev/null
        NETWORK_REG=$?
        # For native SIM
        atcom AT+CREG? | grep "CREG: 0,1" > /dev/null
        NETWORK_REG_2=$?
        # Combined network registeration status
        NETWORK_REG=$((NETWORK_REG+NETWORK_REG_2))

        if [[ $NETWORK_REG -ne 0 ]] || [[ $NETWORK_REG_2 -ne 0 ]]; then  atcom AT+CREG? | grep "CREG:"; fi

        if [[ $SIM_READY -eq 0 ]] && [[ $NETWORK_REG -le 1 ]]; then
            debug "Network is ready."
            NETWORK_OK=1
            return 0
            break
        else
            debug "Retrying network registeration..."
        fi
        sleep 2
    done
    debug "Retwork registeration is failed! Please check SIM card, data plan, antennas etc."
    return 1
}
