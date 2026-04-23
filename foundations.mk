.PHONY: dirs

RED    := $(shell printf '\033[0;31m')
GREEN  := $(shell printf '\033[0;32m')
YELLOW := $(shell printf '\033[0;33m')
BLUE   := $(shell printf '\033[0;34m')
CYAN   := $(shell printf '\033[0;36m')
RESET  := $(shell printf '\033[0m')

define sctl
	/etc/systemd/system/multi-user.target.wants/$(1).$(or $(2),service)
endef

define socket
	/etc/systemd/system/sockets.target.wants/$(1).socket
endef

define user-sctl
	$(HOME)/.config/systemd/user/default.target.wants/$(1).service
endef

define user-timer
	$(HOME)/.config/systemd/user/timers.target.wants/$(1).timer
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
	sudo systemctl daemon-reload
	sudo systemctl enable $(basename $*).service --now

$(call socket,%):
	sudo systemctl daemon-reload
	sudo systemctl enable $(basename $*).socket --now

$(call user-sctl,%):
	systemctl --user daemon-reload
	systemctl --user enable $(basename $*).service --now

$(call user-timer,%):
	systemctl --user daemon-reload
	systemctl --user enable $(basename $*).timer --now

define install_conf
	@if [ -d "$(1)" ]; then sudo mkdir -v -p $(2) ; else  sudo cp -v $(1) $(2) ; fi
	@sudo chown -v root:root $(2)
	@sudo chmod -v --reference=$(1) $(2)
	@sudo touch --reference=$(1) $(2)
	touch $(call stamp_file,$(2))
	@case "$(1)" in \
		*/systemd/user/*.service | */systemd/user/*.timer) systemctl --user daemon-reload && echo "reloaded user daemon";; \
		*/systemd/system/*.service | */systemd/system/*.timer) sudo systemctl daemon-reload && echo "reloaded system daemon";; \
	esac
endef

/etc/%: ./etc/%
	$(call install_conf,$<,$@)

/usr/%: ./usr/%
	$(call install_conf,$<,$@)

define stamp_file
	$(foreach arg,$(1),/tmp/tower-stamp$(shell echo $(arg) | tr '/' '-'))
endef
