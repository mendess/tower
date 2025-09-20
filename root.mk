.PHONY: dirs

define sctl
	/etc/systemd/system/multi-user.target.wants/$(1).service
endef

define bin
	/usr/bin/$(1)
endef

dirs: $(DIRS)

root_dirs: $(ROOT_DIRS)

$(DIRS):
	mkdir -p $@

$(ROOT_DIRS):
	sudo mkdir -p $@

/usr/bin/%:
	sudo pacman -S $(@F)

$(call sctl,%):
	sudo systemctl enable $(basename $*) --now
