#!/bin/bash

set -euo pipefail

read -p "client name? " name

lattest=$(grep -h 'AllowedIPs' ./etc/wireguard/wg0.conf |
    cut -d= -f2 |
    cut -d/ -f1 |
    cut -d. -f4 |
    sort -n |
    tail -1)

ip="10.0.0.$((lattest + 1))"

directory=$(mktemp -d)
trap "rm -rv '$directory'" EXIT
echo "dir: $directory"

privatekey="$directory/privatekey"
publickey="$directory/publickey"

wg genkey | tee "$privatekey" | wg pubkey > "$publickey"

cat <<EOF | tee /dev/tty | qrencode -t ansiutf8
[Interface]
PrivateKey = $(cat "$privatekey")
Address = $ip/24
DNS = 10.0.0.1

[Peer]
PublicKey = $(cat ./publickey)
AllowedIPs = 10.0.0.0/24, 192.168.1.0/24
Endpoint = mendess.xyz:51820
EOF

read -p "Client added? [y/N]"
if [[ "$REPLY" =~ Y|y|yes ]]; then
    cat <<EOF | tee -a ./etc/wireguard/wg0.conf
\n#-- $name
[Peer]
PublicKey = $(cat "$publickey")
AllowedIPs = $ip/32
EOF

    make update-wg
fi
