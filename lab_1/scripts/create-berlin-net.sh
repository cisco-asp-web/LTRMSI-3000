#!/bin/bash

# Exit if already exists
ip link show berlin-net &>/dev/null && exit 0

# Create the bridge
ip link add name berlin-net type bridge
ip link set dev berlin-net up

