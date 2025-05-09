# Lab 4: SRv6 on SONiC [20 Min]

### Description
Enter description
 


## Contents
- [Lab 4: SRv6 on SONiC \[20 Min\]](#lab-4-srv6-on-sonic-20-min)
    - [Description](#description)
  - [Contents](#contents)
  - [Lab Objectives](#lab-objectives)
  - [Deploy containerlab SONiC topology](#deploy-containerlab-sonic-topology)
    - [Ansible "deploy-playbook"](#ansible-deploy-playbook)
    - [SONiC: a very quick tour](#sonic-a-very-quick-tour)
  - [Manual configuration of leaf00](#manual-configuration-of-leaf00)
      - [Should we bother, or do all automated config?](#should-we-bother-or-do-all-automated-config)
  - [Fabric config automation with Ansible](#fabric-config-automation-with-ansible)
    - [Verify SONiC BGP peering](#verify-sonic-bgp-peering)
    - [SONiC SRv6 configuration](#sonic-srv6-configuration)
    - [Configure "ubuntu host" containers attached to SONiC topology](#configure-ubuntu-host-containers-attached-to-sonic-topology)
    - [SRv6 ping test](#srv6-ping-test)
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
   ```

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

#### Should we bother, or do all automated config?



## Fabric config automation with Ansible 
We'll run our fabric config automation with the [sonic-playbook.yaml](ansible/sonic-playbook.yaml) playbook. This playbook executes a number of tasks including:

* Copy each nodes' config_db.json file to the /etc/sonic/ directory [Example leaf00/config_db.json](sonic-config/leaf00/config_db.json)
* Load the config to activate the new settings
* Run SONiC's hostname shell script to apply the new nodes' hostname
* Copy over and run a loopback shell script that we've created for each node [Example loopback.sh](sonic-config/leaf00/loopback.sh)
* Save the config
* Create and activate a loopback interface called **sr0** on each node. This loopback is needed for SONiC SRv6 functionality
* Use the Ansible built-in command plugin to enter the FRR/BGP container and delete the pre-existing default BGP config
* Copy and load our fabric FRR/BGP configs to each node [Example frr.conf](sonic-config/leaf00/frr.conf)


1. cd into the lab_4/ansible directory and execute the *sonic-playbook.yaml*
    ```
    cd ~/LTRMSI-3000/lab_4/ansible

    ansible-playbook -i hosts sonic-playbook.yaml -e "ansible_user=admin ansible_ssh_pass=admin ansible_sudo_pass=admin" -vv
    ```

    The sonic playbook produces a lot of console output, by the time it completes we expect to see something like this:

    ```
    PLAY RECAP *************************************************************************************
    leaf00   : ok=14   changed=12   unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
    leaf01   : ok=14   changed=12   unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
    leaf02   : ok=14   changed=12   unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
    leaf03   : ok=14   changed=12   unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
    spine00  : ok=14   changed=12   unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
    spine01  : ok=14   changed=12   unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
    spine02  : ok=14   changed=12   unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
    spine03  : ok=14   changed=12   unreachable=0    failed=0    skipped=0    rescued=0    ignored=0 
    ``` 

### Verify SONiC BGP peering

SONiC supports eBGP unnumbered peering over its Ethernet interfaces. Example from leaf00:

    ```
    neighbor Ethernet0 interface remote-as 65000
    neighbor Ethernet4 interface remote-as 65001
    neighbor Ethernet8 interface remote-as 65002
    neighbor Ethernet12 interface remote-as 65003
    ```

1. ssh to one or more SONiC nodes and spot check BGP peering (user: admin, pw: admin)
    ```
    ssh admin@clab-sonic-leaf00
    ssh admin@clab-sonic-leaf01

    ssh admin@clab-sonic-spine00
    ssh admin@clab-sonic-spine01
    etc.
    ```

    ```
    vtysh
    ```
    ```
    show bgp summary
    ```
    Expected output from leaf00:
    ```
    leaf00# show bgp summary 

    IPv6 Unicast Summary:
    BGP router identifier 10.0.0.200, local AS number 65200 VRF default vrf-id 0
    BGP table version 58
    RIB entries 47, using 6016 bytes of memory
    Peers 4, using 80 KiB of memory

    Neighbor        V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt Desc
    Ethernet0       4      65000        54        40       58    0    0 00:14:43           17       28 N/A
    Ethernet4       4      65001        99        36       58    0    0 00:14:41           17       28 N/A
    Ethernet8       4      65002        63        36       58    0    0 00:14:41           17       28 N/A
    Ethernet12      4      65003        80        36       58    0    0 00:14:41           17       28 N/A

    Total number of neighbors 4
    ```
    
### SONiC SRv6 configuration

1. Check SONiC SRv6 configuration
   ```
   show run
   ```

   Example SRv6 config output from leaf00:
   ```
   segment-routing
    srv6
      static-sids
      sid fc00:0:1200::/48 locator MAIN behavior uN                       <-- Locator behavior "uN"
      sid fc00:0:1200:fe00::/64 locator MAIN behavior uDT4 vrf default    <-- static uDT4 function for prefixes in the default table
      exit
      !
    exit
    !
    srv6
      encapsulation
      source-address fc00:0:1200::1
      locators
      locator MAIN
        prefix fc00:0:1200::/48 block-len 32 node-len 16 func-bits 16
        behavior usid
      exit
      !
      exit
      !
      formats
      format usid-f3216
      exit
      !
      format uncompressed-f4024
      exit
    ```

2. Check locator/sid-manager status - 'show run' to see the applied SRv6 configuration
    ```
    show segment-routing srv6 locator 
    show segment-routing srv6 manager
    ```

    Expected output:
    ```
    leaf00# show segment-routing srv6 locator 
    Locator:
    Name                 ID      Prefix                   Status
    -------------------- ------- ------------------------ -------
    MAIN                       1 fc00:0:1200::/48         Up

    leaf00# show segment-routing srv6 manager 
    Parameters:
      Encapsulation:
        Source Address:
          Configured: fc00:0:1200::1
    ```

3. Exit the FRR/BGP container and take a look at the linux ipv6 routing table:

    ```
    exit
    ip -6 route
    ```

    Note all the entries with 'proto bgp src', aka routes learned from BGP and installed in the linux routing table

4. Run the ip -6 route command again and grep for the nodes' locator:

    ```
    ip -6 route | grep seg6local
    ```

    Example output:
    ```
    admin@leaf00:~$ ip -6 route | grep seg6local
    fc00:0:1200::/48 nhid 63  encap seg6local action End flavors next-csid lblen 32 nflen 16 dev sr0 proto 196 metric 20 pref medium

### Configure "ubuntu host" containers attached to SONiC topology


### SRv6 ping test


## End of lab 4
Please proceed to [Lab 5](https://github.com/cisco-asp-web/LTRMSI-3000/blob/main/lab_5/lab_5-guide.md)

