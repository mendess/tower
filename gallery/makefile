.DEFAULT_GOAL = install

include .env
DIRS := $(DB_DIR)/gallery/jellyfin/config \
		$(DB_DIR)/gallery/jellyfin/cache \
		$(DATA_DIR)/gallery/immich \
		$(DB_DIR)/gallery/immich/ml \
		$(DB_DIR)/gallery/immich/db
include ../foundations.mk

.PHONY: install alto-mar

install: alto-mar dirs

alto-mar:
	cd ../alto-mar && $(MAKE)
