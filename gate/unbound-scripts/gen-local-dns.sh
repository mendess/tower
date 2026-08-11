#!/usr/bin/env bash

set -euo pipefail

zones() {
    ../homunculus show --csv --reachable private-proxy |
        awk -F, 'NR > 1 { print $6 }' |
        grep -v pendrellvale.home |
        grep -vE '^$' |
        while read -r zone; do
            cat <<EOF
    local-zone: "$zone." redirect
    local-data: "$zone. IN A 192.168.42.2"
EOF
        done
}

cat <<EOF
server:
    local-zone: "pendrellvale.home." redirect
    local-data: "pendrellvale.home. IN A 192.168.42.2"
$(zones)

forward-zone:
    name: "lan."
    forward-addr: 127.0.0.1@5553

forward-zone:
    name: "42.168.192.in-addr.arpa"
    forward-addr: 127.0.0.1@5553
EOF
