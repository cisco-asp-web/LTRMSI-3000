# Welcome to LTMSI-3000: Modern AI networks: IOS-XR, SRv6, Cilium, and SONiC

## Introduction: 

In this immersive hands-on lab, explore how to build SRv6 WAN networks utilizing L3VPNs, next-generation AI networking fabrics using SRv6, Kubernetes-native SRv6 with Cilium, and open-source data center technologies. You’ll explore a new way to architect, program, and optimize traffic in high-performance compute environments using Cisco IOS-XR and SONiC. This lab session walks participants through a series of progressive tutorials and labs covering:

 - SRv6 fundamentals and foundational building blocks for SRv6 L3VPN and Traffic Engineering 

 - Kubernetes integration using Cilium and SRv6 for modern service-aware routing 
  
 - SONiC-based data center fabric bring-up and host-based SRv6 
  
 - Programmatic traffic control using custom SRv6 mappings and intelligent automation 
  
Participants will gain practical skills in deploying flexible, scalable, and programmable infrastructure purpose-built for AI, HPC, or cloud-native workloads. Whether you’re a network engineer, cloud architect, or AI infrastructure specialist, this session bridges the gap between architecture and hands-on implementation.

## Contents
* Repository Overview [LINK](#github-repository-overview)
* Lab Topology [LINK](#dCloud-lab-Topology)
* Lab 1 - XRd Topology Setup and base SRv6 Config [LINK](https://github.com/cisco-asp-web/LTRMSI-3000/blob/main/lab_1/lab_1-guide.md)
* Lab 2 - SRv6 L3VPN and SRv6 TE Configuration [LINK](https://github.com/cisco-asp-web/LTRMSI-3000/blob/main/lab_2/lab_2-guide.md)
* Lab 3 - Kubernetes SRv6 with Cilium [LINK](https://github.com/cisco-asp-web/LTRMSI-3000/blob/main/lab_3/lab_3-guide.md)
* Lab 4 - SONiC DC Fabric Bring Up [LINK](https://github.com/cisco-asp-web/LTRMSI-3000/blob/main/lab_4/lab_4-guide.md)
* Lab 5 - SONiC and Host Based SRv6 for Intelligent Fabric Load Balancing [LINK](https://github.com/cisco-asp-web/LTRMSI-3000/blob/main/lab_5/lab_5-guide.md)


## Github Repository Overview
Each of the labs is designed to be completed in the order presented. Lab 1 will launch our XRd topology with baseline configurations. In each subsequent lab (2-3) we'll add SRv6 configurations on network and host devices. In lab 4-5 we switch to SONIC to discover new AI use cases for backend networks utilizing SRv6.

### Root Directory

| File Name      | Description                                                         |
|:---------------|:--------------------------------------------------------------------|
| ansible        | Ansible scripts to update the lab at bootup                         |
| topo_drawings  | Lab diagrams folder                                                 |
| util           | Utility scripts                                                     |
| lab_1 -> lab_5 | Individual lab folders                                              |


### Individual Lab Directories
Within each lab directory you should see several files of importance:
(X = lab #)

| File Name                | Description                                                  |
|:-------------------------|:-------------------------------------------------------------|
| cleanup-lab_X.sh         | Cleans up the containerlab topology and files                |
| lab_X-topology.yaml       | YAML input file for containerlab to create the topology      |
| lab_X-guide.md           | User guide for this lab                                      |


> [!NOTE]
> We've recently launched a whole series of SRv6 labs on github, many of which are built on XRd:
> 
> https://github.com/segmentrouting/srv6-labs


# dCloud Instances 

Each lab instance is running on Cisco dCloud and is reachable via AnyConnect VPN. In the Webex Teams room for the lab we've provided a spreadsheet with a list of dCloud instances and the AnyConnect credentials necessary to access each instance. To find your dCloud instance please reference your student number provided on the handout in class.


# dCloud lab Topology

The following diagram shows the dCloud VM topology that will be used for this lab:

![dCloud Topology](./topo_drawings/dcloud-topology.png)

This lab environment provides a hands-on experience with modern, programmable network infrastructures using modular technologies: SONiC, XRd, Containerlab, Edgeshark, and Jalapeno.

To support this, we are using four virtual machines, each with a specific role. Here’s what each VM is responsible for:


## 💻 Lab Virtual Machines Summary

| VM Name              | IP Address       | Role / Description                                                                                                     | Key Tools / Use Cases                                                                                          |
|----------------------|------------------|------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------|
| **Topology Host**    | `198.18.133.100` | Core lab environment host that runs network topologies using SONiC and XRd via Containerlab                           | - `Containerlab` to define and deploy topologies (`*.clab.yaml`)<br>- `Edgeshark` for in-container packet captures |
| **Jalapeno Host**    | `198.18.128.101` | Hosts **Project Jalapeno**, an SDN controller framework focused on tunnel-based and graph-driven control planes       | - SDN automation & path computation<br>- Real-time topology modeling<br>- Graph database ingestion              |
| **Windows Management** | `198.18.128.102` | RDP-accessible Windows VM for student interaction with the lab                                                        | - Lab documentation access<br>- VS Code with SSH and extensions:<br> &nbsp;&nbsp;• Start/stop topologies<br> &nbsp;&nbsp;• Capture traffic<br> &nbsp;&nbsp;• Access containers and Linux hosts |


## 🔐 Lab VM Credentials

| VM Name               | Username   | Password       |
|-----------------------|------------|----------------|
| **Windows Management**| `admin`    | `C1sco12345`   | 
| **Topology Host**     | `cisco`    | `C1sco12345`   | 
| **Jalapeno Host**     | `cisco`    | `C1sco12345`   | 


## Navigate through the labs.

1. Connect to your dCloud instance VPN

![VPN](./topo_drawings/anyconnect.png)

Once you've connected to VPN all nodes in the lab can be accessed using a Remote Desktop connection to the windows management hosts at 198.18.128.102 (admin / C1sco12345)

![windows-rdpy](./topo_drawings/windows-rdp.png)

On the Windows virtual machine, please launch firefox you shoud arrive on the github page automatically. Please proceed to [LAB 1](https://github.com/cisco-asp-web/LTRMSI-3000/blob/main/lab_1/lab_1-guide.md)
