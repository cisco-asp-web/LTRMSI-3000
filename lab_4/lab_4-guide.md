# Lab 4: SRv6 on SONiC [30 Min]

### Description
Enter description
 


## Contents
- [Lab 4: SRv6 on SONiC \[30 Min\]](#lab-4-srv6-on-sonic-30-min)
    - [Description](#description)
  - [Contents](#contents)
  - [Lab Objectives](#lab-objectives)
  - [Deploy containerlab SONiC topology](#deploy-containerlab-sonic-topology)
    - [Ansible "deploy-playbook"](#ansible-deploy-playbook)
    - [SONiC: a very quick tour](#sonic-a-very-quick-tour)
  - [Manual configuration of leaf00](#manual-configuration-of-leaf00)
  - [Fabric config automation with Ansible](#fabric-config-automation-with-ansible)
    - [Verify SONiC BGP peering](#verify-sonic-bgp-peering)
  - [End of lab 4](#end-of-lab-4)

## Lab Objectives
We will have achieved the following objectives upon completion of Lab 4:

* Understanding of SONiC's architecture and configuration
* Understanding of SONiC FRR/BGP
* Understanding of SONiC's SRv6 configuration and capabilities


## Deploy containerlab SONiC topology
Given its origins in the Hyperscale world, SONiC has been designed from the ground up as an automation friendly NOS. So in this lab we'll make heavy use of task automation with Ansible.

### Ansible "deploy-playbook"
The first Ansbible playbook is a simple one; it launches the containerlab SONiC topology, and it runs a couple scripts to establish linux test bridges and to reset stored SSH keys.

[deploy-playbook](ansible/deploy-playbook.yaml)

1. cd into the lab_4/ansible directory and run the *deploy-playbook*

   ```
   cd ~/LTRMSI-3000/lab_4/ansible

   ansible-playbook -i hosts deploy-playbook.yaml -e "ansible_user=cisco ansible_ssh_pass=cisco123 ansible_sudo_pass=cisco123" -vv
   ```
   
   Once the script completes the end-summary of the output should look like this:
   ```
   PLAY RECAP ****************************************************************************
   localhost   : ok=4  changed=3  unreachable=0  failed=0  skipped=0  rescued=0  ignored=0   


### SONiC: a very quick tour
1. ssh to leaf00 in our topology (note: password is 'admin')
    ```
    ssh admin@clab-sonic-leaf00
    
    admin
    ```

    Expected output:
    ```
    cisco@topology-host:~/LTRMSI-3000/lab_4/ansible$ ssh admin@clab-sonic-leaf00
    Warning: Permanently added 'clab-sonic-leaf00' (RSA) to the list of known hosts.
    Debian GNU/Linux 12 \n \l

    admin@clab-sonic-leaf00's password: 
    Linux sonic 6.1.0-22-2-amd64 #1 SMP PREEMPT_DYNAMIC Debian 6.1.94-1 (2024-06-21) x86_64
    You are on
      ____   ___  _   _ _  ____
     / ___| / _ \| \ | (_)/ ___|
     \___ \| | | |  \| | | |
      ___) | |_| | |\  | | |___
     |____/ \___/|_| \_|_|\____|

    -- Software for Open Networking in the Cloud --

    Unauthorized access and/or use are prohibited.
    All access and/or use are subject to monitoring.

    Help:    https://sonic-net.github.io/SONiC/

    Last login: Sun May  4 20:51:27 2025
    admin@sonic:~$
    ```

2. List the SONiC docker containers
    ```
    docker ps
    ```

    Expected output:
    ```
    admin@sonic:~$ docker ps
    CONTAINER ID   IMAGE                                COMMAND                  CREATED         STATUS         PORTS     NAMES
    fd325f9f71a3   docker-snmp:latest                   "/usr/bin/docker-snm…"   4 minutes ago   Up 4 minutes             snmp
    83abaaeb0eda   docker-platform-monitor:latest       "/usr/bin/docker_ini…"   4 minutes ago   Up 4 minutes             pmon
    07b16407200a   docker-sonic-mgmt-framework:latest   "/usr/local/bin/supe…"   4 minutes ago   Up 4 minutes             mgmt-framework
    e92cfef2d1a7   docker-lldp:latest                   "/usr/bin/docker-lld…"   4 minutes ago   Up 4 minutes             lldp
    e039e0c50696   docker-sonic-gnmi:latest             "/usr/local/bin/supe…"   4 minutes ago   Up 4 minutes             gnmi
    0eb9d4243f43   docker-router-advertiser:latest      "/usr/bin/docker-ini…"   6 minutes ago   Up 6 minutes             radv
    a802d70ada48   docker-fpm-frr:latest                "/usr/bin/docker_ini…"   6 minutes ago   Up 6 minutes             bgp
    c6bd49fba18d   docker-syncd-vpp:latest              "/usr/local/bin/supe…"   6 minutes ago   Up 6 minutes             syncd
    81ea6a8d2eba   docker-teamd:latest                  "/usr/local/bin/supe…"   6 minutes ago   Up 6 minutes             teamd
    98c4bb45296b   docker-orchagent:latest              "/usr/bin/docker-ini…"   6 minutes ago   Up 6 minutes             swss
    5459d7bc624a   docker-eventd:latest                 "/usr/local/bin/supe…"   6 minutes ago   Up 6 minutes             eventd
    bab374f5a2b5   docker-database:latest               "/usr/local/bin/dock…"   6 minutes ago   Up 6 minutes             database
    ```

3. Try some SONiC CLI commands:
    ```
    show ?
    show interface status
    show ip interfaces
    show ipv6 interfaces
    show version
    ```

4. Access the FRR/BGP container via *vtysh*
    ```
    vtysh
    ```

    Expected output:
    ```
    admin@sonic:~$ vtysh

    Hello, this is FRRouting (version 10.0.1).
    Copyright 1996-2005 Kunihiro Ishiguro, et al.

    2025/05/04 21:01:06 [YDG3W-JND95] FD Limit set: 1048576 is stupidly large.  Is this what you intended?  Consider using --limit-fds also limiting size to 100000
    sonic# 
    ```

5. FRR looks a whole lot like classic IOS:
    ```
    show run
    show interface brief
    exit
    ```


## Manual configuration of leaf00

## Fabric config automation with Ansible 

1. cd into the lab_4/ansible directory and execute the *sonic-playbook.yaml*
    ```
    cd ~/LTRMSI-3000/lab_4/ansible

    ansible-playbook -i hosts sonic-playbook.yaml -e "ansible_user=admin ansible_ssh_pass=admin ansible_sudo_pass=admin" -vv
    ```

### Verify SONiC BGP peering


## End of lab 4
Please proceed to [Lab 5](https://github.com/cisco-asp-web/LTRMSI-3000/blob/main/lab_5/lab_5-guide.md)

