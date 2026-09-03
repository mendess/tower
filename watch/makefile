.DEFAULT_GOAL = install

include .env
include ../foundations.mk

EXPORTERS = prometheus-node-exporter prometheus-systemd-exporter process-exporter nginx-prometheus-exporter

EXPORTER_SOFTWARE = $(call bin, $(EXPORTERS))
EXPORTER_SERVICES = $(foreach s,$(EXPORTERS),$(call sctl,$(s))) $(call sctl,prometheus_wireguard_exporter) $(call sctl,prometheus-nginxlog-exporter)

CONFIGS = $(shell find ./etc | sed 's|\.||') $(shell find ./usr | sed 's|\.||')

.PHONY: install prometheus exporters update-prom

.ONESHELL: install
install: dirs $(CONFIGS) prometheus
	@for f in $(call stamp_file,$(CONFIGS)); do [ -e $$f ] && reload+=($$f); done; [ "$${reload[*]}" ] || exit 0
	rm -v $${reload[@]}
	@echo "reloading prometheus $(EXPORTERS) prometheus_wireguard_exporter"
	sudo systemctl daemon-reload
	sudo systemctl restart prometheus $(EXPORTERS) prometheus_wireguard_exporter

prometheus: /usr/bin/prometheus /etc/prometheus/prometheus.yml exporters $(call sctl,prometheus)

exporters: $(EXPORTER_SOFTWARE) $(EXPORTER_SERVICES) /usr/local/bin/prometheus_wireguard_exporter

WG_CONFIGS = $(shell find ../gate/etc/wireguard/)

/etc/prometheus/prometheus.yml: $(WG_CONFIGS) ./scripts/generate-eyeball-naming.sh
	./scripts/generate-eyeball-naming.sh | sudo tee $@ >/dev/null
	touch $(call stamp_file,/etc/prometheus/prometheus.yml)

/usr/bin/process-exporter:
	aura -S prometheus-process-exporter-bin

/usr/local/bin/prometheus_wireguard_exporter:
	cargo install --git https://github.com/MindFlavor/prometheus_wireguard_exporter
	sudo install --verbose $(CARGO_HOME)/bin/prometheus_wireguard_exporter /usr/local/bin
