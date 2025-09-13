include .env

.PHONY: install alto-mar

DIRS = jellyfin

install: alto-mar $(DIRS)

$(DIRS):
	mkdir -p $@

alto-mar:
	cd ../alto-mar && $(MAKE)
