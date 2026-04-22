#!/bin/bash

cd "$(dirname "$0")/.." || exit
source ./scripts/common.sh

read -p "client name? " name
case "$network" in
    wg0) read -p "split tunnel? [Y/n] " split_tunnel ;;
    mc1) split_tunnel=y ;;
    ex2) split_tunnel=n ;;
esac

case "$split_tunnel" in
    n)
        allowed_ips="0.0.0.0, ::/0"
        ;;
    *)
        allowed_ips="10.0.$network_number.1, 192.168.42.2"
        ;;
esac

lattest=$(grep -h 'AllowedIPs' "$local_conf" |
    cut -d= -f2 |
    cut -d/ -f1 |
    cut -d. -f4 |
    sort -n |
    tail -1) || lattest=1

ip="10.0.$network_number.$((lattest + 1))"

directory=$(mktemp -d)
trap "rm -rv '$directory'" EXIT
echo "dir: $directory"

client_privatekey="$directory/privatekey"
client_publickey="$directory/publickey"

wg genkey | tee "$client_privatekey" | wg pubkey > "$client_publickey"

cat <<EOF | tee /dev/tty | qrencode -t ansiutf8
[Interface]
PrivateKey = $(cat "$client_privatekey")
Address = $ip/24
DNS = 10.0.$network_number.1

[Peer]
PublicKey = $(cat "$publickey")
AllowedIPs = $allowed_ips
Endpoint = mendess.xyz:5182$network_number
EOF

read -p "Client added? [y/N]"
if [[ "$REPLY" =~ Y|y|yes ]]; then
    echo -e "\n============= NEW $network PEER CONFIG ============="
    cat <<EOF | tee -a "$local_conf"

#-- $name
[Peer]
PublicKey = $(cat "$client_publickey")
AllowedIPs = $ip/32
EOF
    echo -e "\n===============================================\n"

    make wg-update-$network
fi
