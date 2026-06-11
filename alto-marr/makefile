.DEFAULT_GOAL = install

include .env
DIRS := scraparr
include ../foundations.mk

.PHONY: install

install: ./scraparr/config.yaml dirs

./scraparr/config.yaml:
	@test -e ./scraparr/config.yaml || ( echo "scraparr is not configured"; exit 1 )
