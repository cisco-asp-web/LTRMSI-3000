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