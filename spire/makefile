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
SERVICES = $(call user-sctl,hass-bridge)

.PHONY: install

.ONESHELL: install
install: dirs $(CONFIG) $(HOME_ASSISTANT_CONFIG) $(SERVICES)
	@for f in $(call stamp_file,$(HOME_ASSISTANT_CONFIG)); do [ -e $$f ] && reload+=($$f); done; [ "$${reload[*]}" ] || exit 0
	rm -v $${reload[@]}
	@echo "reloading hass-bridge"
	systemctl --user daemon-reload
	systemctl --user restart hass-bridge.service

$(DB_DIR)/spire/nextcloud/backups:
	mkdir $@
	chmod 770 $@
	sudo chown 33:mendess $@

$(CONFIG):
	ln ./homer/config.yml $@
