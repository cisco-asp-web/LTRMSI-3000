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