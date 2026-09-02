#!/usr/bin/env bash

set -euo pipefail

ifaces=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        -o)
            path="$2"
            shift
            ;;
        *) ifaces+=("interface-name:$1") ;;
    esac
    shift
done

cat <<EOF > "$path"
[keyfile]
unmanaged-devices=$(IFS=';' ; echo "${ifaces[*]}")
EOF

chmod -v 644 "$path" | grep -v retained || true
