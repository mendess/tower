.DEFAULT_GOAL = install

include .env
ROOT_DIRS = /etc/nginx/sites-enabled /etc/nginx/sites-available
include ../root.mk


install: unbound wireguard nginx

# ----------------- UNBOUND ---------------------
.PHONY: install unbound wireguard update-unbound update-wg wg-down config config-wg wg0

unbound: config /usr/bin/unbound $(call sctl,unbound) /etc/unbound/trusted-key.key

update-unbound: config
	sudo systemctl restart unbound

config-unbound: $(shell find ./etc/unbound | sed 's|\.||')
	sudo rsync -av --update --chown=unbound:unbound ./etc/unbound/ /etc/unbound/

/etc/unbound/trusted-key.key:
	sudo -u unbound unbound-anchor -a /etc/unbound/trusted-key.key

# ----------------- WIREGUARD ---------------------
# source: https://web.archive.org/web/20250911080027/https://robertlathanh.com/2025/03/setting-up-a-vpn-for-home-intranet-access-with-wireguard/
.PHONY: wireguard update-wg wg-down config-wg $(WG0)

WG0 = /proc/self/net/dev_snmp6/wg0

wireguard: config-wg /usr/bin/qrencode /usr/bin/iptables /usr/bin/wg $(WG0)

update-wg: wg-down config-wg $(WG0)

wg-down:
	-ip link show dev wg0 &> /dev/null && sudo wg-quick down /etc/wireguard/wg0.conf

config-wg:
	@./gen-key.sh
	@sudo test /etc/wireguard/wg0.conf -nt ./etc/wireguard/wg0.conf || \
	sed \
		"s|REPLACE__PRIVATE_KEY|$$(sudo cat /etc/wireguard/privatekey)|" \
		./etc/wireguard/wg0.conf | \
		sudo tee /etc/wireguard/wg0.conf

/usr/bin/wg:
	sudo pacman -S wireguard-tools

$(WG0):
	sudo wg-quick up /etc/wireguard/wg0.conf

# ----------------- NGINX ---------------------
.PHONY: default install configure_domains configure_certbot check_reload

DOMAINS_WITH_PORT = mendess.xyz:8042 \
	blind-eternities.mendess.xyz:1651 \
	planar-bridge.mendess.xyz:1711 \
	pendrellvale.home:1025

DOMAINS = $(shell echo $(DOMAINS_WITH_PORT) | sed 's/:[^ ]*//g')

NGINX_SITE_FILES := $(addprefix /etc/nginx/sites-enabled/,$(DOMAINS))

SOFTWARE = $(addprefix /usr/bin/,nginx certbot certbot)

CERTBOT_NGINX = /usr/lib/python3.13/site-packages/certbot_nginx

nginx: $(ROOT_DIRS) $(SOFTWARE) $(CERTBOT_NGINX) /etc/nginx/nginx.conf configure_domains configure_certbot check_reload

configure_domains: $(NGINX_SITE_FILES)

configure_certbot: /etc/systemd/system/timers.target.wants/certbot-renew.timer

check_reload:
	@[[ ! -e /tmp/nginx-needs-reload ]] || (sudo systemctl restart nginx && rm /tmp/nginx-needs-reload)

/etc/nginx/sites-enabled/%: /etc/nginx/sites-available/%
	sudo ln -s $< $@
	[[ "$*" =~ pendrellvale* ]] || sudo certbot --nginx -d "$*" --agree-tos
	@sudo nginx -t
	touch /tmp/nginx-needs-reload

/etc/nginx/sites-available/%.home:
	port=$$(printf "%s\n" $(DOMAINS_WITH_PORT) | grep "$*.home:" | cut -d ':' -f 2); \
	sed "s|DOMAIN|$*|;s|PORT|$$port|" domain-template-file.home | sudo tee $@
	@sudo nginx -t

/etc/nginx/sites-available/%:
	port=$$(printf "%s\n" $(DOMAINS_WITH_PORT) | grep "$*:" | cut -d ':' -f 2); \
	sed "s|DOMAIN|$*|;s|PORT|$$port|" domain-template-file | sudo tee $@
	@sudo nginx -t

/etc/nginx/nginx.conf:
	sudo cp ./etc/nginx/nginx.conf /etc/nginx/nginx.conf

/etc/systemd/system/timers.target.wants/certbot-renew.timer:
	sudo systemctl enable certbot-renew.timer --now

$(CERTBOT_NGINX):
	sudo pacman -S certbot-nginx
