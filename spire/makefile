.DEFAULT_GOAL = install

include .env
DIRS = $(DB_DIR)/spire/homer/
include ../foundations.mk

CONFIG = ~/vault/spire/homer/config.yml

.PHONY: install

/usr/%: ./usr/%
	sudo rsync -av $< $@

install: $(call bin,wol) dirs $(CONFIG) /usr/lib/systemd/system/docker-wol.service $(call sctl,docker-wol)

$(CONFIG):
	ln ./homer/config.yml $@
