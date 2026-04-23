#!/bin/bash

output=$(echo "$@" | socat -t 3600 - UNIX-CONNECT:$XDG_RUNTIME_DIR/hass-bridge/socket)

case "$(printf "%s" "$output" | jq -jr .status)" in
    success)
        printf "%s" "$output" | jq -jr .stdout
        printf "%s" "$output" | jq -jr .stderr >&2
        exit "$(echo "$output" | jq .exit -r)"
        ;;
    failure)
        printf "%s" "$output" | jq -jr .error >&2
        exit 70
        ;;
esac
