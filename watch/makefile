.DEFAULT_GOAL = install

include .env
DIRS := $(DB_DIR)/watch/grafana
include ../foundations.mk

EXPORTERS = prometheus-node-exporter prometheus-systemd-exporter process-exporter nginx-prometheus-exporter

EXPORTER_SOFTWARE = $(call bin, $(EXPORTERS))
EXPORTER_SERVICES = $(foreach s,$(EXPORTERS),$(call sctl,$(s))) $(call sctl,prometheus_wireguard_exporter)

OVERRIDE_CONF = /etc/systemd/system/prometheus.service.d/override.conf
WG_EXPORTER_SERVICE = /usr/lib/systemd/system/prometheus_wireguard_exporter.service

.PHONY: install prometheus exporters update-prom

install: dirs prometheus

prometheus: /usr/bin/prometheus /etc/prometheus/prometheus.yml $(OVERRIDE_CONF) exporters $(call sctl,prometheus) $(WG_EXPORTER_SERVICE)

exporters: $(EXPORTER_SOFTWARE) $(EXPORTER_SERVICES) /usr/local/bin/prometheus_wireguard_exporter

/usr/bin/process-exporter:
	aura -S prometheus-process-exporter-bin

/usr/local/bin/prometheus_wireguard_exporter:
	cargo install --git https://github.com/MindFlavor/prometheus_wireguard_exporter
	sudo install --verbose $(CARGO_HOME)/bin/prometheus_wireguard_exporter /usr/local/bin
