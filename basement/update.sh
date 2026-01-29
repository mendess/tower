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

    project=${project%@*}
    proj_dir="$HOME/scriptorium/$project"
    (
        cd "$proj_dir"
        git pull --rebase
    )
    case "$service" in
        *@*)
            IFS='@' read service git_hash <<<"$service"
            (
                cd "$proj_dir"
                git checkout "$git_hash"
            )
            undo=1
            ;;
    esac
    docker compose up "$service" -d --build
    if [[ "$undo" ]]; then
        (
            cd "$proj_dir"
            git checkout master
        )
    fi
done
