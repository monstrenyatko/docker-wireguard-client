#!/bin/sh

# Debug output
set -x

# Exit on error
set -e

if [ -n "$NET6_LOCAL" ]; then
  docker_network_gw="$(ip -6 route | awk '/default/{print $3}')"
  ip route add $NET6_LOCAL via $docker_network_gw dev eth0
fi
