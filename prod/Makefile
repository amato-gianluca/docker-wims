current-dir := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
docker-compose := docker compose -f $(current-dir)docker-compose.yml
make := /usr/bin/make -f $(current-dir)Makefile
source-env-file := $(current-dir)../.env-dist
target-env-file := $(current-dir).env

# Be sure that default configuration is loaded the first time.
include $(source-env-file)
# If already present, load customized local configuration.
-include $(target-env-file)

include $(current-dir)../general-rules.mk

# This target must be run before starting the WIMS service.
.PHONY: warmup
warmup:
	@if [ ! -d "$(current-dir)log-volume/classes" ]; \
	then \
	  echo "[WARM UP] Populating WIMS shared directories with WIMS initial content..."; \
	  # 1. Populate initial content. \
	  docker run \
		--rm \
		--mount type=bind,src=$(current-dir)log-volume,target=/home/wims/log-volume \
		--entrypoint rsync \
		$(WIMS_IMAGE_NAME) \
		-av /home/wims/log/ /home/wims/log-volume/; \
	  # 2. Override initial content, if any, with specific content. \
	  rsync -av $(current-dir)log-volume-overriding/ $(current-dir)log-volume/; \
	  # 3. Be sure the whole content is owned by the wims:wims user. \
	  docker run \
		--rm \
		--mount type=bind,src=$(current-dir)log-volume,target=/home/wims/log-volume \
		--entrypoint chown \
		$(WIMS_IMAGE_NAME) \
		-R wims:wims /home/wims/log-volume/; \
	  docker run \
		--rm \
		--mount type=bind,src=$(current-dir)devel-volume,target=/home/wims/devel-volume \
		--entrypoint chown \
		$(WIMS_IMAGE_NAME) \
		-R wims:wims /home/wims/devel-volume/; \
	  echo "[WARM UP] Done!"; \
	else \
	  echo "[WARM UP] WIMS shared directories were already populated. Nothing to do!"; \
	fi;

# To be used only on exceptional cases (last resource) to enable local administration.
# Remove that manager IP always after its use from log/wims.conf.
.PHONY: add-ip-for-local-management
add-ip-for-local-management:
	$(docker-compose) exec -e APP_ENV=test wims /wims/bin/entrypoint.d/5_add_manager_site_ip.sh
	@echo ""
	@echo "Showing current admin passwords..."
	$(make) --no-print-directory show-admin-password
