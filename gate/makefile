.DEFAULT_GOAL = install

include .env
ROOT_DIRS = /etc/nginx/sites-enabled /etc/nginx/sites-available
include ../foundations.mk


.PHONY: install
install: ssh unbound wireguard nginx

# ------------------- SSHD ----------------------
.PHONY: ssh
SSHD_CONFIG = $(shell find ./etc/ssh | sed 's|\.||')

/etc/ssh/sshd_config.bak:
	sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

ssh: /etc/ssh/sshd_config.bak $(SSHD_CONFIG)
	@for f in $(call stamp_file,$(SSHD_CONFIG)); do [ -e $$f ] && reload+=($$f); done; [ "$${reload[*]}" ] || exit 0
	rm -v $${reload[@]}
	@echo "reloading sshd"
	sudo systemctl restart sshd

# ------------------ UNBOUND --------------------
.PHONY: unbound config-unbound

UNBOUND_CONFIG = $(shell find ./etc/unbound | sed 's|\.||')

unbound: /usr/bin/unbound /etc/unbound/trusted-key.key $(call sctl,unbound) config-unbound

.ONESHELL: config-unbound
config-unbound: $(UNBOUND_CONFIG)
	@for f in $(call stamp_file,$(UNBOUND_CONFIG)); do [ -e $$f ] && reload+=($$f); done; [ "$${reload[*]}" ] || exit 0
	rm -v $${reload[@]}
	@echo "reloading unbound"
	sudo systemctl restart unbound

/etc/unbound/trusted-key.key:
	sudo -u unbound unbound-anchor -a /etc/unbound/trusted-key.key

# ----------------- WIREGUARD ---------------------
# source: https://web.archive.org/web/20250911080027/https://robertlathanh.com/2025/03/setting-up-a-vpn-for-home-intranet-access-with-wireguard/

NETWORK_ENABLED = $(shell find ./etc/wireguard -type f | sed -E 's|^.+/||; s|\.conf||; s|^|/proc/self/net/dev_snmp6/|')

$(info NETWORK_ENABLED is [${NETWORK_ENABLED}])

.PHONY: wireguard wg-update wg-down

wireguard: $(call bin,qrencode iptables wg) $(NETWORK_ENABLED)

# wg-up-%:
/proc/self/net/dev_snmp6/%: wg-%.conf
	@printf "$(GREEN)   UP$(RESET) Bringing up interface $*\n"
	sudo wg-quick up /etc/wireguard/$*.conf

wg-update-%: wg-down-% /proc/self/net/dev_snmp6/%
	@true

wg-down-%:
	@printf "$(RED) DOWN$(RESET) Taking down interface $*\n"
	test ! -e /proc/self/net/dev_snmp6/$* || sudo wg-quick down $*

wg-%.conf:
	@printf "$(YELLOW)CONFIG$(RESET) Generating WireGuard config for $*\n"
	@./scripts/config-wg.sh $*

/usr/bin/wg:
	sudo pacman -S wireguard-tools

# ----------------- NGINX ---------------------
.PHONY: nginx config-nginx configure-domains configure-certbot

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
	rm -v $${reload[@]}
	@echo "reloading nginx"
	sudo systemctl restart nginx

/etc/nginx/sites-enabled/%: /etc/nginx/sites-available/%
	sudo ln -s $< $@
	[[ "$*" =~ pendrellvale* ]] || sudo certbot --nginx -d "$*" --agree-tos
	@sudo nginx -t
	touch $(call stamp_file,/etc/nginx/nginx.conf)

/etc/nginx/sites-available/%.home: ./domain-template-file.home
	port=$$(printf "%s\n" $(DOMAINS_WITH_PORT) | grep "$*.home:" | cut -d ':' -f 2); \
	sed "s|DOMAIN|$*|;s|PORT|$$port|" domain-template-file.home | sudo tee $@
	@sudo nginx -t

/etc/nginx/sites-available/%: ./domain-template-file
	port=$$(printf "%s\n" $(DOMAINS_WITH_PORT) | grep "^$*:" | cut -d ':' -f 2); \
	echo $$port; \
	sed "s|DOMAIN|$*|;s|PORT|$$port|" domain-template-file | sudo tee $@
	@sudo nginx -t

/etc/systemd/system/timers.target.wants/certbot-renew.timer:
	sudo systemctl enable certbot-renew.timer --now

$(CERTBOT_NGINX):
	sudo pacman -S certbot-nginx
