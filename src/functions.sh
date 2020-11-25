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

        debug "SIM Status:"
        atcom AT+CPIN? | grep "CPIN: READY"
        SIM_READY=$?

        debug "Network Registeration Status:"
        # For super SIM
        atcom AT+CREG? | grep "CREG: 0,5"
        NETWORK_REG=$?
        # For native SIM
        atcom AT+CREG? | grep "CREG: 0,1"
        NETWORK_REG_2=$?
        # Combined network registeration status
        NETWORK_REG=$((NETWORK_REG+NETWORK_REG_2))

        if [[ $SIM_READY -eq 0 ]] && [[ $NETWORK_REG -le 1 ]]; then
            debug "Network is ready."
            NETWORK_OK=1
            return 0
            break
        else
            printf "?"
        fi
        sleep 2
    done
    return 1
}
