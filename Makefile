-include .env
PI ?= pi@raspberrypi.local
MEDIAMTX_VERSION ?= v1.15.5

help: ## show this help
	@awk -F' *:.*## ' '/^[a-z-]+ *:.*## /{printf "%-8s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

deploy: ## install/update mediamtx and config on the Pi (override host with PI=user@host)
	ssh $(PI) mkdir -p irpi
	scp mediamtx.yml irpi.service install.sh $(PI):irpi/
	ssh $(PI) "cd irpi && sh install.sh $(MEDIAMTX_VERSION)"

check: ## list cameras detected on the Pi
	ssh $(PI) rpicam-hello --list-cameras

status: ## show service status
	ssh $(PI) systemctl status irpi --no-pager

logs: ## follow service logs
	ssh $(PI) journalctl -u irpi -f

.PHONY: help deploy check status logs
