## Bonus: Project Jalapeno and Host-Based SRv6

### Host Based SRv6

## Why host-based SRv6? 

* **Flexibility and Control**: We get tremendous control of the SRv6 SIDs and our encapsulation depth isn't subject to ASIC limitations

* **Performance and Massive Scale**: With host-based SRv6 traffic reaches the transport network already encapsulated, thus the ingress PE or SRv6-TE headend doesn't need all the resource intense policy configuration; they just statelessly forward traffic per the SRv6 encapsulation or Network Program
  
* **SRv6 as Common E2E Architecture**: We could extend SRv6 into the Cloud! Or to IoT devices or other endpoints connected to the physical network...
 
We feel this ability to perform SRv6 operations at the host or other endpoint is a game changer which opens up enormous potential for innovation!

## srctl command line tool
**srctl** is an experimental command line tool that we've developed and which allows us to access SRv6 network services by programing SRv6 routes on Linux hosts or [VPP](https://fd.io/). It is modeled after *kubectl*, and as such it generally expects to be fed a *yaml* file defining the source and destination prefixes or endpionts for which we want a specific SRv6 network service. When the user runs the command, **srctl** will call the Jalapeno API and pass the yaml file data. Jalapeno will perform its path calculations and will return a set of SRv6 instructions. **srctl** will then program the SRv6 routes on the Linux host or VPP.

 **srctl's** currently supported network services are: 

 - Low Latency Path
 - Least Utilized Path
 - Data Sovereignty Path
 - Get All Paths (informational only)

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


### Jalapeno Web UI

The Jalapeno UI is a demo or proof-of-concept meant to illustrate the potential use cases for extending SRv6 services beyond traditional network elements and into the server, host, VM, k8s, or other workloads. Once Jalapeno has programmatically collected data from the network and built its topology graphs, the network operator has complete flexibility to add data or augment the graph. In fact, our SONiC *`fabric_graph`* data was simply uploaded from a json file. 

Once the topology graphs are in place its not too difficult to conceive of building network services based on calls to the Jalapeno API and leveraging the SRv6 uSID stacks that are returned.

The Jalapeno Web UI can be accessed at: [http://198.18.128.101:30700](http://198.18.128.101:30700). 

On the left hand sidebar you will see that UI functionality is split into two sections:

- **Data Collections**: explore raw object and graph data collected from the network.
- **Topology Viewer**: explore the network topology graphs and perform path calculations.


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