# Lab 5: SRv6 for Intelligent Load Balancing of AI Workloads [20 Min]

### Description
In recent months a few Hyperscalers have expressed interest in running SRv6 over the AI training fabrics. The idea would be to offer their customers the ability to do intelligent and deterministic load balancing of large, long-lived flows, by pinning them to specific paths thru the fabric. They would do this by offering the end-customer the ability to query an API and receive a set of SRv6 uSID encapsulations for a given set of source/destination GPU pairs. The customer could then program SRv6 routes right at the host or RDMA NIC: host-based SRv6.

In Lab 5 we will explore this use case with our SONiC nodes and their attached Ubuntu containers simulating an AI Training infrastructure. 


## Contents
- [Lab 5: SRv6 for Intelligent Load Balancing of AI Workloads \[20 Min\]](#lab-5-srv6-for-intelligent-load-balancing-of-ai-workloads-20-min)
    - [Description](#description)
  - [Contents](#contents)
  - [Lab Objectives](#lab-objectives)
  - [Host-Based SRv6 for Intelligent Fabric Load Balancing](#host-based-srv6-for-intelligent-fabric-load-balancing)
    - [Topology as Graph](#topology-as-graph)
    - [SRv6 PyTorch Plugin](#srv6-pytorch-plugin)
    - [Linux SRv6 test route](#linux-srv6-test-route)
  - [PyTorch SRv6 Plugin: Network-Optimized Distributed Training](#pytorch-srv6-plugin-network-optimized-distributed-training)
      - [Ping tests and Edgshark](#ping-tests-and-edgshark)
    - [Test flows with TRex tool](#test-flows-with-trex-tool)
      - [Grafana Dashboard](#grafana-dashboard)


## Lab Objectives
The student should have achieved the following objectives upon completion of Lab 5:

* Understanding of the SRv6 Fabric Load Balancing use case
* Familiarity of the SRv6 stack available in Linux
* Understanding of SONiC's SRv6 uSID shift-and-forward capabilities
* Bonus if time allows: Familiarity with the open-source Jalapeno project, its API, and UI

## Host-Based SRv6 for Intelligent Fabric Load Balancing


Recently at the EMEA OCP summit Guohan Lu from Microsoft explained how they build Source Routed AI Backend Networks with SRv6:

https://www.segment-routing.net/conferences/2025-ocp-emea-microsoft-srv6-ai-backend/

The key problem to solve is large, long-lived flows being ECMP'd can result in path collision or hotspots in the fabric. With AI training this can lead to delays or even job failures such that the training run needs to be restarted. Given the cost of running large GPU pools, delay or failure can be very costly indeed.

The solution: coordination of all senders source routing their traffic over disjoint paths through the fabric.

In addition to basic Fabric Load Balancing we also envision the use of SRv6 to partition the network such that tenants' or customers' training jobs do not ever come into conflict across the fabric.

Cisco doesn't currently have a host-based SRv6 controller product and the Hyperscalers build their own SDN control infrastructure, so to simulate this capability in the lab we've built a demo PyTorch SRv6 plugin which leverages the open-source project Jalapeno as its backend data repository.

SRv6 PyTorch plugin: https://github.com/segmentrouting/srv6-pytorch-plugin

Project Jalapeno homepage: https://github.com/cisco-open/jalapeno

For more info on PyTorch: https://pytorch.org/

Insert diagram with PyTorch plugin + Jalapeno controller/API interaction

### Topology as Graph

We've created a model of our SONiC fabric topology with relevant SRv6 data in Jalapeno's Arango Graph Database. This makes the fabric topology graph available to PyTorch (or other SDN applications) via Jalapeno's API. 

After completing Lab 5 feel free to checkout the [Lab 5 Bonus Section](./lab_5-bonus.md) that explores the GraphDB or API in more detail.


### SRv6 PyTorch Plugin

From https://pytorch.org/projects/pytorch/

*PyTorch is an open source machine learning framework that accelerates the path from research prototyping to production deployment. Built to offer maximum flexibility and speed...its Pythonic design and deep integration with native Python tools make it an accessible and powerful platform for building and training deep learning models at scale.*

PyTorch Distributed Training:
When you start distributed training, PyTorch initializes a process group
It uses a backend (like NCCL) for communication between nodes
Each node gets a rank and knows about other nodes through the process group
NVIDIA NCCL (NVIDIA Collective Communications Library):
NCCL is the default backend for multi-GPU communication in PyTorch
It handles all the collective operations (all-reduce, all-gather, etc.)
It's optimized for NVIDIA GPUs and high-speed networks
NCCL automatically selects the best network path for communication
pytorch-srv6-plugin's Role:
The plugin intercepts the NCCL initialization phase
Before NCCL starts communicating, the plugin:
Gets the list of nodes from the distributed setup
Queries the Jalapeno API for optimized SRv6 paths between nodes
Programs local SRv6 routes on each node
This happens transparently to both PyTorch and NCCL
NCCL then uses these optimized routes for its communication
Here's a typical flow:

```
[PyTorch Training Script]
        ↓
[Initialize Distributed Training]
        ↓
[PyTorch calls NCCL backend]
        ↓
[SRv6 Plugin intercepts]
        ↓
[Programs SRv6 routes]
        ↓
[NCCL uses routes for communication]
        ↓
[Training continues normally]
```

The key point is that the plugin works at the network layer, below both PyTorch and NCCL. It ensures that when NCCL needs to communicate between nodes, it uses the optimized SRv6 paths we've programmed, but NCCL itself doesn't need to know about SRv6 - it just sees the network as being faster and more efficient.

The demo uses gloo as the backend instead of NCCL because:
gloo is a CPU-based backend that doesn't require GPUs
It's perfect for testing and demonstration purposes
It still provides all the distributed training functionality we need

The interaction is similar, but simpler:

```
[PyTorch Training Script]
        ↓
[Initialize Distributed Training with gloo backend]
        ↓
[SRv6 Plugin intercepts]
        ↓
[Programs SRv6 routes]
        ↓
[gloo uses routes for communication]
        ↓
[Training continues normally]
```

The key:
The plugin intercepts the distributed initialization phase
It programs the SRv6 routes before any communication starts
It doesn't care which backend is being used for the actual communication

### Linux SRv6 test route

The linux route entries include SRv6 encapsulation instructions per the Linux kernel SRv6 implementation. For more info: https://segment-routing.org/


## PyTorch SRv6 Plugin: Network-Optimized Distributed Training

The PyTorch SRv6 Plugin is a tool that leverages SRv6 to enhance distributed training. It optimizes network paths for distributed training workloads by dynamically programming SRv6 routes based on real-time network conditions.

Key Features

* Network-Aware Distributed Training: Automatically optimizes network paths for PyTorch distributed training sessions
* SRv6 Route Programming: Programs optimal SRv6 routes using either Linux kernel or VPP (Vector Packet Processing)
* Dynamic Path Selection: Uses Jalapeno API to determine the best network paths based on current network conditions
* Multi-Platform Support: Works with both Linux and VPP platforms for route programming
* Distributed Training Integration: Seamlessly integrates with PyTorch's distributed training framework

How It Works
Initialization: When a distributed training session starts, the plugin:
Initializes the distributed environment
Collects information about all participating nodes
Establishes communication with the Jalapeno API
Path Discovery: For each node pair:
Queries the Jalapeno API for optimal paths
Receives SRv6 path information including USIDs (Universal Segment Identifiers)
Processes path information to determine optimal routes
Route Programming: For each discovered path:
Programs local SRv6 routes using the appropriate platform (Linux/VPP)
Appends destination functions to USIDs
Sets up encapsulation for optimal packet forwarding
Distributed Training: After route programming:
Enables distributed training communication
Maintains optimized network paths throughout the training session
Ensures efficient data transfer between nodes
Use Cases
Distributed Deep Learning: Optimize network paths for multi-node training
Network-Aware Computing: Leverage SRv6 for intelligent packet routing
High-Performance Computing: Improve communication efficiency in distributed systems
Network Engineering Training: Demonstrate SRv6 capabilities in a practical setting
Technical Requirements
Python 3.8+
PyTorch
Linux kernel with SRv6 support (for Linux route programming)
VPP (optional, for VPP-based route programming)
Access to Jalapeno API
Network infrastructure supporting SRv6
This plugin serves as an excellent example of how modern networking technologies like SRv6 can be integrated with distributed computing frameworks to optimize performance and resource utilization.

#### Ping tests and Edgshark

### Test flows with TRex tool

#### Grafana Dashboard




