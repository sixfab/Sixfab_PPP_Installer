#!/bin/env bash

function debug()
{
    echo $(date "+%Y/%m/%d - %H:%M:%S :") "$1"
}

function check_network()
{   
    NETWORK_TIMEOUT=300     # Check network for ($NETWORK_TIMEOUT x 2 Seconds)     

    # Check the network is ready
    debug "Checking the network is ready..."

    for i in {1..$NETWORK_TIMEOUT}; do
        NETWORK_OK=0

        debug "SIM Status:"
        atcom AT+CPIN? OK ERROR 10 | grep "CPIN: READY"
        SIM_READY=$?

        debug "Network Registeration Status:"
        # For super SIM
        atcom AT+CREG? OK ERROR 10 | grep "CREG: 0,5"
        NETWORK_REG=$?
        # For native SIM
        atcom AT+CREG? OK ERROR 10 | grep "CREG: 0,1"
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
