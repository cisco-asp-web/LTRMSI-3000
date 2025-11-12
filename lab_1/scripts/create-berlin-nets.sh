#!/bin/bash

# Exit if already exists
ip link show berlin-net0 &>/dev/null && exit 0

# Create the bridge
ip link add name berlin-net0 type bridge
ip link set dev berlin-net0 up

# Add the IP address to the bridge for Berlin VMs default route
ip addr add 10.8.0.3/24 dev berlin-net

ip link show berlin-net1 &>/dev/null && exit 0

# Create the bridge
ip link add name berlin-net1 type bridge
ip link set dev berlin-net1 up

# Add the IP address to the bridge for Berlin VMs default route
ip addr add 10.8.1.3/24 dev berlin-net1

ip link show berlin-net2 &>/dev/null && exit 0

# Create the bridge
ip link add name berlin-net2 type bridge
ip link set dev berlin-net2 up

# Add the IP address to the bridge for Berlin VMs default route
ip addr add 10.8.2.3/24 dev berlin-net2

ip link show berlin-net3 &>/dev/null && exit 0

# Create the bridge
ip link add name berlin-net3 type bridge
ip link set dev berlin-net3 up

# Add the IP address to the bridge for Berlin VMs default route
ip addr add 10.8.3.3/24 dev berlin-net3
    
# Add the iptables rule to SNAT Berlin outbound traffic to the Internet
sudo iptables -t nat -A POSTROUTING -o ens160 -j MASQUERADE