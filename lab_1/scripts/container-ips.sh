#!/bin/bash

# Amsterdam eth1 - global table
echo "Setting up Amsterdam eth1 ip addresses and routes"
docker exec -it clab-clus25-amsterdam ip addr add 10.101.1.2/24 dev eth1
docker exec -it clab-clus25-amsterdam ip addr add fc00:0:101:1::2/64 dev eth1
docker exec -it clab-clus25-amsterdam ip route add 10.107.1.0/24 via 10.101.1.1
docker exec -it clab-clus25-amsterdam ip route add 20.0.0.0/24 via 10.101.1.1
docker exec -it clab-clus25-amsterdam ip route add 30.0.0.0/24 via 10.101.1.1
docker exec -it clab-clus25-amsterdam ip -6 route add fc00:0000::/32 via fc00:0:101:1::1
docker exec -it clab-clus25-amsterdam ip addr show eth1

# Amsterdam eth2 - vrf carrots
echo "Setting up Amsterdam eth2 ip addresses and routes"
docker exec -it clab-clus25-amsterdam ip addr add 10.101.2.2/24 dev eth2
docker exec -it clab-clus25-amsterdam ip addr add fc00:0:101:2::2/64 dev eth2
docker exec -it clab-clus25-amsterdam ip route add 10.107.2.0/24 via 10.101.2.1
docker exec -it clab-clus25-amsterdam ip route add 40.0.0.0/24 via 10.101.2.1
docker exec -it clab-clus25-amsterdam ip route add 50.0.0.0/24 via 10.101.2.1
docker exec -it clab-clus25-amsterdam ip -6 route add fc00:0000:40::/64 via fc00:0:101:2::1
docker exec -it clab-clus25-amsterdam ip -6 route add fc00:0000:50::/64 via fc00:0:101:2::1
docker exec -it clab-clus25-amsterdam ip addr show eth2
docker exec -it clab-clus25-amsterdam ip route

# Rome eth1 - global table
echo "Setting up Rome eth1 ip addresses and routes"
docker exec -it clab-clus25-rome ip addr add 10.107.1.2/24 dev eth1
docker exec -it clab-clus25-rome ip addr add fc00:0:107:1::2/64 dev eth1
docker exec -it clab-clus25-rome ip route add 10.101.1.0/24 via 10.107.1.1
docker exec -it clab-clus25-rome ip -6 route add fc00:0000::/32 via fc00:0:107:1::1
docker exec -it clab-clus25-rome ip addr show eth1

# Rome eth2 - vrf carrots
echo "Setting up Rome eth2 ip addresses and routes"
docker exec -it clab-clus25-rome ip addr add 10.107.2.2/24 dev eth2
docker exec -it clab-clus25-rome ip addr add fc00:0:107:2::2/64 dev eth2
docker exec -it clab-clus25-rome ip route add 10.101.2.0/24 via 10.107.2.1
docker exec -it clab-clus25-rome ip addr show eth2
docker exec -it clab-clus25-rome ip route



