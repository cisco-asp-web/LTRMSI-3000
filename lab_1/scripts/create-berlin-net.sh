#!/bin/bash

# Exit if already exists
ip link show berlin-net &>/dev/null && exit 0
ip link show warsaw-net &>/dev/null && exit 0

# Create the bridge
ip link add name berlin-net type bridge
ip link set dev berlin-net up

ip link add name warsaw-net type bridge
ip link set dev warsaw-net up

# Add the IP address to the bridge for Berlin VMs default route
ip addr add 10.1.2.3/24 dev berlin-net
ip addr add 10.1.2.11/24 dev warsaw-net

# Add the iptables rule to SNAT Berlin and Warsaw outbound traffic to the Internet
sudo iptables -t nat -A POSTROUTING -o ens160 -j MASQUERADE