include .env

.PHONY: install

DIRS = $(DB_DIR)/basement/db $(DB_DIR)/basement/memnarch $(DB_DIR)/basement/rattlesnake $(DB_DIR)/basement/reaction-bot blind-eternities planar-bridge

install: $(DIRS)

$(DIRS):
	mkdir -p $@
