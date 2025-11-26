.PHONY: dirs

RED    := $(shell printf '\033[0;31m')
GREEN  := $(shell printf '\033[0;32m')
YELLOW := $(shell printf '\033[0;33m')
BLUE   := $(shell printf '\033[0;34m')
CYAN   := $(shell printf '\033[0;36m')
RESET  := $(shell printf '\033[0m')

define sctl
	/etc/systemd/system/multi-user.target.wants/$(1).service
endef

define bin
	$(foreach arg,$(1),/usr/bin/$(arg))
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

/etc/%: ./etc/%
	if [ -d "$<" ]; then \
		mkdir -v -p $< ;\
		touch --reference=$@ $<;\
	else \
		sudo cp -v $< $@ ;\
	fi
	touch $(call stamp_file,$@)

define stamp_file
	$(foreach arg,$(1),/tmp/tower-stamp$(shell echo $(arg) | tr '/' '-'))
endef
