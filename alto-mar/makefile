include .env

.PHONY: install

DIRS = $(DATA_DIR)/alto-mar/media $(DATA_DIR)/alto-mar/torrents bazarr radarr sonarr qbittorrent prowlarr scraparr

install: $(DIRS)

$(DIRS):
	mkdir -p $@
