# Lab 5: SRv6 for Intelligent Load Balancing of AI Workloads [20 Min]

### Description
In Lab 5 we will explore the power of SRv6 as a truly end-to-end technology through host-based SRv6. In this lab our SONiC nodes and their attached Ubuntu containers are simulating an AI Training infrastructure. We don't have any GPUs, but have built a simple controller that leverages the open-source Jalapeno platform as its backend data warehouse.

Project Jalapeno homepage: https://github.com/cisco-open/jalapeno


## Contents
- [Lab 5: SRv6 for Intelligent Load Balancing of AI Workloads \[20 Min\]](#lab-5-srv6-for-intelligent-load-balancing-of-ai-workloads-20-min)
    - [Description](#description)
  - [Contents](#contents)
    - [Why host-based SRv6?](#why-host-based-srv6)
  - [Lab Objectives](#lab-objectives)
  - [SRv6 Fabric Load Balancing](#srv6-fabric-load-balancing)
  - [srctl command line tool](#srctl-command-line-tool)
  - [Jalapeno](#jalapeno)
    - [Arango Graph Database](#arango-graph-database)
  - [Jalapeno REST API](#jalapeno-rest-api)
  - [Jalapeno Web UI](#jalapeno-web-ui)
  - [Rome VM: SRv6 on Linux](#rome-vm-srv6-on-linux)
    - [Rome to Amsterdam: Lowest Latency Path](#rome-to-amsterdam-lowest-latency-path)
  - [Get Paths](#get-paths)
    - [Configure "ubuntu host" containers attached to SONiC topology](#configure-ubuntu-host-containers-attached-to-sonic-topology)


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
* How to use the **srctl** command line tool to program SRv6 routes on Linux hosts

## SRv6 Fabric Load Balancing

Use case writeup

Insert diagram with Jalapeno controller/API interaction

## srctl command line tool
**srctl** is an experimental command line tool that we've developed and which allows us to access SRv6 network services by programing SRv6 routes on Linux hosts or [VPP](https://fd.io/). It is modeled after *kubectl*, and as such it generally expects to be fed a *yaml* file defining the source and destination prefixes or endpionts for which we want a specific SRv6 network service. When the user runs the command, **srctl** will call the Jalapeno API and pass the yaml file data. Jalapeno will perform its path calculations and will return a set of SRv6 instructions. **srctl** will then program the SRv6 routes on the Linux host or VPP.

 **srctl's** currently supported network services are: 

 - Low Latency Path
 - Least Utilized Path
 - Data Sovereignty Path
 - Get All Paths (informational only)

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
    The output should look something like the following. Note that the Jalapeno VM is also using Cilium as its CNI, and that all of the Jalapeno pods/microservices are running in the **jalapeno** namespace.  Also, the Jalapeno K8s cluster is completely independent of the K8s cluster on the Berlin VM. In our simulation the Berlin VM is a consumer of services on our SRv6 network, which may include services that are accessed by interacting with Jalapeno.

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
    kube-system   coredns-565d847f94-nmt4n                       1/1     Running   0                4h40m
    kube-system   coredns-565d847f94-sg8fl                       1/1     Running   3 (4h41m ago)    363d
    kube-system   etcd-jalapeno                                  1/1     Running   19 (4h41m ago)   363d
    kube-system   kube-apiserver-jalapeno                        1/1     Running   3 (4h41m ago)    363d
    kube-system   kube-controller-manager-jalapeno               1/1     Running   3 (4h41m ago)    363d
    kube-system   kube-proxy-g8nbn                               1/1     Running   3 (4h41m ago)    363d
    kube-system   kube-scheduler-jalapeno                        1/1     Running   3 (4h41m ago)    363d
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

2. Click on the *`ipv6_graph`* collection, then select the `content` tab to see data from our topology graph

3. Optional or for reference: feel free to connect to the DB and try some of the queries in the [lab_5-queries.md doc](https://github.com/jalapeno/SRv6_dCloud_Lab/tree/main/lab_5/lab_5-queries.md)

## Jalapeno REST API

The Jalapeno REST API is used to run queries against the ArangoDB and retrieve graph topology data or execute shortest path calculations. 

1. Test the Jalapeno REST API:
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
- **Schedule a Workload**: this function is under construction. 


## Rome VM: SRv6 on Linux

The Rome VM is simulating a user host or endpoint and will use its Linux dataplane to perform SRv6 traffic encapsulation:

 - Linux SRv6 route reference: https://segment-routing.org/index.php/Implementation/Configuration

1. Login to the Rome VM
   ```
   ssh cisco@198.18.128.103
   ```

2. Run *srctl --help* to see the help menu for the tool.
   ```
   srctl --help
   ```

   Expected output:
   ```yaml
   cisco@rome:~$ srctl --help
   Usage: srctl [OPTIONS] COMMAND [ARGS]...

     Command line interface for Segment Routing Configuration

   Options:
     --api-server TEXT  Jalapeno API server address
     --help             Show this message and exit.

   Commands:
     apply      Apply a configuration from file
     delete     Delete a configuration from file
     get-paths  Get best paths between source and destination
   ```

   Per the *help* output we see that our current options are to *apply* or *delete* a configuration from a yaml file, or an informational *get-paths* command. Also notice the --api-server option where you can specify the Jalapeno API server address.

3. Lets review the [rome.yaml](srctl/rome.yaml) file we will use in later steps to program Rome use srctl.
   
   ```yaml
   apiVersion: jalapeno.srv6/v1     # following the k8s design pattern, the api version
   kind: PathRequest                # the type of object we are creating, a path request of Jalapeno
   metadata:
     name: rome-routes              # the name of the object
   spec:
     platform: linux   # we specify the platform so srctl knows which type of routes to install (linux or vpp)
     defaultVrf:       # also supports linux and vpp VRFs or tables
       ipv6:      # the same applies to ipv6
         routes:
           - name: rome-to-amsterdam-v6
             graph: ipv6_graph
             pathType: shortest_path
             metric: low-latency
             source: hosts/rome
             destination: hosts/amsterdam
             destination_prefix: "fc00:0:101:2::/64"
             outbound_interface: "ens192"
   ```

4. cd into the *lab_5/srctl* directory. If you like you can review the yaml files in the directory - they should basically match the commented example.

   ```
   cd ~/SRv6_dCloud_Lab/lab_5/srctl
   cat rome.yaml
   ```

5. For SRv6 outbound encapsulation we'll need to set Rome's SRv6 source address:

   ```
   sudo ip sr tunsrc set fc00:0:107:1::1
   ```

   Validate that the SR tunnel source was set:
   ```
   sudo ip sr tunsrc show
   ```
   Example output:
   ```
   cisco@rome:~/SRv6_dCloud_Lab/lab_5/srctl$ sudo ip sr tunsrc show
   tunsrc addr fc00:0:107:1::1
   ```

### Rome to Amsterdam: Lowest Latency Path

Our first use case is to make path selection through the network based on the cummulative link latency from A to Z. Calculating best paths using latency meta-data is not something traditional routing protocols can do, though it may be possible to statically build routes through your network using weights to define a path. However, what these workarounds cannot do is provide path selection based on near real time data which is possible with an application like Jalapeno. This provides customers a flexible tool that can react to changes in the WAN environment.

For the next section we will run the **srctl** *Low Latency* service on Rome to give it the lowest latency path to Amsterdam. See the diagram below for what the expected SRv6 path will be.

![Low Latency Path](/topo_drawings/low-latency-path.png)

1. From the *lab_5/srctl* directory on Rome, run the following command (note, we add *sudo* to the command as we are applying the routes to the Linux host):

   ```
   sudo srctl --api-server http://198.18.128.101:30800 apply -f rome.yaml
   ```

   Alternatively, define the API server address with an environment variable and run a simplified version of the command:
   ```
   export JALAPENO_API_SERVER="http://198.18.128.101:30800"

   sudo -E srctl apply -f rome.yaml
   ```

   The Output should look something like this:
   ```yaml
   cisco@rome:~/SRv6_dCloud_Lab/lab_5/srctl$ sudo srctl --api-server http://198.18.128.101:30800 apply -f rome.yaml
   Loaded configuration from rome.yaml
   Adding route with encap: {'type': 'seg6', 'mode': 'encap', 'segs': ['fc00:0:7777:6666:5555:1111:0:0']} to table 0
   rome-to-amsterdam-v6: fc00:0:7777:6666:5555:1111: Route to fc00:0:101:2::/64 via fc00:0:7777:6666:5555:1111:0:0 programmed successfully in table 0  # success message
   ```

2. Take a look at the Linux route table on Rome to see the new routes:
   ```
   ip -6 route show 
   ```

   Expected truncated output for ipv6:
   ```
   fc00:0:101:2::/64  encap seg6 mode encap segs 1 [ fc00:0:7777:6666:5555:1111:: ] dev ens192 proto static metric 1024 pref medium
   ```

3. Run a ping test from Rome to Amsterdam.
   ```
   ping fc00:0:101:2::1 -i .4
   ```

   Optional: run tcpdump on the XRD VM to see the traffic flow and SRv6 uSID in action. 
   ```
   sudo ip netns exec clab-clus25-xrd07 tcpdump -lni Gi0-0-0-0
   ```
   ```
   sudo ip netns exec clab-clus25-xrd06 tcpdump -lni Gi0-0-0-0
   ```

   We expect the ping to work, and tcpdump output should look something like this:
   ```yaml
   cisco@xrd:~$ sudo ip netns exec clab-clus25-xrd06 tcpdump -lni Gi0-0-0-0
   tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
   listening on Gi0-0-0-0, link-type EN10MB (Ethernet), capture size 262144 bytes
   22:23:10.294176 IP6 fc00:0:107:1::1 > fc00:0:6666:5555:1111::: srcrt (len=2, type=4, segleft=0[|srcrt]
   22:23:10.301615 IP6 fc00:0:101:1::1 > fc00:0:7777::: IP6 fc00:0:101:2::1 >  fc00:0:107:1:250:56ff:fe97:11bb: ICMP6, echo reply, seq 1, length 64
   22:23:10.694957 IP6 fc00:0:107:1::1 > fc00:0:6666:5555:1111::: srcrt (len=2, type=4, segleft=0[|srcrt]
   22:23:10.701436 IP6 fc00:0:101:1::1 > fc00:0:7777::: IP6 fc00:0:101:2::1 > fc00:0:107:1:250:56ff:fe97:11bb: ICMP6, echo reply, seq 2, length 64
   ```



## Get Paths

**srctl's** *Get All Paths* service will query the API for a set of ECMP paths from a source to a destination. The CLI can take a yaml file as input, or can take command line variables for source and destination. The CLI can also specify a limit to the number of paths returned.

Examples:
```
srctl get-paths -f amsterdam-to-rome.yaml 
```
```
srctl get-paths -s hosts/berlin-k8s -d hosts/rome --type best-paths --limit 3
```

1. On any of the VMs (Amsterdam, Rome, Berlin) run the **srctl** *Get Paths* CLI:
    ``` 
    cd ~/SRv6_dCloud_Lab/lab_5/srctl
    srctl get-paths -f amsterdam-to-rome.yaml 
    ```
    Expected output:
    ```
    cisco@rome:~/SRv6_dCloud_Lab/lab_5/srctl$ srctl get-paths -f amsterdam-to-rome.yaml 
    Loaded configuration from amsterdam-to-rome.yaml

    amsterdam-to-rome:
      Path 1 SRv6 uSID: fc00:0:1111:2222:6666:7777:
      Path 2 SRv6 uSID: fc00:0:1111:5555:4444:7777:
      Path 3 SRv6 uSID: fc00:0:1111:5555:6666:7777:
      Path 4 SRv6 uSID: fc00:0:1111:2222:3333:4444:7777:
    ```

Optional: run get-paths using all CLI options and/or with -v for verbose output:
   ```
   srctl get-paths -s hosts/berlin-k8s -d hosts/rome --type best-paths --limit 3
   srctl get-paths -s hosts/amsterdam -d hosts/rome --type best-paths --limit 4 -v
   ```


2. **srctl** *Get Next Best Paths* is an extension of the *Get Paths* service. It will query the API for a set of ECMP paths and also a set of *next best* paths that are one hop longer than the shortest/best path. The *next best* paths are the paths that would be used if the *best* path failed, or if we wanted to create an SRv6 policy that performed UCMP load balancing.

   ```
   srctl get-paths -s hosts/amsterdam -d hosts/rome --type next-best-path --same-hop-limit 3 --plus-one-limit 5 
   ```

   Expected output:
   ```
   cisco@berlin:~/SRv6_dCloud_Lab/lab_5/srctl$ srctl get-paths -s hosts/amsterdam -d hosts/rome --type next-best-path --same-hop-limit 3 --plus-one-limit 5

   hosts/amsterdam-to-hosts/rome:
     Best Path SRv6 uSID: fc00:0:1111:2222:6666:7777:
     Additional Best Path 1 SRv6 uSID: fc00:0:1111:2222:6666:7777:
     Additional Best Path 2 SRv6 uSID: fc00:0:1111:5555:4444:7777:
     Additional Best Path 3 SRv6 uSID: fc00:0:1111:5555:6666:7777:
     Next Best Path 1 SRv6 uSID: fc00:0:1111:2222:3333:4444:7777:
   ``` 


### Configure "ubuntu host" containers attached to SONiC topology

The *host-routes.sh* shell script located in the lab_4/ansible/scripts directory will add ip address and route entries to the Ubuntu containers attached to our SONiC topology. The linux route entries include SRv6 encapsulation instructions per the Linux kernel SRv6 implementation. For more info: https://segment-routing.org/


