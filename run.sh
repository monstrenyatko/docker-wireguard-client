#!/bin/sh

# Debug output
set -x

# Exit on error
set -e

_term() {
  echo "Request to STOP received"
  wg-quick down wg0
  echo "STOPPED"
  kill -TERM "$child" 2>/dev/null
}

if [ "$1" = 'vpnc-app' ]; then
  shift;
  /firewall.sh
  /firewall6.sh
  /routing.sh
  /routing6.sh
  wg-quick up wg0
  trap _term SIGTERM
  wg show
  sleep infinity &
  child=$!
  wait "$child"
fi

exec "$@"
