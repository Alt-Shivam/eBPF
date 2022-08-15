#!/bin/bash

echo "Program to attach eBPF programs to NIC"
OPTIONS=$1


case $OPTIONS in

  help)
    echo "List of options to perform:"
    echo ">> p For installing required packages."
    echo ">> c Compile XDP-Bridge"
    echo ">> a Attach XDP-Bridge"
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
    echo -n "Compiling XDP-Bridge program."
    cd ../packet03-redirecting/
    make
    ;;

  *)
    echo -n "unknown"
    ;;
esac

