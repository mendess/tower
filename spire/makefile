.DEFAULT_GOAL = install

include .env
DIRS = $(DB_DIR)/spire/homer/
include ../foundations.mk

CONFIG = ~/vault/spire/homer/config.yml
HOME_ASSISTANT_CONFIG = $(shell find ./etc | sed 's|\.||') $(shell find ./usr | sed 's|\.||')

.PHONY: install

/usr/%: ./usr/%
	sudo rsync -av $< $@

install: dirs $(CONFIG) $(HOME_ASSISTANT_CONFIG)

$(CONFIG):
	ln ./homer/config.yml $@
