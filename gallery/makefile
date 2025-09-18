.DEFAULT_GOAL = install

include .env
DIRS := jellyfin \
		$(DATA_DIR)/gallery/immich \
		$(DB_DIR)/gallery/immich/ml \
		$(DB_DIR)/gallery/immich/db
include ../root.mk

.PHONY: install alto-mar

install: alto-mar dirs

alto-mar:
	cd ../alto-mar && $(MAKE)
