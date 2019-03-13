#!/bin/sh

# Configuration parameters
interface="enp5s0u2u1"
status="up"

# Turn off interface
if [[ $1 = $interface ]]; then
    if [[ $2 = $status ]]; then
      ip link set enp5s0u2u1 down
    fi
fi
