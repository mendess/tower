.DEFAULT_GOAL = install

include .env
DIRS = $(DB_DIR)/spire/homer/
include ../root.mk

CONFIG = ~/vault/spire/homer/config.yml

.PHONY: install

install: dirs $(CONFIG)

$(CONFIG):
	ln ./homer/config.yml $@
