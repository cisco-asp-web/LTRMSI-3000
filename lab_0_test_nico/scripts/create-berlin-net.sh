#!/bin/bash

# Exit if already exists
ip link show berlin-net &>/dev/null && exit 0

# Create the bridge
ip link add name berlin-net type bridge
ip link set dev berlin-net up

# Add the IP address to the bridge for Berlin VMs default route
ip addr add 198.18.4.3/24 dev berlin-net

# Add the iptables rule to SNAT Berlin outbound traffic to the Internet
sudo iptables -t nat -A POSTROUTING -o ens160 -j MASQUERADE