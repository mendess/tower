.DEFAULT_GOAL = install

include .env
include ../foundations.mk

.PHONY: install borgmatic repo-create run-backup

CONFIG = $(shell find ./etc | sed 's|\.||') $(shell find ./usr | sed 's|\.||')

SERVICES = $(call user-sctl,nextcloud-backup,timer)

install: /usr/bin/borgmatic $(CONFIG) ~/.local/share/borgmatic $(SERVICES)

~/.local/share/borgmatic:
	mkdir $@

.ONESHELL: repo-create
repo-create: install
	export BORG_PASSCOMMAND="cat ./borg-passphrase"
	borgmatic repo-create --encryption repokey

.ONESHELL: run-backup
run-backup: install
	export BORG_PASSCOMMAND="cat ./borg-passphrase"
	borgmatic create --verbosity 2
