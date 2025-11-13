#!/bin/bash

cd "$(dirname "$0")/.." || exit
source ./scripts/common.sh

genkey() {
    mkdir -vp "$keys"
    echo "checking if wireguard keys already exist"
    sudo /usr/bin/test -e "/etc/wireguard/$network-privatekey" &&
        /usr/bin/test -e "$publickey" &&
        return

    read -p "no keys found. Should a new ones be generated? [y/N] "
    if [[ "$REPLY" != y ]]; then
        exit
    fi

    echo "generating keys"

    wg genkey | tee "$privatekey" | wg pubkey > "$publickey"

    echo "server public key"
    cat "$publickey" | qrencode -t ANSI256

    chmod -v 400 "$privatekey"
    chmod -v 440 "$publickey"
    sudo mv -v "$privatekey" "$installed_privatekey"
    sudo chown root:root "$installed_privatekey"
}

test -e "$local_conf" || {
    echo "$network does not exist in $local_conf"
    exit
}

echo "configuring $network"

genkey

sudo test -e "$installed_conf" &&
    sudo test "$installed_conf" -nt "$local_conf" &&
    echo "no need to update $installed_conf" &&
    exit 0

echo -e "\n============= INSTALLING $network CONFIG =============\n"
sed \
    "s|REPLACE__PRIVATE_KEY|$(sudo cat "$installed_privatekey")|" \
    "$local_conf" | \
    sudo tee "$installed_conf"
echo -e "\n======================================================\n"
