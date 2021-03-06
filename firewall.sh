#!/bin/sh

# Debug output
set -x

# Exit on error
set -e

docker_networks=$(ip link | awk -F': ' '$0 !~ "lo|wg|tun|tap|^[^0-9]"{print $2;getline}' | cut -d@ -f1 | (
  while read interface
  do
    network="$(ip -o addr show dev $interface | awk '$3 == "inet" {print $4}')"
    if [ -z "$result" ]; then
      result=$network
    else
      result=$result,$network
    fi
  done
  echo $result
))
if [ -z "$docker_networks" ]; then
  >&2 echo "No inet network"
  exit
fi

iptables -F
iptables -X
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -s ${docker_networks} -j ACCEPT

iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A OUTPUT -d ${docker_networks} -j ACCEPT
iptables -A OUTPUT -o wg+ -j ACCEPT
iptables -A OUTPUT -p udp -m udp --dport 53 -j ACCEPT
iptables -A OUTPUT -p udp -m udp --dport ${WIREGUARD_PORT} -j ACCEPT

iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -i lo -j ACCEPT
iptables -A FORWARD -d ${docker_networks} -j ACCEPT
iptables -A FORWARD -s ${docker_networks} -j ACCEPT

iptables -t nat -A POSTROUTING -o wg+ -j MASQUERADE

if [ -n "$NET_LOCAL" ]; then
  iptables -A INPUT -i eth0 -s $NET_LOCAL -j ACCEPT
  iptables -A OUTPUT -o eth0 -d $NET_LOCAL -j ACCEPT
fi
