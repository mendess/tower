include .env

.PHONY: install alto-mar

DIRS = jellyfin \
	   $(DATA_DIR)/gallery/immich \
	   $(DB_DIR)/gallery/immich/ml \
	   $(DB_DIR)/gallery/immich/db

install: alto-mar $(DIRS)

$(DIRS):
	mkdir -p $@

alto-mar:
	cd ../alto-mar && $(MAKE)
