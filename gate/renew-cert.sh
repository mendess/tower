#!/usr/bin/env bash

set -euo pipefail

sudo certbot certonly --preferred-challenges=dns -d '*.mendess.xyz'  -d 'mendess.xyz' --manual

sudo certbot certificates
