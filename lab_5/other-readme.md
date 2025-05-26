## srctl command line tool
**srctl** is an experimental command line tool that we've developed and which allows us to access SRv6 network services by programing SRv6 routes on Linux hosts or [VPP](https://fd.io/). It is modeled after *kubectl*, and as such it generally expects to be fed a *yaml* file defining the source and destination prefixes or endpionts for which we want a specific SRv6 network service. When the user runs the command, **srctl** will call the Jalapeno API and pass the yaml file data. Jalapeno will perform its path calculations and will return a set of SRv6 instructions. **srctl** will then program the SRv6 routes on the Linux host or VPP.

 **srctl's** currently supported network services are: 

 - Low Latency Path
 - Least Utilized Path
 - Data Sovereignty Path
 - Get All Paths (informational only)