#!/bin/env bash

source functions.sh
source configs.sh


if check_network -eq 0; then 
    debug "PPP chatscript is starting...";
    sudo pon;
else 
    debug "Network registeration is failed!";
fi 

while true; do
    # Checking cellular internet connection
    ping -q -c 1 -s 0 -w $PING_TIMEOUT -I ppp0 8.8.8.8 > /dev/null 2>&1
    PINGG=$?

    if [[ $PINGG -eq 0 ]]; then
        printf "."
    else
        printf "/"
        sleep $DOUBLE_CHECK_WAIT
	    # Checking cellular internet connection
        ping -q -c 1 -s 0 -w $PING_TIMEOUT -I ppp0 8.8.8.8 > /dev/null 2>&1
        PINGG=$?

        if [[ $PINGG -eq 0 ]]; then
            printf "+"
        else
	        debug "Connection is down, reconnecting..."
            if check_network -eq 0; then sleep 0.1; else debug "Network registeration is failed!"; fi
	        sudo pon
	    fi
    fi
	sleep $INTERVAL
done
