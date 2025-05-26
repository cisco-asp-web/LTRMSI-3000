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
  - [SRv6 Fabric Load Balancing](#srv6-fabric-load-balancing)
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

## SRv6 Fabric Load Balancing

Use case writeup

Insert diagram with Jalapeno controller/API interaction


## Jalapeno

The Jalapeno package is preinstalled and running on the **Jalapeno** VM (198.18.128.101).

1. SSH to the Jalapeno VM and verify k8s pods are running. For those students new to Kubernetes you can reference this cheat sheet [HERE](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)  

    ```
    ssh cisco@198.18.128.101
    ```
    
    Verify k8s pods
    ```
    kubectl get pods -A
    ```
    The output should look something like the truncated output below. Note that the Jalapeno VM is also using Cilium as its CNI, and that all of the Jalapeno pods/microservices are running in the **jalapeno** namespace.  Also, the Jalapeno K8s cluster is completely independent of the K8s cluster on the Berlin VM. In our simulation the Berlin VM is a consumer of services on our SRv6 network, which may include services that are accessed by interacting with Jalapeno.

    ```yaml
    cisco@jalapeno:~/jalapeno/install$ kubectl get pods -A
    NAMESPACE     NAME                                           READY   STATUS    RESTARTS         AGE
    jalapeno      arangodb-0                                     1/1     Running   0                86s
    jalapeno      gobmp-5db68bd644-dgg7w                         1/1     Running   1 (44s ago)      78s
    jalapeno      grafana-deployment-565756bd74-d26pj            1/1     Running   0                86s
    jalapeno      influxdb-0                                     1/1     Running   0                86s
    jalapeno      jalapeno-api-5d8469557-gpz8j                   1/1     Running   0                85s
    jalapeno      jalapeno-ui-54f8f95c5d-pn79v                   1/1     Running   0                84s
    jalapeno      kafka-0                                        1/1     Running   0                87s
    jalapeno      lslinknode-edge-b954577f9-w46gf                1/1     Running   3 (53s ago)      72s
    jalapeno      telegraf-egress-deployment-5795ffdd9c-7xjj4    1/1     Running   0                73s
    jalapeno      telegraf-ingress-deployment-5b456574dc-vlnvq   1/1     Running   0                79s
    jalapeno      topology-678ddb8bb4-klzmt                      1/1     Running   1 (41s ago)      73s
    jalapeno      zookeeper-0                                    1/1     Running   0                87s
    kube-system   cilium-k8fht                                   1/1     Running   3 (4h41m ago)    363d
    kube-system   cilium-operator-6f5db4f885-nmpwb               1/1     Running   3 (4h41m ago)    363d
  
    ```

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
    Once logged the UI should then show you its *collections* view, which should look something like:
   <img src="images/arango-collections.png" width="1000">


We've preloaded our fabric topology and relevant SRv6 data in Jalapeno's backend graph database (ArangoDB)

2. Click on the *`fabric_graph`* collection, then select the `content` tab to see data from our topology graph

3. Optional or for reference: feel free to connect to the DB and try some of the queries in the [lab_5-arango-queries.md doc](https://github.com/cisco-asp-web/LTRMSI-3000/tree/main/lab_5/lab_5-arango-queries.md)

## Jalapeno REST API

The Jalapeno REST API is used to run queries against the ArangoDB and retrieve graph topology data or execute shortest path calculations. 

1. Optional: test the Jalapeno REST API:
   From the ssh session on the Jalapeno VM or the XRD VM (or the command line on your local machine) validate the Jalapeno REST API is running. We installed the *`jq`* tool to help with improved JSON parsing:
   ```
   curl http://198.18.128.101:30800/api/v1/collections | jq | more
   ```

   The API also has auto-generated documentation at: [http://198.18.128.101:30800/docs/](http://198.18.128.101:30800/docs/) 

2. The Jalapeno API github repo has a collection of example curl commands as well:

    [Jalapeno API Github](https://github.com/jalapeno/jalapeno-api/blob/main/notes/curl-commands.md)


## Jalapeno Web UI

The Jalapeno UI is a demo or proof-of-concept meant to illustrate the potential use cases for extending SRv6 services beyond traditional network elements and into the server, host, VM, k8s, or other workloads. Once Jalapeno has programmatically collected data from the network and built its topology graphs, the network operator has complete flexibility to add data or augment the graph as we saw in the previous section. From there, its not too difficult to conceive of building network services based on calls to the Jalapeno API and leveraging the SRv6 uSID stacks that are returned.

Each lab instance has a Jalapeno Web UI that can be accessed at the following URL: [http://198.18.128.101:30700](http://198.18.128.101:30700). 

On the left hand sidebar you will see that UI functionality is split into three sections:

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




