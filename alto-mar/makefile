.DEFAULT_GOAL = install

include .env
DIRS := $(DATA_DIR)/alto-mar/media \
		$(DATA_DIR)/alto-mar/torrents \
		bazarr \
		radarr \
		sonarr \
		qbittorrent \
		prowlarr \
		scraparr
include ../root.mk

.PHONY: install

install: dirs
