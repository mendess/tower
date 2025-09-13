.PHONY: install

DIRS = jellyfin

install: alto-mar $(DIRS)

$(DIRS):
	mkdir -p $@

alto-mar:
	cd ../alto-mar && $(MAKE)
