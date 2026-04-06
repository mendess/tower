.DEFAULT_GOAL = install

include .env
include ../foundations.mk

.PHONY: install borgmatic repo-create run-backup

install: borgmatic /etc/borgmatic /etc/borgmatic/config.yaml ~/.local/share/borgmatic

borgmatic: /usr/bin/borgmatic

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
