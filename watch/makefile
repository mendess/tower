include .env

.PHONY: install prometheus update-prom

DIRS = $(DB_DIR)/watch/grafana

install: $(DIRS) prometheus

$(DIRS):
	mkdir -p $@

/usr/bin/prometheus:
	sudo pacman -S prometheus
	sudo systemctl enable prometheus --now

/usr/bin/prometheus-node-exporter:
	sudo pacman -S prometheus-node-exporter
	sudo systemctl enable prometheus-node-exporter --now

/etc/prometheus/prometheus.yml:
	sudo cp ./prometheus.yml /etc/prometheus/prometheus.yml

/etc/systemd/system/:
	sudo cp -v ./prometheus.service /etc/systemd/system/

prometheus: /usr/bin/prometheus /usr/bin/prometheus-node-exporter /etc/prometheus/prometheus.yml /etc/systemd/system

update-prom:
	sudo cp ./prometheus.yml /etc/prometheus/prometheus.yml
	sudo systemctl restart prometheus
