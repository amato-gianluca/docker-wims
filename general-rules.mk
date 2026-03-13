WIMS_CONTAINER_TAG ?= $(shell $(docker-compose) config --format json | jq -r '.services["wims"].logging.options.tag')
WIMS_CONTAINER_NAME := $(shell $(docker-compose) config --format json | jq -r '.services["wims"].container_name')

.PHONY: all
all: build-quick-and-restart

.PHONY: build-quick-and-restart
build-quick-and-restart: build-quick restart

.PHONY: build-quick
build-quick: copy-env
	$(docker-compose) build

# source-env-file and target-env-file variables are defined on the invoking Makefile.
.PHONY: copy-env
copy-env:
	cp --update=none $(source-env-file) $(target-env-file)

.PHONY: build-full-and-restart
build-full-and-restart: build-full restart

.PHONY: build-full
build-full: copy-env
	$(docker-compose) build --no-cache

.PHONY: start
start: warmup
	$(docker-compose) up -d

.PHONY: destroy
destroy:
	$(docker-compose) down --remove-orphans

.PHONY: restart
restart: destroy start

.PHONY: show-admin-password
show-admin-password:
	$(docker-compose) exec wims find log/ -name ".wimspass" -exec cat {} +
	$(docker-compose) exec wims find tmp/log/ -name ".wimspassone" -exec cat {} +

.PHONY: open-shell
open-shell:
	@$(docker-compose) exec wims bash

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

.PHONY: test
test: configuration-file-checking-echoed

# On latest WIMS version, when defined WIMS_PASS variable,
# the content of .wimspass is a randomly generated value.
.PHONY: configuration-file-checking
configuration-file-checking:
	docker run --rm --entrypoint test $(WIMS_IMAGE_NAME) -f /home/wims/log/.wimspass;
	docker run --rm --entrypoint test $(WIMS_IMAGE_NAME) ! -f /home/wims/log/wims.conf;
	@echo "OK: Configuration files checking passed!"

.PHONY: push-to-hub
push-to-hub: test
	docker push $(WIMS_IMAGE_NAME)

.PHONY: logs-follow
logs-follow:
	@if [ "$(WIMS_CONTAINER_TAG)" = "null" ]; \
	then \
	  docker logs -f $(WIMS_CONTAINER_NAME); \
	else \
	  journalctl CONTAINER_TAG=$(WIMS_CONTAINER_TAG) --follow; \
	fi;

.PHONY: logs-show
logs-show:
	@if [ "$(WIMS_CONTAINER_TAG)" = "null" ]; \
	then \
	  docker logs $(WIMS_CONTAINER_NAME) | tac; \
	else \
		journalctl CONTAINER_TAG=$(WIMS_CONTAINER_TAG) --reverse; \
	fi;
