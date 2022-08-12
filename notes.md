
```
apt-get update && apt-get upgrade -y 
apt-get install -y --install-recommends linux-generic-hwe-18.04
apt install -y  clang llvm libelf-dev gcc-multilib linux-headers-generic linux-tools-generic linux-tools-common build-essential git libpcap-dev ethtool
```
```
git clone https://github.com/atoonk/xdp-tutorial.git
cd xdp-tutorial
git submodule update --init
git clone --recurse-submodules https://github.com/xdp-project/xdp-tutorial
```

```
ip route flush cache
for f in /proc/sys/net/ipv4/conf/*/accept_redirects; do echo 0 > $f; done
for f in /proc/sys/net/ipv4/conf/*/send_redirects; do echo 0 > $f; done
for f in /proc/sys/net/ipv4/conf/*/rp_filter; do echo 0 > $f; done

sysctl net.ipv4.ip_forward net.ipv4.ip_forward=1
sysctl -w net.ipv4.conf.all.send_redirects=0
sysctl -w net.ipv4.conf.all.accept_redirects=0
```

```
mount -t bpf bpf /sys/fs/bpf/

make
alias t='../testenv/testenv.sh'
cd ~/xdp-tutorial/packet03-redirecting
cp ../packet-solutions/xdp_prog_kern_03.c xdp_prog_kern.c
cp ../packet-solutions/xdp_prog_user.c .
make clean && make
```

```
./xdp_loader -d enp1s0f1 -F --progsec xdp_pass
./xdp_loader -d enp1s0f1 -F --progsec xdp_pass

#pin BPF resources (redirect map) to a persistent filesystem
mount -t bpf bpf /sys/fs/bpf/

# attach xdp_router code to eno2
./xdp_loader -d eno2 -F --progsec xdp_router
# attach xdp_router code to eno4
./xdp_loader -d eno4 -F --progsec xdp_router

# populateredirect_params maps
./xdp_prog_user -d eno2
./xdp_prog_user -d eno4


```
Check stats:
```
./xdp_stats -d eno4
```

unload:
```
./xdp_loader -d enp1s0f0 -U --progsec xdp_router
./xdp_loader -d enp1s0f1 -U --progsec xdp_pass

```

to change number of cores / RSS queues:

```
root@xdp:~/xdp-tutorial/packet03-redirecting# ethtool -L eno2  combined 10
root@xdp:~/xdp-tutorial/packet03-redirecting# ethtool -l eno2
Channel parameters for eno2:
Pre-set maximums:
RX:		0
TX:		0
Other:		1
Combined:	64
Current hardware settings:
RX:		0
TX:		0
Other:		1
Combined:	10
```
