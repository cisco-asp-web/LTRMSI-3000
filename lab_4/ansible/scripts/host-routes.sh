#!/bin/sh

# IP addresses and routes

## host00
docker exec -it clab-sonic-host00 ip addr add 200.0.100.2/24 dev eth1
docker exec -it clab-sonic-host00 ip addr add 2001:db8:1000:0::2/64 dev eth1
docker exec -it clab-sonic-host00 ip -6 route add fc00:0::/32 via 2001:db8:1000:0::1 dev eth1
docker exec -it clab-sonic-host00 ip route add 200.0.0.0/8 via 200.0.100.1 dev eth1
docker exec -it clab-sonic-host00 ip route
docker exec -it clab-sonic-host00 ip -6 route

## host08
docker exec -it clab-sonic-host08 ip addr add 200.8.100.2/24 dev eth1
docker exec -it clab-sonic-host08 ip addr add 2001:db8:1008:0::2/64 dev eth1
docker exec -it clab-sonic-host08 ip -6 route add fc00:0::/32 via 2001:db8:1008:0::1 dev eth1
docker exec -it clab-sonic-host08 ip route add 200.0.0.0/8 via 200.8.100.1 dev eth1
docker exec -it clab-sonic-host08 ip route
docker exec -it clab-sonic-host08 ip -6 route

## host16
docker exec -it clab-sonic-host16 ip addr add 200.16.100.2/24 dev eth1
docker exec -it clab-sonic-host16 ip addr add 2001:db8:1016:0::2/64 dev eth1
docker exec -it clab-sonic-host16 ip -6 route add fc00:0::/32 via 2001:db8:1016:0::1 dev eth1
docker exec -it clab-sonic-host16 ip route add 200.0.0.0/8 via 200.16.100.1 dev eth1
docker exec -it clab-sonic-host16 ip route
docker exec -it clab-sonic-host16 ip -6 route

## host24
docker exec -it clab-sonic-host24 ip addr add 200.24.100.2/24 dev eth1
docker exec -it clab-sonic-host24 ip addr add 2001:db8:1024:0::2/64 dev eth1
docker exec -it clab-sonic-host24 ip -6 route add fc00:0::/32 via 2001:db8:1024:0::1 dev eth1
docker exec -it clab-sonic-host24 ip route add 200.0.0.0/8 via 200.24.100.1 dev eth1
docker exec -it clab-sonic-host24 ip route
docker exec -it clab-sonic-host24 ip -6 route

