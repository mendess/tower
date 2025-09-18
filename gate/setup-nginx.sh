#!/bin/bash

set -e

if [[ $(id -u) != 0 ]]; then
    echo "this script needs to be run as root"
    exit 1
fi

declare -A ports
ports=(
    [mendess.xyz]=8042
    [blind-eternities.mendess.xyz]=1651
    [planar-bridge.mendess.xyz]=1711
    [grafana.mendess.xyz]=3000
)

pacman -Q nginx certbot certbot-nginx || pacman -Sy nginx certbot certbot-nginx

echo -e "\n\n ::::::: setting up nginx :::::: \n\n"

cat <<EOF | tee /etc/nginx/nginx.conf
worker_processes  1;

# Load all installed modules
include modules.d/*.conf;

events {
    worker_connections  1024;
}


http {
    include       mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    keepalive_timeout  65;
    server_names_hash_bucket_size 64;
    types_hash_max_size 2048;
    types_hash_bucket_size 128;


    include /etc/nginx/sites-enabled/*;
}
EOF
nginx -t || exit

echo

mkdir -v -p /etc/nginx/sites-enabled
mkdir -v -p /etc/nginx/sites-available

echo

for domain in "${!ports[@]}"; do
    echo -e "configuring $domain"
    cat <<EOF | tee /etc/nginx/sites-available/$domain
server {
    server_name $domain;
    listen 80;
    location / {
        proxy_pass http://127.0.0.1:${ports[$domain]};
    }
}
EOF
    nginx -t || exit
    ln -svf /etc/nginx/{sites-available,sites-enabled}/$domain
    echo
done

sudo systemctl stop nginx || :
sudo systemctl enable nginx --now

echo -e "\n\n ::::::: setting up certbot :::::: \n\n"

for domain in "${!ports[@]}"; do
    echo "configuring ssl for $domain"
    certbot --nginx -d "$domain"
done

systemctl enable certbot-renew.timer --now
