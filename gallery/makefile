.DEFAULT_GOAL = install

include .env
DIRS := $(DB_DIR)/gallery/jellyfin/config \
		$(DB_DIR)/gallery/jellyfin/cache \
		$(DATA_DIR)/gallery/immich \
		$(DB_DIR)/gallery/immich/ml \
		$(DB_DIR)/gallery/immich/db
include ../foundations.mk

.PHONY: install alto-marr

install: alto-marr dirs

alto-marr:
	cd ../alto-marr && $(MAKE)
