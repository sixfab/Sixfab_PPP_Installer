#!/bin/env bash

source functions.sh
source config.sh

echo "PING TIMEOUT: " $PING_TIMEOUT
echo "DOUBLE CHECK WAIT: " $DOUBLE_CHECK_WAIT
echo "INTERVAL: " $INTERVAL

check_network