.DEFAULT_GOAL = install

include .env
DIRS := $(DB_DIR)/watch/grafana
include ../foundations.mk

EXPORTERS = prometheus-node-exporter prometheus-systemd-exporter process-exporter nginx-prometheus-exporter

EXPORTER_SOFTWARE = $(call bin, $(EXPORTERS))
EXPORTER_SERVICES = $(foreach s,$(EXPORTERS),$(call sctl,$(s)))

OVERRIDE_CONF = /etc/systemd/system/prometheus.service.d/override.conf

.PHONY: install prometheus exporters update-prom

install: dirs prometheus

prometheus: /usr/bin/prometheus /etc/prometheus/prometheus.yml $(OVERRIDE_CONF) exporters $(call sctl,prometheus)

exporters: $(EXPORTER_SOFTWARE) $(EXPORTER_SERVICES)

/usr/bin/process-exporter:
	aura -S prometheus-process-exporter-bin
