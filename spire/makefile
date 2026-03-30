.DEFAULT_GOAL = install

include .env
DIRS = $(DB_DIR)/spire/homer/ $(DB_DIR)/spire/nextcloud/backups
include ../foundations.mk

CONFIG = ~/vault/spire/homer/config.yml
HOME_ASSISTANT_CONFIG = $(shell find ./etc | sed 's|\.||') $(shell find ./usr | sed 's|\.||')

.PHONY: install

install: dirs $(CONFIG) $(HOME_ASSISTANT_CONFIG)

$(DB_DIR)/spire/nextcloud/backups:
	mkdir $@
	chmod 770 $@
	sudo chown 33:mendess $@

$(CONFIG):
	ln ./homer/config.yml $@
