#!/bin/bash

set -euo pipefail

sudo /usr/bin/test -e /etc/wireguard/privatekey && exit
/usr/bin/test -e publickey && {
    read -p "you lost your public key. Should a new one be generated? [Y/n] "
    if [[ "$REPLY" = n ]]; then
        exit
    fi
}

echo "generating keys"

wg genkey | tee privatekey | wg pubkey > publickey

echo "server public key"
cat publickey | qrencode -t ANSI256

chmod -v 400 privatekey
chmod -v 444 publickey
sudo mv -v privatekey /etc/wireguard/
