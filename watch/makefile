DIRS = ~/vault/watch/grafana

install: $(DIRS) prometheus

$(DIRS):
	mkdir -p $@

/etc/prometheus/prometheus.yml:
	sudo cp ./prometheus.yml /etc/prometheus/prometheus.yml

/etc/systemd/system/:
	sudo cp -v ./prometheus.service /etc/systemd/system/

prometheus: /etc/prometheus/prometheus.yml /etc/systemd/system
	sudo systemctl enable prometheus --now
