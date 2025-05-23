# Lab 4: SRv6 on SONiC [20 Min]

### Description
From the SONiC homepage: https://sonicfoundation.dev/

*Software for Open Networking in the Cloud (SONiC) is an open source network operating system (NOS) based on Linux that runs on switches from multiple vendors and ASICs. SONiC offers a full suite of network functionality, like BGP and RDMA, that has been production-hardened in the data centers of some of the largest cloud service providers. It offers teams the flexibility to create the network solutions they need while leveraging the collective strength of a large ecosystem and community.*
 
In lab 4 we'll deploy a CLOS topology of SONiC nodes, we'll explore the SONiC/Linux and FRR CLIs, and we'll use Ansible scripts to configure interfaces, BGP, and finally SRv6.

## Contents
- [Lab 4: SRv6 on SONiC \[20 Min\]](#lab-4-srv6-on-sonic-20-min)
    - [Description](#description)
  - [Contents](#contents)
  - [Lab Objectives](#lab-objectives)
  - [Deploy containerlab SONiC topology](#deploy-containerlab-sonic-topology)
    - [Ansible "deploy-playbook"](#ansible-deploy-playbook)
  - [SONiC: A Very Quick Tour](#sonic-a-very-quick-tour)
    - [SONiC Docker Containers](#sonic-docker-containers)
  - [SONiC Configuration Files](#sonic-configuration-files)
    - [config load, config reload, config save](#config-load-config-reload-config-save)
    - [Configure leaf00 from SONiC CLI](#configure-leaf00-from-sonic-cli)
  - [Fabric Config Automation with Ansible](#fabric-config-automation-with-ansible)
    - [Verify SONiC BGP peering](#verify-sonic-bgp-peering)
    - [SONiC SRv6 configuration](#sonic-srv6-configuration)
    - [Configure "ubuntu host" containers attached to SONiC topology](#configure-ubuntu-host-containers-attached-to-sonic-topology)
  - [End of lab 4](#end-of-lab-4)

## Lab Objectives
We will have achieved the following objectives upon completion of Lab 4:

* Understanding of SONiC's architecture and configuration
* Understanding of SONiC FRR/BGP
* Understanding of SONiC's SRv6 configuration and capabilities


## Deploy containerlab SONiC topology
Given its origins in the Hyperscale world, SONiC has been designed from the ground up as an automation friendly NOS. So in this lab we'll make heavy use of task automation with *Ansible*.

### Ansible "deploy-playbook"
The first Ansible playbook is a simple one; it launches the containerlab SONiC topology, and it runs a couple scripts to establish linux test bridges and to reset stored SSH keys.

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

## SONiC: A Very Quick Tour

SONiC is Linux plus a microservices-style architecture comprised of various modules running as Docker containers. These containers comprise what can be thought of as a highly modular *router application suite*. The containers interact and communicate with each other through the Switch State Service (*`swss`*) container. The infrastructure also relies on the use of a *redis-database* engine: a key-value database to provide a language independent interface, a method for data persistence, replication and multi-process communication among all SONiC subsystems.

For a deep dive on SONiC architecture and containers please see: https://sonicfoundation.dev/deep-dive-into-sonic-architecture-design/


1. ssh to leaf00 in our topology (note: password is *`admin`*)
    ```
    ssh admin@clab-sonic-leaf00
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
### SONiC Docker Containers

| Docker Container Name| Description                                                      |
|:---------------------|:-----------------------------------------------------------------|
| BGP                  | Runs FRR [Free Range Routing](https://frrouting.org/) |
| Database             | Hosts the redis-database engine|
| LLDP                 | Hosts LLDP. Includes 3 process *llpd*, *LLDP-syncd*, *LLDPmgr* |
| MGMT-Framework       | North Bound Interfaces (NBIs) for  managing configuration and status|
| PMON                 | Runs *sensord* daemon used to log and alert sensor data |
| RADV                 | Hosts *radv* daemon and handles IPv6 router solicitations / router advertisements |
| SNMP                 | Hosts SNMP feature. *SNMPD* and *SNMP-Agent* |
| SWSS                 | Collection of tools to allow communication among all SONiC modules |
| SYNCD                | Synchronization of the switch's network state with the switch's actual hardware/ASIC |
| TeamD                | Runs open-source implementation of LAG protocol |
| GNMI                 | SONiC gnmi/telemetry service |

1. List SONiC's docker containers. Note, it takes 2-3 minutes from topology deployment for all 12 docker containers to come up. 
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

In addition to normal Linux CLI, SONiC has its own CLI that operates from the Linux shell:

3. Try some SONiC CLI commands:
    ```
    show ?
    show interface status
    show ip interfaces
    show ipv6 interfaces
    show version
    ```

If you would like to explore more we've included a short [SONiC CLI command reference](https://github.com/cisco-asp-web/LTRMSI-3000/blob/main/lab_4/sonic_cli_reference.md)

SONiC leverages the open-source FRR [Free Range Routing](https://frrouting.org/) routing stack for its Control Plane. Currently the only supported routing protocol is BGP, however, FRR supports ISIS and OSPF, so someday in the future we could see SONiC incorporating those protocols as well. 

The *docker ps* output above included a container named **bgp**. In reality this is FRR running as a container.

1. Access **leaf00's** FRR/BGP container via *vtysh*
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

2. FRR looks a whole lot like classic IOS:
    ```
    show run
    show interface brief
    exit
    ```

## SONiC Configuration Files
Configuration state in SONiC is saved in two separate files. The first is the **/etc/sonic/config_db.json** file, which contains global configuration attributes such as hostname, interfaces, IP addresses, etc. The second is the FRR control plane configuration at **/etc/sonic/frr/bgpd.conf**.

### config load, config reload, config save

**config load**

The command *config load* is used to load a configuration following the JSON schema. This command loads the configuration from the input file, which defaults to */etc/sonic/config_db.json*, unless specified otherwise.The configuration present in the input file overwrites the already running configuration. This command does not flush the config DB before loading the new configuration, rather it performs a *diff* on the existing and applies the new. 

- Usage:
```
config load [-y|--yes] [<filename>]
```
- Example:
```
admin@sonic::~$ sudo config load
Load config from the file /etc/sonic/config_db.json? [y/N]: y
Running command: /usr/local/bin/sonic-cfggen -j /etc/sonic/config_db.json --write-to-db
```

**config reload**

This command is used to clear current configuration and import new configurationn from the input file or from */etc/sonic/config_db.json*. This command shall stop all services before clearing the configuration and it then restarts those services.

The command *config reload* restarts various services/containers running in the device and it takes some time to complete the command.

- Usage:
```
config reload [-y|--yes] [-l|--load-sysinfo] [<filename>] [-n|--no-service-restart] [-f|--force]
```

**config save**

The command *config save* is used to save the redis CONFIG_DB into the user-specified filename or into the default /etc/sonic/config_db.json. This is analogous to the Cisco IOS command *copy run start*. 

Saved files can be transferred to remote machines for debugging. If users wants to load the configuration from this new file at any point of time, they can use the *config load* command and provide this newly generated file as input. 

- Usage:
```
config save [-y|--yes] [<filename>]
```
- Example (Save configuration to /etc/sonic/config_db.json):

```
admin@sonic::~$ sudo config save -y
```

- Example (Save configuration to a specified file):
```
admin@sonic::~$ sudo config save -y /etc/sonic/config2.json
```

**Edit Configuration Through CLI**

The SONiC CLI can also be used to apply non-control plane configurations. From the Linux shell enter *config* and the command syntax needed. 
```
admin@sonic::~$ config ?
Usage: config [OPTIONS] COMMAND [ARGS]...

  SONiC command line - 'config' command
```

### Configure leaf00 from SONiC CLI

Before we proceed with applying full fabric configurations via Ansible, we wanted to demonstrate SONiC CLI by partially configuring **leaf00**

1. ssh to *leaf00* (password is `admin`)
    ```
    ssh admin@clab-sonic-leaf00
    ```

2. Configure hostname and *Loopback0* IPv4 and IPv6 addresses
   ```
   sudo config hostname leaf00
   sudo config interface ip add Loopback0 10.0.0.200/32
   sudo config interface ip add Loopback0 fc00:0:1200::1/128
   ```

Our SONiC fabric will use IPv6 link local addresses for the BGP underlay, so we only need to configure IPs for the host-facing interface Ethernet16.

3. Configure interface Ethernet16 IPv4 and IPv6
   ```
   sudo config interface ip add Ethernet16 200.0.100.1/24
   sudo config interface ip add Ethernet16 2001:db8:1000:1::1/64
   ```

4. Save configuration
   ```
   sudo config save
   ```
   
5. Exit the sonic node and ssh back in to see the hostname change in effect

6. Do a quick verification of interface IP:
   ```
   show ip interfaces 
   ```

   Example output:
   ```
   admin@leaf00:~$ show ip int
   Interface    Master    IPv4 address/mask    Admin/Oper    BGP Neighbor    Neighbor IP
   -----------  --------  -------------------  ------------  --------------  -------------
   Ethernet16             200.0.100.1/24       up/up         N/A             N/A
   Loopback0              10.0.0.200/32        up/up         N/A             N/A
   docker0                240.127.1.1/24       up/down       N/A             N/A
   eth0                   10.0.0.15/24         up/up         N/A             N/A
   lo                     127.0.0.1/16         up/up         N/A             N/A
   ```

**Manual Configuration of FRR**

Configuring SONiC's BGP container can be done from the command line and is very much like IOS.

1. Invoke FRR's VTY shell
   ```
   vtysh
   ```

2. Enter configuration mode
   ```
   conf t
   ```

3. This particular SONiC image was pre-configured with a BGP instance. We'll delete that instance first, then apply the config we want:
   ```
   no router bgp 65100
   ```

4. Copy **leaf00's** FRR config [LINK](https://github.com/cisco-asp-web/LTRMSI-3000/blob/main/lab_4/sonic-config/leaf00/frr.conf) and paste it into the terminal

5. Save the config
   ```
   write mem
   ```

6. Optional: run some *show* commands:
   ```
   show run
   show bgp summary
   show interface brief
   ```   

You may have noticed in the FRR config or show command output that SONiC supports eBGP unnumbered peering over its Ethernet interfaces. This is a huge advantage for deploying, automating, and managing hyperscale fabrics, and we wanted to highlight it here. 

Config example from leaf00:

   ```
   neighbor Ethernet0 interface remote-as 65000
   neighbor Ethernet4 interface remote-as 65001
   neighbor Ethernet8 interface remote-as 65002
   neighbor Ethernet12 interface remote-as 65003
   ```

## Fabric Config Automation with Ansible 

We'll use Ansible and execute the [sonic-playbook.yaml](https://github.com/cisco-asp-web/LTRMSI-3000/blob/main/lab_4/ansible/sonic-playbook.yaml) to complete the configuration of our SONiC fabric. This playbook executes a number of tasks including:

* Copy each node's *config_db.json* file to the */etc/sonic/* directory [Example spine00/config_db.json](https://github.com/cisco-asp-web/LTRMSI-3000/blob/main/lab_4/sonic-config/spine00/config_db.json)
* Load the config to activate the new settings
* Run SONiC's hostname shell script to apply the node's hostname
* Copy over and run a loopback shell script that we've created for each node [Example spine00 loopback.sh](https://github.com/cisco-asp-web/LTRMSI-3000/blob/main/lab_4/sonic-config/spine00/loopback.sh)
* Save the config
* Create and activate a loopback interface called **sr0** on each node. This loopback is needed for SONiC SRv6 functionality
* Use the Ansible built-in command plugin to enter the FRR/BGP container and delete the pre-existing default BGP config
* Copy and load FRR configs, which include BGP and SRv6 attributes, to each node; [Example spine00 frr.conf](https://github.com/cisco-asp-web/LTRMSI-3000/blob/main/lab_4/sonic-config/spine00/frr.conf)


1. cd into the lab_4 directory and execute the *sonic-playbook.yaml*
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

Keep your *vtysh* session open on any **leaf** router and:

1. Check SONiC SRv6 configuration
   ```
   show run
   ```

   Example SRv6 config output from leaf00:
   ```
   segment-routing
    srv6
      static-sids
      sid fc00:0:1200::/48 locator MAIN behavior uN                      <-- Locator behavior "uN"
      sid fc00:0:1200:fe04::/64 locator MAIN behavior uDT4 vrf default   <-- static uDT4 function for prefixes in the default ipv4 table
      sid fc00:0:1200:fe06::/64 locator MAIN behavior uDT6 vrf default   <-- static uDT6 function for prefixes in the default ipv6 table    
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

2. Check locator/sid-manager status 
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
    ```
    ```
    ip -6 route
    ```

    Note all the entries with `*proto bgp src*` - these are routes (including ECMP!) learned from BGP and installed in the linux routing table

4. Run the ip -6 route command again and grep for the local routes for the node's locator:

    ```
    ip -6 route | grep seg6local
    ```

    Example output:
    ```
    admin@leaf00:~$ ip -6 route | grep seg6local
    fc00:0:1200::/48 nhid 63  encap seg6local action End flavors next-csid lblen 32 nflen 16 dev sr0 proto 196 metric 20 pref medium

### Configure "ubuntu host" containers attached to SONiC topology

In addition to configuring our SONiC fabric nodes, the *sonic-playbook.yaml* script also ran the `host-routes.sh` shell script located in the lab_4/ansible/scripts directory. This script added ip address and route entries to the Ubuntu containers attached to our SONiC topology. The linux static route entries point to the remote *ubuntu host* containers in our topology, with the directly connected SONiC leaf node as the nexthop.

1. Verify host IPs and routes

    From the topology host execute *docker exec* commands to display the ip addresses and routing table of ubuntu-host00:

    ```
    docker exec -it clab-sonic-host00 ip addr show dev eth1 | grep inet
    ```
    ```
    docker exec -it clab-sonic-host00 ip -6 route
    ```

    Expected output:
    ```
    cisco@topology-host:$ docker exec -it clab-sonic-host00 ip addr show dev eth1 | grep inet
    inet 200.0.100.2/24 scope global eth1
    inet6 2001:db8:1000::2/64 scope global 
    inet6 fe80::a8c1:abff:feb4:ba48/64 scope link

    cisco@topology-host:$ docker exec -it clab-sonic-host00 ip -6 route
    2001:db8:1000::/64 dev eth1 proto kernel metric 256 pref medium
    2001:db8:1024::/64 via 2001:db8:1000::1 dev eth1 metric 1024 pref medium   <--- v6 test route to ubuntu-host24
    fc00::/32 via 2001:db8:1000::1 dev eth1 metric 1024 pref medium
    fe80::/64 dev eth1 proto kernel metric 256 pref medium
    fe80::/64 dev eth2 proto kernel metric 256 pref medium
    ```

2. Ping test from *ubuntu-host00* to *ubuntu-host24*:

    ```
    docker exec -it clab-sonic-host00 ping 2001:db8:1024::2 -i .3 -c 4
    ```

## End of lab 4
Please proceed to [Lab 5: Host Based SRv6](https://github.com/cisco-asp-web/LTRMSI-3000/blob/main/lab_5/lab_5-guide.md)

