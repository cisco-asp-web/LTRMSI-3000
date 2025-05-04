#!/bin/sh

sudo ip link set leaf00-bridge down
sudo ip link set leaf01-bridge down
sudo ip link set leaf02-bridge down
sudo ip link set leaf03-bridge down
sudo brctl delbr leaf00-bridge
sudo brctl delbr leaf01-bridge
sudo brctl delbr leaf02-bridge
sudo brctl delbr leaf03-bridge