#!/bin/bash

docker exec nextcloud-mariadb sh -c 'cat > /tmp/credentials.cnf <<EOF
[client]
user=$MYSQL_USER
password=$MYSQL_PASSWORD
EOF'

#docker exec --user mysql -it nextcloud-mariadb mariadb-dump --defaults-extra-file=/tmp/credentials.cnf --single-transaction --default-character-set=utf8mb4
