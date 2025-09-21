.DEFAULT_GOAL = install

include .env
ROOT_DIRS = /etc/nginx/sites-enabled /etc/nginx/sites-available
include ../foundations.mk


.PHONY: install
install: unbound wireguard nginx

# ----------------- UNBOUND ---------------------
.PHONY: unbound config-unbound

UNBOUND_CONFIG = $(shell find ./etc/unbound | sed 's|\.||')

unbound: /usr/bin/unbound /etc/unbound/trusted-key.key $(call sctl,unbound) config-unbound

.ONESHELL: config-unbound
config-unbound: $(UNBOUND_CONFIG)
	@for f in $(call stamp_file,$(UNBOUND_CONFIG)); do [ -e $$f ] && reload+=($$f); done; [ "$${reload[*]}" ] || exit 0
	rm $${reload[@]}
	sudo systemctl restart unbound

/etc/unbound/trusted-key.key:
	sudo -u unbound unbound-anchor -a /etc/unbound/trusted-key.key

# ----------------- WIREGUARD ---------------------
# source: https://web.archive.org/web/20250911080027/https://robertlathanh.com/2025/03/setting-up-a-vpn-for-home-intranet-access-with-wireguard/
.PHONY: wireguard update-wg wg-down config-wg $(WG0)

WG0 = /proc/self/net/dev_snmp6/wg0

wireguard: config-wg $(call bin,qrencode iptables wg) $(WG0)

update-wg: wg-down config-wg $(WG0)

wg-down:
	-ip link show dev wg0 &> /dev/null && sudo wg-quick down /etc/wireguard/wg0.conf

.ONESHELL: config-wg
config-wg:
	@./gen-key.sh
	@sudo test /etc/wireguard/wg0.conf -nt ./etc/wireguard/wg0.conf && exit 0
	sed \
		"s|REPLACE__PRIVATE_KEY|$$(sudo cat /etc/wireguard/privatekey)|" \
		./etc/wireguard/wg0.conf | \
		sudo tee /etc/wireguard/wg0.conf

/usr/bin/wg:
	sudo pacman -S wireguard-tools

$(WG0):
	sudo wg-quick up /etc/wireguard/wg0.conf

# ----------------- NGINX ---------------------
.PHONY: nginx configure-domains configure-certbot

DOMAINS_WITH_PORT = mendess.xyz:8042 \
	blind-eternities.mendess.xyz:1651 \
	planar-bridge.mendess.xyz:1711 \
	pendrellvale.home:1025

DOMAINS = $(shell echo $(DOMAINS_WITH_PORT) | sed 's/:[^ ]*//g')

NGINX_SITE_FILES := $(addprefix /etc/nginx/sites-enabled/,$(DOMAINS))

SOFTWARE = $(call bin,nginx certbot certbot)

CERTBOT_NGINX = /usr/lib/python3.13/site-packages/certbot_nginx

nginx: $(ROOT_DIRS) $(SOFTWARE) $(CERTBOT_NGINX) configure-domains configure-certbot config-nginx

configure-domains: $(NGINX_SITE_FILES)

configure-certbot: /etc/systemd/system/timers.target.wants/certbot-renew.timer

.ONESHELL: config-nginx
config-nginx: /etc/nginx/nginx.conf
	@for f in $(call stamp_file,/etc/nginx/nginx.conf); do [ -e $$f ] && reload+=($$f); done; [ "$${reload[*]}" ] || exit 0
	rm $${reload[@]}
	sudo systemctl restart nginx

/etc/nginx/sites-enabled/%: /etc/nginx/sites-available/%
	sudo ln -s $< $@
	[[ "$*" =~ pendrellvale* ]] || sudo certbot --nginx -d "$*" --agree-tos
	@sudo nginx -t
	touch $(call stamp_file,/etc/nginx/nginx.conf)

/etc/nginx/sites-available/%.home:
	port=$$(printf "%s\n" $(DOMAINS_WITH_PORT) | grep "$*.home:" | cut -d ':' -f 2); \
	sed "s|DOMAIN|$*|;s|PORT|$$port|" domain-template-file.home | sudo tee $@
	@sudo nginx -t

/etc/nginx/sites-available/%:
	port=$$(printf "%s\n" $(DOMAINS_WITH_PORT) | grep "$*:" | cut -d ':' -f 2); \
	sed "s|DOMAIN|$*|;s|PORT|$$port|" domain-template-file | sudo tee $@
	@sudo nginx -t

/etc/systemd/system/timers.target.wants/certbot-renew.timer:
	sudo systemctl enable certbot-renew.timer --now

$(CERTBOT_NGINX):
	sudo pacman -S certbot-nginx
