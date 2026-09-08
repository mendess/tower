#!/usr/bin/env bash

set -euo pipefail

cd $(dirname "$0")

declare -A static_ips
static_ips=(
    ['127\.0\.0\.1']=pendrellvale
    ['localhost']=pendrellvale
    ['192\.168\.42\.2']=pendrellvale
    ['192\.168\.42\.3']=tolaria
    ['192\.168\.42\.50']=aramanthinewall
    ['192\.168\.42\.125']=oboro
    ['192\.168\.42\.1']=router
)

metric_relabels() {
    echo "    metric_relabel_configs:"
    cat <<EOF
      - source_labels: [remote_addr]
        regex: '^.*$'
        target_label: eyeball
        replacement: 'unknown'
      - source_labels: [remote_addr]
        regex: '^192\\.168\\.42\\....$'
        target_label: eyeball
        replacement: 'unknown lan host'
      - source_labels: [remote_addr]
        regex: '^10\\.0\\..\\....$'
        target_label: eyeball
        replacement: 'unknown wireguard host'
EOF
    cat ../../gate/etc/wireguard/*.conf |
        awk '
        BEGIN { name = "" }
        /friendly_name/ {name=$4}
        name != "" && $1 == "AllowedIPs" { sub(/\/32$/, "", $3); print($3":"name); name = "" }' |
        while IFS=':' read -r addr name; do
            cat <<EOF
      - source_labels: [remote_addr]
        regex: '^${addr//./\\.}$'
        target_label: eyeball
        replacement: '$name'
EOF
        done
    for addr in "${!static_ips[@]}"; do
            cat <<EOF
      - source_labels: [remote_addr]
        regex: '^${addr}$'
        target_label: eyeball
        replacement: '${static_ips[$addr]}'
EOF
    done
}

declare -A job_names
job_names=(
    ["prometheus"]='[localhost:9090]'
    ['prometheus-systemd']='[localhost:9558]'
    ['nginx']='[localhost:9113]'
    ['nginx-logs']='[localhost:2000]'
    ['pendrellvale']='[localhost:9100]'
    ['blind-eternities']='[localhost:9001]'
    ['planar-bridge']='[localhost:9002]'
    ['grafana']='[localhost:3000]'
    ['minecraft']='[localhost:19565]'
    ['scraparr']='[localhost:7100]'
    ['immich_api']='[localhost:8081]'
    ['immich_microservices']='[localhost:8082]'
    ['wireguard']='[localhost:9586]'
    ['cadvisor']='[localhost:1696]'
)

cat <<EOF
global:
  scrape_interval:     10s
  evaluation_interval: 10s

scrape_configs:
EOF
for job in "${!job_names[@]}"; do
    cat <<EOF
  - job_name: $job
    static_configs:
      - targets: ${job_names[$job]}
        labels:
          instance: pendrellvale
$([[ $job = nginx-logs ]] && metric_relabels)
EOF
done
