#!/bin/sh

# Debug output
set -x

# Exit on error
set -e

if [ -n "$NET6_LOCAL" ]; then
  docker_network_gw="$(ip -6 route | awk '/default/{print $3}')"
  # Check if the route already exists before attempting to add it
  if ! ip -6 route show "${NET6_LOCAL}" >/dev/null 2>&1; then
    ip -6 route add "${NET6_LOCAL}" via "${docker_network_gw6}" dev eth0
  fi
fi
