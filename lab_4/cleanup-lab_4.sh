#!/bin/sh

sudo clab destroy -t lab_4-topology.clab.yaml -c
sudo ansible/scripts/del-br.sh

