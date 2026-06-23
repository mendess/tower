#!/bin/bash

script_dir=$(dirname "$(realpath "$0")")
source "$script_dir/common.sh"
cd "$(dirname "$0")/.." || exit

if [[ -e "$installed_conf" ]]; then
    before_mtime=$(stat --print '%Y' "$installed_conf")
    $script_dir/config-wg.sh "$network"
    after_mtime=$(stat --print '%Y' "$installed_conf")

    if [[ "$before_mtime" != "$after_mtime" ]]; then
        printf "$RED DOWN$RESET Taking down interface $*\n"
        sudo wg-quick down /etc/wireguard/$network.conf
    fi
else
    $script_dir/config-wg.sh "$network"
fi

if ! [[ -e "/proc/self/net/dev_snmp6/$network" ]]; then
    printf "$GREEN   UP$RESET Bringing up interface $*\n"
    sudo wg-quick up /etc/wireguard/$network.conf
fi

echo "wireguard $network configured"
