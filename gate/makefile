.DEFAULT_GOAL = install

include .env
include ../root.mk

# source: https://web.archive.org/web/20250911080027/https://robertlathanh.com/2025/03/setting-up-a-vpn-for-home-intranet-access-with-wireguard/

.PHONY: install unbound wireguard update-unbound update-wg wg-down config wg0

WG0 = /proc/self/net/dev_snmp6/wg0

install: unbound wireguard

unbound: config /usr/bin/unbound $(call sctl,unbound)
wireguard: config /usr/bin/qrencode /usr/bin/iptables /usr/bin/wg $(WG0)

# UTILS

update-unbound: config
	sudo systemctl restart unbound

update-wg: config wg-down $(WG0)

wg-down:
	-ip link show dev wg0 &> /dev/null && sudo wg-quick down /etc/wireguard/wg0.conf

# FILES

config:
	sudo rsync -av --update --chown=root:root ./etc/ /etc
	./gen-key.sh
	sudo sed -i \
		"s|REPLACE__PRIVATE_KEY|$$(sudo cat /etc/wireguard/privatekey)|" \
		/etc/wireguard/wg0.conf

$(WG0):
	sudo wg-quick up /etc/wireguard/wg0.conf

/usr/bin/wg:
	sudo pacman -S wireguard-tools
