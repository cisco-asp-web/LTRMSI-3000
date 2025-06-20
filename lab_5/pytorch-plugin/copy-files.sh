#!/bin/bash

## Delete old files
docker exec -it clab-clus25-dc--host00 rm network_programmer.py
docker exec -it clab-clus25-dc--host00 rm test_dist.py

docker exec -it clab-clus25-dc--host01 rm network_programmer.py
docker exec -it clab-clus25-dc--host01 rm test_dist.py

docker exec -it clab-clus25-dc--host02 rm network_programmer.py
docker exec -it clab-clus25-dc--host02 rm test_dist.py

docker exec -it clab-clus25-dc--host03 rm network_programmer.py
docker exec -it clab-clus25-dc--host03 rm test_dist.py


## Copy updated files
docker cp demo/.env clab-clus25-dc--host00:/app/
docker cp demo/test_plugin.py clab-clus25-dc--host00:/app/
docker cp srv6_plugin.py clab-clus25-dc--host00:/app/
docker cp dist_setup.py clab-clus25-dc--host00:/app/
docker cp controller.py clab-clus25-dc--host00:/app/
docker cp route_programmer.py clab-clus25-dc--host00:/app/

docker cp demo/.env clab-clus25-dc--host01:/app/
docker cp demo/test_plugin.py clab-clus25-dc--host01:/app/
docker cp srv6_plugin.py clab-clus25-dc--host01:/app/
docker cp dist_setup.py clab-clus25-dc--host01:/app/
docker cp controller.py clab-clus25-dc--host01:/app/
docker cp route_programmer.py clab-clus25-dc--host01:/app/

docker cp demo/.env clab-clus25-dc--host02:/app/
docker cp demo/test_plugin.py clab-clus25-dc--host02:/app/
docker cp srv6_plugin.py clab-clus25-dc--host02:/app/
docker cp dist_setup.py clab-clus25-dc--host02:/app/
docker cp controller.py clab-clus25-dc--host02:/app/
docker cp route_programmer.py clab-clus25-dc--host02:/app/

docker cp demo/.env clab-clus25-dc--host03:/app/
docker cp demo/test_plugin.py clab-clus25-dc--host03:/app/
docker cp srv6_plugin.py clab-clus25-dc--host03:/app/
docker cp dist_setup.py clab-clus25-dc--host03:/app/
docker cp controller.py clab-clus25-dc--host03:/app/
docker cp route_programmer.py clab-clus25-dc--host03:/app/