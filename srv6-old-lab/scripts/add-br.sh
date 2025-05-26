#! /bin/bash

sudo brctl addbr leaf00-bridge
sudo brctl addbr leaf01-bridge
sudo brctl addbr leaf02-bridge
sudo brctl addbr leaf03-bridge

sudo ip link set dev leaf00-bridge up
sudo ip link set dev leaf01-bridge up
sudo ip link set dev leaf02-bridge up
sudo ip link set dev leaf03-bridge up

sudo ip addr add 2001:db8:1000:2::2/64 dev leaf00-bridge
sudo ip addr add 2001:db8:1008:2::2/64 dev leaf01-bridge
sudo ip addr add 2001:db8:1016:2::2/64 dev leaf02-bridge
sudo ip addr add 2001:db8:1024:2::2/64 dev leaf03-bridge

