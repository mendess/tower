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

define user-sctl
	$(HOME)/.config/systemd/user/default.target.wants/$(1).service
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

$(call user-sctl,%):
	systemctl --user enable $(basename $*) --now

define install_conf
	if [ -d "$(1)" ]; then sudo mkdir -v -p $(2) ; else  sudo cp -v $(1) $(2) ; fi
	sudo chown root:root $(2)
	sudo chmod --reference=$(1) $(2)
	sudo touch --reference=$(1) $(2)
	touch $(call stamp_file,$(2))
endef

/etc/%: ./etc/%
	$(call install_conf,$<,$@)

/usr/%: ./usr/%
	$(call install_conf,$<,$@)

define stamp_file
	$(foreach arg,$(1),/tmp/tower-stamp$(shell echo $(arg) | tr '/' '-'))
endef
