current-dir := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
docker-compose := docker compose -f $(current-dir)docker-compose.yml
make := /usr/bin/make

.PHONY: all
all: build-quick-and-restart

.PHONY: build-quick-and-restart
build-quick-and-restart: build-quick restart

.PHONY: build-quick
build-quick:
	$(docker-compose) build

.PHONY: build-full-and-restart
build-full-and-restart: build-full restart

.PHONY: build-full
build-full:
	$(docker-compose) build --no-cache

.PHONY: start
start:
	$(docker-compose) up -d

.PHONY: destroy
destroy:
	$(docker-compose) down

.PHONY: restart
restart: destroy start

.PHONY: activate-rsyslog-for-forensyc
activate-rsyslog-for-forensyc:
	$(docker-compose) exec wims apt update
	$(docker-compose) exec wims apt install -y rsyslog
	$(docker-compose) exec wims /etc/init.d/rsyslog restart
	$(docker-compose) exec wims /etc/init.d/rsyslog status

# Wildcard target to output target execution duration.
# How to use this:
#  1. Have a target named 'do-something:'
#  2.a. Invoke target named 'make do-something' to invoke it as is.
#  2.b. Invoke target named 'make do-something-echoed' to invoke it with START and END echoed lines.
%-echoed:
	$(eval target := $(subst -echoed,,$@))
	@echo `date +"%Y-%m-%d %H:%M:%S"`" === START:" $(target)
	@bash -c "set -m; trap 'exit 0' INT; $(make) --no-print-directory $(target)"
	@echo `date +"%Y-%m-%d %H:%M:%S"`" === END  :" $(target)
