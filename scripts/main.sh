#!/bin/bash

echo "Program to attach eBPF programs to NIC"
OPTIONS=$1
NIC1=$2
NIC2=$3

case $OPTIONS in

  help)
    echo "List of options to perform:"
    echo ">> p For installing required packages."
    echo ">> c For Compile XDP-Bridge"
    echo ">> a For Attaching XDP-Bridge (also provide NIC names .ie './main.sh a eno2 eno3')"
    ;;

  p)
    echo "Installing required packages."
    sudo apt install -y clang llvm libelf-dev libpcap-dev gcc-multilib build-essential
    sudo apt install -y linux-tools-$(uname -r)
    sudo apt install -y linux-headers-$(uname -r)
    sudo apt install -y linux-tools-common linux-tools-generic
    sudo apt install -y tcpdump
    ;;

  c)
    echo "Compiling XDP-Bridge program."
    cd ../packet03-redirecting/
    make
    ;;

  a)
    echo "Attaching XDP-Bridge program."
    cd ../packet03-redirecting/
    sudo mount -t bpf bpf /sys/fs/bpf/
    sudo ./xdp_loader -d $NIC1 -F — progsec xdp_router
    sudo ./xdp_loader -d $NIC2 -F — progsec xdp_router
    sudo ./xdp_prog_user -d $NIC1
    sudo ./xdp_prog_user -d $NIC2
    ;;

  *)
    echo "Please select a valid option."
    ;;
esac

