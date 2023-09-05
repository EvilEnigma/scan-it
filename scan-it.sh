#!/bin/bash
#Author: EvilEnigma

if [ "$#" -ne 2 ]; then
    echo "[-] Error: scan-it needs two arguments. The first argument is the foldername and second is the host that you would like to scan.."
    echo "Example: ./scan-it.sh example.htb 127.0.0.1"
    exit 1
fi


if ps aux | grep -q "[o]penvpn"; then
    echo "[+] OpenVPN is running."
    
    if ifconfig tun0 &>/dev/null || ip addr show tun0 &>/dev/null; then
        echo "[+] OpenVPN has an IP address assigned."
    else
        echo "[+] OpenVPN does not have an IP address assigned."
    fi
else
    echo "[-] OpenVPN is not running."
    exit 1
fi




folder_name="$1"

if [ -d "$folder_name" ]; then
    echo "[-] Folder '$folder_name' already exists."
else
    mkdir "$folder_name"
    echo "[+] Folder '$folder_name' created successfully."
fi

ipv4_pattern="^([0-9]{1,3}\.){3}[0-9]{1,3}$"

if [[ $2 =~ $ipv4_pattern ]]; then
    echo "[+] Argument 2 ('$2') is a valid IPv4 address."
else
    echo "[-] Argument 2 ('$2') is not a valid IPv4 address."
    exit 1
fi


arg1="$1"
arg2="$2"

echo "Argument 1 is -->: $arg1"
echo "Argument 2 is -->: $arg2"


sudo nmap -Pn --open -n -sS --max-retries 1 -T4 -p- $2 -oA $1/sS-$1-$2 -vvv


open_ports=$(grep -oP '\d+\/open' "$1/sS-$1-$2.gnmap" | cut -d'/' -f1 | tr '\n' ',' | sed 's/,$//')

if [ -n "$open_ports" ]; then
        echo "Running script scan on open ports: $open_ports"
        nmap -Pn -p "$open_ports" -A -sC -sV -oA $1/sC-$1-$2 $2 -vvvv
        echo "Script scan completed. Results saved $1/sC-$1-$2"
else
        echo "No open ports found to perform a script scan."
fi
