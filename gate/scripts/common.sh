#!/bin/bash

set -euo pipefail

if [ "$#" -lt 1 ]; then
    echo "usage: $0 network"
    exit
fi

readonly network=$1
network_number=$(echo "$network" | grep -oE '[0-9]+$')
if [[ -z "$network_number" ]] || [[ "$network_number" -gt 254 ]]; then
    echo "invalid network name. Network number too high"
    exit 1
fi
readonly keys=wireguard-keys
readonly publickey="$keys/$network-publickey"
readonly privatekey="$keys/$network-privatekey"
readonly local_conf="./etc/wireguard/$network.conf"
readonly installed_conf="/etc/wireguard/$network.conf"
readonly installed_privatekey="/etc/wireguard/$network-privatekey"

readonly RED="\033[0;31m"
readonly GREEN="\033[0;32m"
readonly YELLOW="\033[0;33m"
readonly BLUE="\033[0;34m"
readonly CYAN="\033[0;36m"
readonly RESET="\033[0m"
