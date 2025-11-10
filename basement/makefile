.DEFAULT_GOAL = install

include .env
DIRS := $(DB_DIR)/basement/db \
		$(DB_DIR)/basement/memnarch \
		$(DB_DIR)/basement/rattlesnake \
		$(DB_DIR)/basement/reaction-bot \
		$(DB_DIR)/basement/blind-eternities \
		blind-eternities \
		planar-bridge
include ../foundations.mk

.PHONY: install

install: dirs
