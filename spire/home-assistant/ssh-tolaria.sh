#!/bin/bash
ssh -i /config/.ssh/id_ed25519 -o UserKnownHostsFile=/config/.ssh/known_hosts mendess@tolaria.lan -- "$@"
