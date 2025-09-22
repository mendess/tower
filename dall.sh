#!/bin/bash

down() {
    for d in *; do (
        [ -d "$d" ] || exit
        cd "$d" || exit
        echo "::::: down $d"
        [ -e docker-compose.yaml ] && docker compose down
    ) done
}

up() {
    for d in *; do (
        [ -d "$d" ] || exit
        cd "$d" || exit
        echo "::::: up $d"
        [ -e docker-compose.yaml ] && docker compose up -d
        make
    ) done
}

case "$1" in
    down) down;;
    up) up;;
esac
