# When and Where is the XDP code executed
XDP programs can be attached to three different points. The fastest is to have it run on the NIC itself, for that you need a smartnic and is called offload mode. To the best of my knowledge, this is currently only supported on Netronome cards. The next attachment opportunity is essentially in the driver before the kernel allocates an SKB. This is called “native” mode and means you need your driver to support this, luckily most popular [drivers](https://github.com/xdp-project/xdp-project/blob/master/areas/drivers/README.org) do nowadays.

Finally, there is SKB or Generic Mode XDP, where the XDP hook is called from netif _ receive _ skb(), this is after the packet DMA and skb allocation are completed, as a result, you lose most of the performance benefits.

Assuming you don’t have a smartnic, the best place to run your XDP program is in native mode as you’ll really benefit from the performance gain.

## XDP actions
Now that we know that XDP code is an eBPF C program, and we understand where it can run, now let’s take a look at what you can do with it. Once the program is called, it receives the packet context and from that point on you can read the content, update some counters, potentially modify the packet, and then the program needs to terminate with one of 5 XDP actions:  

**XDP_DROP**  
This does exactly what you think it does; it drops the packet and is often used for XDP based firewalls and DDOS mitigation scenarios.  

**XDP_ABORTED**  
Similar to DROP, but indicates something went wrong when processing. This action is not something a functional program should ever use as a return code.

**XDP_PASS**  
This will release the packet and send it up to the kernel network stack for regular processing. This could be the original packet or a modified version of it.  

**XDP_TX**  
This action results in bouncing the received packet back out the same NIC it arrived on. This is usually combined with modifying the packet contents, like for example, rewriting the IP and Mac address, such as for a one-legged load balancer.  

**XDP_REDIRECT**  
The redirect action allows a BPF program to redirect the packet somewhere else, either a different CPU or different NIC. We’ll use this function later to build our router. It is also used to implement AF_XDP, a new socket family that solves the highspeed packet acquisition problem often faced by virtual network functions. AF_XDP is, for example, used by IDS’ and now also supported by Open vSwitch.

### How to Compile and attach program manually.
**Compile**
```
make
```
**Attach**
```
#pin BPF resources (redirect map) to a persistent filesystem
mount -t bpf bpf /sys/fs/bpf/

# attach xdp_router code to eno2
./xdp_loader -d <1stInterfaceName> -F — progsec xdp_router

# attach xdp_router code to eno4
./xdp_loader -d <2ndInterfaceName> -F — progsec xdp_router

# populate redirect_params maps
./xdp_prog_user -d <1stInterfaceName>
./xdp_prog_user -d <2ndInterfaceName>
```
