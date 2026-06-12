#!/bin/bash

case $PWD in
    *tower/spire/home-assistant*) BASE=$PWD ;;
    *) BASE="/config"
esac
ssh -i "${BASE}/.ssh/id_ed25519" -o UserKnownHostsFile="${BASE}/.ssh/known_hosts" mendess@tolaria.lan -- "$@"
