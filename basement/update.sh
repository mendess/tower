#!/bin/bash
set -e

for reference in "${@}"; do
    IFS='/' read project service <<<"$reference"
    if [[ -z "$project" ]] && [[ -z "$service" ]]; then
        echo "reference: $reference is invalid"
    fi
    if [[ -z "$service" ]]; then
        service="$project"
    fi

    (
        cd "$HOME/scriptorium/$project"
        git pull --rebase
    )
    docker compose up "$service" -d --build
done
