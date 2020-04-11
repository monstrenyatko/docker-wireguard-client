#!/bin/sh

# Debug output
set -x

# Exit on error
set -e

if [ -n "$NET_LOCAL" ]; then
  docker_network_gw="$(ip route | awk '/default/{print $3}')"
  ip route add $NET_LOCAL via $docker_network_gw dev eth0
fi
