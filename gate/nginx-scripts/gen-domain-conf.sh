#!/bin/bash

set -euo pipefail

target=$1
case "$target" in
    *public*) mode=public ;;
    *private*) mode=private ;;
    *)
        echo "invalid mode"
        exit 1
        ;;
esac

script_dir=$(dirname "$(realpath "$0")")
homunculus="$script_dir/../../homunculus"
cd "$(dirname "$0")/.." || exit

hostname=$(basename "$target")
port=$($homunculus show --csv | awk -F, -v hostname=$hostname '$6 == hostname {print $3}')
redirect=$($homunculus show --csv | awk -F, -v hostname=$hostname '$6 == hostname {print $7}')

listen() {
    case "$hostname" in
        *pendrellvale.home) l="listen 80;";;
        *mendess.xyz) l="listen 443 ssl;";;
    esac
    cat <<EOF
    server_name $hostname;
    client_max_body_size 50M;
    $l
EOF
}

allow-list() {
    [[ "$mode" = public ]] && return
    cat <<EOF
    include /etc/nginx/shared-conf/private-service.conf;
EOF
}

ssl() {
    [[ "$hostname" =~ .*pendrellvale.home ]] && return
    cat <<EOF
    include /etc/nginx/shared-conf/ssl.conf;
EOF
}

ssl-redirect() {
    [[ "$hostname" =~ .*pendrellvale.home ]] && return
    cat <<EOF
server {
    server_name $hostname;
    listen 80;
    return 301 https://\$host\$request_uri;
}
EOF
}

pendrellvale_home_redirect() {
    [[ "$redirect" ]] || return
    cat <<EOF
server {
    server_name $redirect;
    listen 80;
    return 301 https://$hostname\$request_uri;
}
EOF
}

if [[ -e .$target ]]; then
    echo "copying .$target to $target"
    sudo cp .$target $target
else
    echo "generting $target"
    cat <<EOF | sudo tee $target >/dev/null
server {
$(listen)

$(ssl)

$(allow-list)

    location / {
        proxy_set_header Host \$host;
        proxy_set_header X-Forwarded-Host \$host;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_pass http://127.0.0.1:$port;
    }
}
$(ssl-redirect)
$(pendrellvale_home_redirect)
EOF
fi
sudo chmod 644 $target | grep -v retained || true
