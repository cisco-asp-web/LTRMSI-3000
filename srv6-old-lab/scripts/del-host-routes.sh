#! /bin/bash

docker exec -it clab-sonic-host00 ip route del 200.8.100.0/24
docker exec -it clab-sonic-host00 ip route del 200.16.100.0/24
docker exec -it clab-sonic-host00 ip route del 200.24.100.0/24

docker exec -it clab-sonic-host00 ip -6 route del 2001:db8:1000::/64
docker exec -it clab-sonic-host00 ip -6 route del 2001:db8:1008::/64
docker exec -it clab-sonic-host00 ip -6 route del 2001:db8:1024::/64

docker exec -it clab-sonic-host08 ip route del 200.0.100.0/24
docker exec -it clab-sonic-host08 ip route del 200.16.100.0/24
docker exec -it clab-sonic-host08 ip route del 200.24.100.0/24

docker exec -it clab-sonic-host08 ip -6 route del 2001:db8:1000::/64
docker exec -it clab-sonic-host08 ip -6 route del 2001:db8:1016::/64
docker exec -it clab-sonic-host08 ip -6 route del 2001:db8:1024::/64

docker exec -it clab-sonic-host16 ip route del 200.0.100.0/24
docker exec -it clab-sonic-host16 ip route del 200.8.100.0/24
docker exec -it clab-sonic-host16 ip route del 200.24.100.0/24

docker exec -it clab-sonic-host16 ip -6 route del 2001:db8:1000::/64
docker exec -it clab-sonic-host16 ip -6 route del 2001:db8:1008::/64
docker exec -it clab-sonic-host16 ip -6 route del 2001:db8:1024::/64

docker exec -it clab-sonic-host24 ip route del 200.0.100.0/24
docker exec -it clab-sonic-host24 ip route del 200.8.100.0/24
docker exec -it clab-sonic-host24 ip route del 200.16.100.0/24

docker exec -it clab-sonic-host24 ip -6 route del 2001:db8:1000::/64
docker exec -it clab-sonic-host24 ip -6 route del 2001:db8:1008::/64
docker exec -it clab-sonic-host24 ip -6 route del 2001:db8:1016::/64
