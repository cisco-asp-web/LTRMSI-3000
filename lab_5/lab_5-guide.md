


### Configure "ubuntu host" containers attached to SONiC topology

The *host-routes.sh* shell script located in the lab_4/ansible/scripts directory will add ip address and route entries to the Ubuntu containers attached to our SONiC topology. The linux route entries include SRv6 encapsulation instructions per the Linux kernel SRv6 implementation. For more info: https://segment-routing.org/


## Jalapeno

Project Jalapeno combines existing open source tools with some new stuff we've developed into a data collection and warehousing infrastructure intended to enable development of SDN or network service applications. Think of it as applying microservices architecture and concepts to SDN: give developers the ability to quickly and easily build microservice control planes on top of a common data collection and warehousing infrastructure. More information on Jalapeno can be found at the Jalapeno Git repository: [LINK](https://github.com/cisco-open/jalapeno/blob/main/README.md)

![jalapeno_architecture](https://github.com/cisco-open/jalapeno/blob/main/docs/img/jalapeno_architecture.png)