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

1. cd into the lab_4 directory and run the *deploy-playbook*

   ```
   cd ~/LTRMSI-3000/lab_4/ 

   ansible-playbook -i ansible/hosts ansible/deploy-playbook.yaml -e "ansible_user=cisco ansible_ssh_pass=cisco123 ansible_sudo_pass=cisco123" -vv
   ```




## Manual configuration of leaf00

## Fabric config automation with Ansible 

### Verify SONiC BGP peering


## End of lab 4
Please proceed to [Lab 5](https://github.com/cisco-asp-web/LTRMSI-3000/blob/main/lab_5/lab_5-guide.md)

