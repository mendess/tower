.DEFAULT_GOAL = install

include .env
include ../foundations.mk

.PHONY: install borgmatic repo-create run-backup

CONFIG = $(shell find ./etc | sed 's|\.||') $(shell find ./usr | sed 's|\.||')

SERVICES = $(call user-timer,nextcloud-backup) $(call user-timer,borgmatic)

install: /usr/bin/borgmatic $(CONFIG) ~/.local/share/borgmatic $(SERVICES)
test: /usr/bin/borgmatic $(CONFIG) ~/.local/share/borgmatic $(SERVICES)
	echo $^

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
