.DEFAULT_GOAL = install

include .env
ROOT_DIRS = /etc/nginx/sites-enabled/public /etc/nginx/sites-available/public /etc/nginx/sites-enabled/private /etc/nginx/sites-available/private
include ../foundations.mk

.PHONY: install
install: ssh unbound wireguard nginx dnsmasq nft

# ------------------- SSHD ----------------------
.PHONY: ssh
SSHD_CONFIG = $(shell find ./etc/ssh | sed 's|\.||')

/etc/ssh/sshd_config.bak:
	sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

.ONESHELL: ssh
ssh: /etc/ssh/sshd_config.bak $(SSHD_CONFIG)
	@for f in $(call stamp_file,$(SSHD_CONFIG)); do [ -e $$f ] && reload+=($$f); done; [ "$${reload[*]}" ] || exit 0
	rm -v $${reload[@]}
	@echo "reloading sshd"
	sudo systemctl restart sshd

# ------------------ UNBOUND --------------------
.PHONY: unbound config-unbound

UNBOUND_CONFIG = $(shell find ./etc/unbound | sed 's|\.||')

unbound: /usr/bin/unbound /etc/unbound/trusted-key.key $(call sctl,unbound) config-unbound

./etc/unbound/unbound.conf.d/local.conf: ./unbound-scripts/gen-local-dns.sh ../port-docs.toml
	./unbound-scripts/gen-local-dns.sh > $@

.ONESHELL: config-unbound
config-unbound: $(UNBOUND_CONFIG)
	@for f in $(call stamp_file,$(UNBOUND_CONFIG)); do [ -e $$f ] && reload+=($$f); done; [ "$${reload[*]}" ] || exit 0
	rm -v $${reload[@]}
	@echo "reloading unbound"
	sudo unbound-checkconf || exit 1
	@sudo chown unbound:unbound /etc/unbound -Rv | grep -v retained
	sudo systemctl restart unbound

/etc/unbound/trusted-key.key:
	-sudo -u unbound unbound-anchor -a /etc/unbound/trusted-key.key

# ----------------- WIREGUARD ---------------------
# source: https://web.archive.org/web/20250911080027/https://robertlathanh.com/2025/03/setting-up-a-vpn-for-home-intranet-access-with-wireguard/

WG_CONFIGS := $(wildcard ./etc/wireguard/*.conf)
WG_NETWORK_NAMES := $(patsubst ./etc/wireguard/%.conf,%,$(WG_CONFIGS))
WG_SERVICES := $(addprefix /etc/systemd/system/multi-user.target.wants/wg-quick@, $(addsuffix .service, $(WG_NETWORKS)))
WG_NETWORKS := $(addprefix wg-,$(WG_NETWORK_NAMES))
NETWORK_MANAGER = /etc/NetworkManager/conf.d/99-unmanaged-devices.conf

.PHONY: wireguard wg-down wg-conf

wireguard: $(call bin,qrencode wg) $(WG_NETWORKS) $(WG_SERVICES) /etc/sysctl.conf $(shell find ./etc/systemd | sed 's|\.||') $(NETWORK_MANAGER)

$(NETWORK_MANAGER): $(WG_CONFIGS)
	sudo ./wg-scripts/generate-network-manager-conf.sh $(WG_NETWORK_NAMES) -o $(NETWORK_MANAGER)

wg-%:
	@sudo ./wg-scripts/makefile-entrypoint.sh "$*"

wg-down-%:
	@printf "$(RED) DOWN$(RESET) Taking down interface $*\n"
	test ! -e /proc/self/net/dev_snmp6/$* || sudo wg-quick down $*

wg-%.conf:
	@printf "$(YELLOW)CONFIG$(RESET) Generating WireGuard config for $*\n"
	@./wg-scripts/config-wg.sh $*

/usr/bin/wg:
	sudo pacman -S wireguard-tools

# ----------------- NGINX ---------------------
.PHONY: nginx config-nginx configure-domains configure-certbot nginx-clean

PRIVATE_DOMAINS := \
	$(shell ../homunculus show --reachable private-proxy --csv | awk -F, 'NR > 1 {print $$6}')
PUBLIC_DOMAINS := \
	$(shell ../homunculus show --reachable public-proxy  --csv | awk -F, 'NR > 1 {print $$6}') minecraft.mendess.xyz

NGINX_SITE_FILES := \
	$(addprefix /etc/nginx/sites-enabled/public/,$(PUBLIC_DOMAINS)) \
	$(addprefix /etc/nginx/sites-enabled/private/,$(PRIVATE_DOMAINS))

SOFTWARE = $(call bin,nginx certbot certbot)

CERTBOT_NGINX = /usr/lib/python3.14/site-packages/certbot_nginx

SHARED_CONF = $(shell find ./etc/nginx/shared-conf | sed 's|\.||')

nginx: $(ROOT_DIRS) $(SOFTWARE) $(CERTBOT_NGINX) $(SHARED_CONF) configure-domains configure-certbot config-nginx

configure-domains: $(NGINX_SITE_FILES)

configure-certbot: #/etc/systemd/system/timers.target.wants/certbot-renew.timer
	@true # disabled while I wait to switch from namecheap to somewhere that lets me automate wildcard domains

.ONESHELL: config-nginx
config-nginx: /etc/nginx/nginx.conf
	@for f in $(call stamp_file,/etc/nginx/nginx.conf $(SHARED_CONF)); do [ -e $$f ] && reload+=($$f); done; [ "$${reload[*]}" ] || exit 0
	@rm $${reload[@]}
	@echo "reloading nginx"
	sudo nginx -t || exit 1
	sudo systemctl restart nginx

/etc/nginx/sites-enabled/%: /etc/nginx/sites-available/%
	@test -e $<
	@test -e $@ || sudo ln -sv $< $@
	@sudo nginx -t
	touch $(call stamp_file,/etc/nginx/nginx.conf)

.PRECIOUS: /etc/nginx/sites-available/%
/etc/nginx/sites-available/%: ./etc/nginx/sites-available/%
	./nginx-scripts/gen-domain-conf.sh $@
.PRECIOUS: /etc/nginx/sites-available/%
/etc/nginx/sites-available/%: ../port-docs.toml ./nginx-scripts/gen-domain-conf.sh
	./nginx-scripts/gen-domain-conf.sh $@

/etc/systemd/system/timers.target.wants/certbot-renew.timer:
	sudo systemctl enable certbot-renew.timer --now

nginx-clean:
	sudo rm -v /etc/nginx/sites-enabled/public/*
	sudo rm -v /etc/nginx/sites-enabled/private/*
	sudo rm -v /etc/nginx/sites-available/public/*
	sudo rm -v /etc/nginx/sites-available/private/*

$(CERTBOT_NGINX):
	sudo pacman -S certbot-nginx
	sudo certbot certonly --preferred-challenges=dns -d '*.mendess.xyz'  -d 'mendess.xyz'

# ----------------- DHCP ---------------------

.PHONY: dnsmasq config-dnsmasq

DNSMASQ_CONFIG = /etc/dnsmasq.conf

dnsmasq: config-dnsmasq $(call sctl,dnsmasq) /etc/hosts
	./toggle-static-ip.sh apply

.ONESHELL: config-dnsmasq
config-dnsmasq: $(DNSMASQ_CONFIG)
	@for f in $(call stamp_file,$(DNSMASQ_CONFIG)); do [ -e $$f ] && reload+=($$f); done; [ "$${reload[*]}" ] || exit 0
	rm -v $${reload[@]}
	@echo "reloading dnsmasq"
	sudo systemctl restart unbound


# ----------------- NFT ---------------------
.PHONY: nft

NFT_CONFIG = /etc/nftables.conf /etc/sysctl.conf $(call sctl,nftables)

.ONESHELL: nft
nft: /usr/bin/nft $(NFT_CONFIG)
	@for f in $(call stamp_file,$(NFT_CONFIG)); do [ -e $$f ] && reload+=($$f); done; [ "$${reload[*]}" ] || exit 0
	rm -v $${reload[@]}
	@echo "reloading nft"
	sudo systemctl restart nftables
	sudo sysctl -p

/usr/bin/nft:
	sudo pacman -S nftables
