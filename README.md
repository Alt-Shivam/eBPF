# eBPF: Extended Berkeley Packet Filter
## What is eBPF?
eBPF is a feature available in Linux kernels that allows you to run a virtual machine inside the kernel. This virtual machine allows you to safely load programs into the kernel, in order to customize its operation. Why is this important?

In the past, making changes to the kernel was difficult: there were APIs you could call to get data, but you couldn’t influence what was inside the kernel or execute code. Instead, you had to submit a patch to the Linux community and wait for it to be approved. With eBPF, you can load a program into the kernel and instruct the kernel to execute your program if, for example, a certain packet is seen or another event occurs.

With eBPF, the kernel and its behavior become highly customizable, instead of being fixed. This can be extremely beneficial, when used under the right circumstances.

## How can eBPF be used?
There are several use cases for eBPF, including traffic control, creating network policy, connect-time load balancing, and observability.

## Traffic control
Without eBPF, packets use the standard Linux networking path on their way to a final destination. If a packet shows up at point A, and you know that the packet needs to go to point B, you can optimize the network path in the Linux kernel by sending it straight to point B. With eBPF, you can leverage additional context to make these changes in the kernel so that packets bypass complex routing and simply arrive at their final destination.

This is especially relevant in a Kubernetes container environment, where you have numerous networks. (In addition to the host network stack, each container has its own mini network stack.) When traffic comes in, it is usually routed to a container stack and must travel a complex path as it makes its way there from the host stack. This routing can be bypassed using eBPF.

## Creating network policy
When creating network policy, there are two instances where eBPF can be used:

eXpress Data Path (XDP) – As a raw packet buffer enters the system, eBPF gives you an efficient way to examine that buffer and make quick decisions about what to do with it.
Network policy – eBPF allows you to efficiently examine a packet and apply network policy, both for pods and hosts.
Connect-time load balancing
When load balancing service connections in Kubernetes, a port needs to talk to a service and therefore network address translation (NAT) must occur. A packet is sent to a virtual IP, and that virtual IP translates it to the destination IP of the pod backing the service; the pod then responds to the virtual IP and the return packet is translated back to the source.

With eBPF, you can avoid this packet translation by using an eBPF program that you’ve loaded into the kernel and load balancing at the source of the connection. All NAT overhead from service connections is removed because destination network address translation (DNAT) does not need to take place on the packet processing path.

## Observability
Collecting statistics and deep-dive debugging of the kernel are two useful ways in which eBPF can be used for observability. eBPF programs can be attached to a number of different functions in the kernel, providing access to data that a function is processing while also allowing that data to be modified. For example, with eBPF, if a network connection is established, you can receive a call when the socket is created. Why is this important when you can already receive socket calls as events? The key here is that eBPF provides these calls within the context of the program that opened the socket, so you get information about which process opened it and what happened to the socket.

# The price of performance
So is eBPF more efficient than standard Linux iptables? The short answer: it depends.

If you were to micro-benchmark how iptables works when applying network policies with a large number of IP addresses (i.e. ipsets), iptables in many cases is better than eBPF. But if you want to do something in the Linux kernel where you need to alter the packet flow in the kernel, eBPF would be the better choice. Standard Linux iptables is a complex system and certainly has its limitations, but at the same time it provides options to manipulate traffic; if you know how to program iptables rules, you can achieve a lot. eBPF allows you to load your own programs into the kernel to influence behavior that can be customized to your needs, so it is more flexible than iptables as it is not limited to one set of rules.

Something else to consider is that, while eBPF allows you to run a program, add logic, redirect flows, and bypass processing—which is a definite win—it’s a virtual machine and as such must be translated to bytecode. By comparison, the Linux kernel’s iptables is already compiled to code.

As you can see, comparing eBPF to iptables is not a straight apples-to-apples comparison. What we need to assess is performance, and the two key factors to look at here are latency (speed) and expense. If eBPF is very fast but takes up 80% of your resources, then it’s like a Lamborghini—an expensive, fast car. And if that works for you, great (maybe you really like expensive, fast cars). Just keep in mind that more CPU usage means more money spent with your cloud providers. So while a Lamborghini might be faster than a lot of other cars, it might not be the best use of money if you need to comply with speed limits on your daily commute.
