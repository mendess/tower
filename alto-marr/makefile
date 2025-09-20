.DEFAULT_GOAL = install

include .env
DIRS := $(DATA_DIR)/alto-marr/media \
		$(DATA_DIR)/alto-marr/torrents \
		$(DB_DIR)/alto-marr/bazarr \
		$(DB_DIR)/alto-marr/radarr \
		$(DB_DIR)/alto-marr/sonarr \
		$(DB_DIR)/alto-marr/qbittorrent \
		$(DB_DIR)/alto-marr/prowlarr \
		scraparr
include ../foundations.mk

.PHONY: install

install: ./scraparr/config.yaml dirs

./scraparr/config.yaml:
	@test -e ./scraparr/config.yaml || ( echo "scraparr is not configured"; exit 1 )
