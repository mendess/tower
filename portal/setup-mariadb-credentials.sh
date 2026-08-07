#!/bin/bash

case "$1" in
    clear)
        docker exec nextcloud-mariadb sh -c 'rm -f /tmp/credentials.cnf'
        ;;
    init|*)
        docker exec nextcloud-mariadb sh -c 'cat > /tmp/credentials.cnf <<EOF
[client]
user=$MYSQL_USER
password=$MYSQL_PASSWORD
EOF'
        ;;
esac
