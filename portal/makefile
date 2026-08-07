.DEFAULT_GOAL = install

include .env
include ../foundations.mk

.PHONY: install borgmatic repo-create run-backup

CONFIG = $(shell find ./etc | sed 's|\.||') $(shell find ./usr | sed 's|\.||')

SERVICES = $(call user-timer,nextcloud-backup) $(call timer,borgmatic)

## To generate the encrypted borgmatic.pw file this command was used
# systemd-ask-password -n | sudo systemd-creds encrypt - /etc/credstore.encrypted/borgmatic.pw

install: /usr/bin/borgmatic $(CONFIG) ~/.local/share/borgmatic $(SERVICES)
test: /usr/bin/borgmatic $(CONFIG) ~/.local/share/borgmatic $(SERVICES)
	echo $^

~/.local/share/borgmatic:
	mkdir $@

.ONESHELL: repo-create
repo-create: install
	sudo borgmatic repo-create --encryption repokey

.ONESHELL: run-backup
run-backup: install
	sudo borgmatic create --verbosity 2
