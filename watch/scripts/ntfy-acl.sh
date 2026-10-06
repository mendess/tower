#!/usr/bin/env bash

set -euo pipefail

ntfy() {
    docker compose exec ntfy ntfy "$@"
}

mapfile -t users < <(ntfy user l | grep user | cut -f2 -d' ' | grep -v -F '*')

ntfy access --reset
for user in "${users[@]}"; do
    ntfy access "$user" "$user*" rw
done
