.DEFAULT_GOAL = install

include .env
DIRS = $(DB_DIR)/spire/homer/ \
	   $(DB_DIR)/spire/nextcloud/backups \
	   $(DB_DIR)/spire/actual/data \
	   $(DB_DIR)/spire/mosquitto/config \
	   $(DB_DIR)/spire/mosquitto/data \
	   $(DB_DIR)/spire/mosquitto/log
include ../foundations.mk

CONFIG = ~/vault/spire/homer/config.yml
HOME_ASSISTANT_CONFIG = $(shell find ./etc | sed 's|\.||') $(shell find ./usr | sed 's|\.||')
SERVICES = $(call socket,hass-bridge) $(call sctl,hass-bridge)

.PHONY: install hass-bridge

.ONESHELL: install
install: dirs $(CONFIG) $(HOME_ASSISTANT_CONFIG) $(SERVICES)
	@for f in $(call stamp_file,$(HOME_ASSISTANT_CONFIG)); do [ -e $$f ] && reload+=($$f); done; [ "$${reload[*]}" ] || exit 0
	rm -v $${reload[@]}
	@echo "reloading hass-bridge"
	sudo systemctl daemon-reload
	sudo systemctl restart hass-bridge.service

$(DB_DIR)/spire/nextcloud/backups:
	mkdir $@
	chmod 770 $@
	sudo chown 33:mendess $@

$(CONFIG):
	ln ./homer/config.yml $@

hass-bridge:
	cargo install --git https://github.com/mendess/hass-bridge.git
	sudo install --verbose $(CARGO_HOME)/bin/hass-bridge /usr/local/bin
	curl -s https://raw.githubusercontent.com/mendess/hass-bridge/refs/heads/master/host-run.sh | sudo tee ./home-assistant/host-run.sh
	sudo chmod 777 ./home-assistant/host-run.sh
