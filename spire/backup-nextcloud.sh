#!/bin/bash

set -euo pipefail

nextcloud=/home/mendess/vault/spire/nextcloud

backup_dir=$nextcloud/backups
mkdir -p "$backup_dir"

disable_maintenance() {
    docker exec --user www-data -it nextcloud php occ maintenance:mode --off
}

docker exec --user www-data -it nextcloud php occ maintenance:mode --on
trap disable_maintenance EXIT

docker exec --user www-data -it nextcloud tar \
        --verbose \
        --create \
        --file "/backups/nextcloud-data-backup.tar.xz" \
        "/var/www/html" \
        --ignore-failed-read \
        --use-compress-program='xz -9e'

docker exec --user mysql -it nextcloud-mariadb sh -c 'mariadb-dump --single-transaction --default-character-set=utf8mb4 -h localhost -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE' > $backup_dir/mariadb.sql
