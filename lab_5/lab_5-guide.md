# Lab 5: SRv6 for Intelligent Load Balancing of AI Workloads [20 Min]

### Description
In Lab 5 we will explore the power of SRv6 as a truly end-to-end technology through host-based SRv6. In this lab our SONiC nodes and their attached Ubuntu containers are simulating an AI Training infrastructure. We don't have any GPUs, but have built a (*very*) simple demo controller that leverages the open-source Jalapeno platform as its backend data warehouse.

Project Jalapeno homepage: https://github.com/cisco-open/jalapeno


## Contents
- [Lab 5: SRv6 for Intelligent Load Balancing of AI Workloads \[20 Min\]](#lab-5-srv6-for-intelligent-load-balancing-of-ai-workloads-20-min)
    - [Description](#description)
  - [Contents](#contents)
    - [Why host-based SRv6?](#why-host-based-srv6)
  - [Lab Objectives](#lab-objectives)
  - [Host-Based SRv6 for Intelligent Fabric Load Balancing](#host-based-srv6-for-intelligent-fabric-load-balancing)
  - [Jalapeno](#jalapeno)
    - [Arango Graph Database](#arango-graph-database)
  - [Jalapeno REST API](#jalapeno-rest-api)
  - [Jalapeno Web UI](#jalapeno-web-ui)
    - [UI Topology Viewer](#ui-topology-viewer)
      - [Workload Scheduling Mode](#workload-scheduling-mode)
      - [SRv6 SID data](#srv6-sid-data)
    - [SRv6 route-add script](#srv6-route-add-script)
      - [Ping tests and Edgshark](#ping-tests-and-edgshark)
    - [Test flows with TRex tool](#test-flows-with-trex-tool)
      - [Grafana Dashboard](#grafana-dashboard)


### Why host-based SRv6? 

* **Flexibility and Control**: We get tremendous control of the SRv6 SIDs and our encapsulation depth isn't subject to ASIC limitations

* **Performance and Massive Scale**: With host-based SRv6 traffic reaches the transport network already encapsulated, thus the ingress PE or SRv6-TE headend doesn't need all the resource intense policy configuration; they just statelessly forward traffic per the SRv6 encapsulation or Network Program
  
* **SRv6 as Common E2E Architecture**: We could extend SRv6 into the Cloud! Or to IoT devices or other endpoints connected to the physical network...
 
We feel this ability to perform SRv6 operations at the host or other endpoint is a game changer which opens up enormous potential for innovation!

## Lab Objectives
The student upon completion of Lab 5 should have achieved the following objectives:

* Understanding of the SRv6 Fabric Load Balancing use case
* Understanding of the SRv6 stack available in Linux
* Understanding of SONiC's SRv6 uSID shift-and-forward capabilities
* Familiarity with the open-source Jalapeno project, its API, and UI

## Host-Based SRv6 for Intelligent Fabric Load Balancing


Recently at the EMEA OCP summit Guohan Lu from Microsoft explained how they build Source Routed AI Backend Networks with SRv6:

https://www.segment-routing.net/conferences/2025-ocp-emea-microsoft-srv6-ai-backend/

The key problem to solve is large, long-lived flows being ECMP'd can result in path collision or hotspots in the fabric. With AI training this can lead to delays or even job failures such that the training run needs to be restarted. Given the cost of running large GPU pools, delay or failure can be very costly indeed.

The solution: coordination of all senders source routing their traffic over disjoint paths through the fabric.

In addition to basic Fabric Load Balancing we also envision the use of SRv6 to partition the network such that tenants' or customers' training jobs do not ever come into conflict across the fabric.

While SRv6-based fabric load balancing seems quite useful for AI backend networks, to date SR/SRv6 have not really been deployed in traditional frontend DC fabrics as ECMP has generally been good enough. However, we do see potential for a similar kind of implementation for the frontend where large flows could load balanced across the fabric using source routing or host-based SRv6

Cisco doesn't currently have a host-based SRv6 controller product and the Hyperscalers build their own SDN control infrastructure, so to demonstrate this capability in the lab we'll leverage the open-source project Jalapeno.

Insert diagram with Jalapeno controller/API interaction


## Jalapeno

The Jalapeno package is preinstalled and running on the **Jalapeno** VM (198.18.128.101).

1. SSH to the Jalapeno VM and display the running k8s pods. Those who are new to Kubernetes can reference this cheat sheet [HERE](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)  

    ```
    ssh cisco@198.18.128.101
    ```
    
    Display k8s pods
    ```
    kubectl get pods -A
    ```
    Note that the Jalapeno VM is also using Cilium as its CNI, and that all of the Jalapeno pods/microservices are running in the **jalapeno** namespace.  Also, the Jalapeno K8s cluster is completely independent of the K8s cluster on the Berlin VM. In our simulation the Berlin VM is a consumer of services on our SRv6 network, which may include services that are accessed by interacting with Jalapeno.


### Arango Graph Database
At the heart of Jalapeno is the Arango Graph Database, which is used to model network topology and provide a graph-based data store for the network data collected via BMP or other sources. 

1. Open the Arango web UI at:

    ```
    http://198.18.128.101:30852/
    ```
    
    Login and select the "jalapeno" DB from the dropdown:
    ```
    user: root
    password: jalapeno
    DB: jalapeno
    ```
    Once logged in the UI will show you its *collections* view. If you like, take a moment to browse around the collections


We've preloaded our fabric topology and relevant SRv6 data in the Jalapeno/ArangoDB instance.

1. Click on the *`fabric_graph`* collection, then select the `content` tab to see data from our topology graph

2. Optional or for reference: connect to the DB and try some of the queries in the [lab_5-arango-queries.md doc](https://github.com/cisco-asp-web/LTRMSI-3000/tree/main/lab_5/lab_5-arango-queries.md)

## Jalapeno REST API

The Jalapeno REST API is used to run queries against the ArangoDB and retrieve graph topology data or execute shortest path calculations. 

1. Optional: test the Jalapeno REST API:
   From the ssh session on the *jalapeno VM* or the *topology-host VM* (or the command line on your local machine) validate the Jalapeno REST API is running. We installed the *`jq`* tool on the *jalapeno VM* to help with improved JSON parsing:
   ```
   curl http://198.18.128.101:30800/api/v1/collections | jq | more
   ```

   The API has auto-generated documentation at: [http://198.18.128.101:30800/docs/](http://198.18.128.101:30800/docs/) 

   The Jalapeno API github repo has a collection of example curl commands as well:

   [Jalapeno API Github](https://github.com/jalapeno/jalapeno-api/blob/main/notes/curl-commands.md)


## Jalapeno Web UI

The Jalapeno UI is a demo or proof-of-concept meant to illustrate the potential use cases for extending SRv6 services beyond traditional network elements and into the server, host, VM, k8s, or other workloads. Once Jalapeno has programmatically collected data from the network and built its topology graphs, the network operator has complete flexibility to add data or augment the graph. In fact, our SONiC *`fabric_graph`* data was simply uploaded from a json file. 

Once the topology graphs are in place its not too difficult to conceive of building network services based on calls to the Jalapeno API and leveraging the SRv6 uSID stacks that are returned.

The Jalapeno Web UI can be accessed at: [http://198.18.128.101:30700](http://198.18.128.101:30700). 

On the left hand sidebar you will see that UI functionality is split into two sections:

- **Data Collections**: explore raw object and graph data collected from the network.
- **Topology Viewer**: explore the network topology graphs and perform path calculations.


### UI Topology Viewer

Layouts
Modes

#### Workload Scheduling Mode

Load balancing API calls
Note the path highlights should be evenly spread
Running multiple attempts (highlighting is still under construction)

#### SRv6 SID data


### SRv6 route-add script

The linux route entries include SRv6 encapsulation instructions per the Linux kernel SRv6 implementation. For more info: https://segment-routing.org/

#### Ping tests and Edgshark

### Test flows with TRex tool

#### Grafana Dashboard




