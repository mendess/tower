.DEFAULT_GOAL = install

include .env
DIRS := $(DATA_DIR)/alto-mar/media \
		$(DATA_DIR)/alto-mar/torrents \
		$(DB_DIR)/alto-mar/bazarr \
		$(DB_DIR)/alto-mar/radarr \
		$(DB_DIR)/alto-mar/sonarr \
		$(DB_DIR)/alto-mar/qbittorrent \
		$(DB_DIR)/alto-mar/prowlarr \
		scraparr
include ../root.mk

.PHONY: install

install: ./scraparr/config.yaml dirs

./scraparr/config.yaml:
	@test -e ./scraparr/config.yaml || ( echo "scraparr is not configured"; exit 1 )
