.PHONY: help init chown-volumes chown-volume-src \
        up down down-v rebuild rebuild-all \
        dev-up dev-down dev-down-v dev-clean dev-rebuild dev-rebuild-clean dev-rebuild-all dev-full-rebuild

.DEFAULT_GOAL := help

PROD = docker compose -f docker-compose.yml
DEV  = docker compose

SUDO := $(shell [ "$$(id -u)" -eq 0 ] || echo sudo)

# ── Help Text ─────────────────────────────────────────────────────────────────

help:
	@echo ""
	@echo "Usage: make <target>"
	@echo ""
	@echo "Setup"
	@echo "  init                 Create the docker_volumes directory structure"
	@echo "  chown-volumes        Fix ownership of docker_volumes (uses sudo if needed)"
	@echo "  chown-volume-src     Fix ownership of CKAN_HOME volume (uses sudo if needed)"
	@echo ""
	@echo "Production"
	@echo "  up                   Start all production containers (detached)"
	@echo "  down                 Stop and remove production containers"
	@echo "  down-v               Stop and remove production containers and volumes"
	@echo "  rebuild              Rebuild the CKAN final layer and restart the container"
	@echo "  rebuild-all          Rebuild all CKAN layers and restart the container"
	@echo ""
	@echo "Development (includes override with ckan_home volume)"
	@echo "  dev-up               Start all dev containers (detached)"
	@echo "  dev-down             Stop and remove dev containers"
	@echo "  dev-down-v           Stop and remove dev containers and volumes"
	@echo "  dev-clean            Stop dev containers, remove volumes and docker_volumes"
	@echo "  dev-rebuild          Rebuild the CKAN final layer and restart the container"
	@echo "  dev-rebuild-clean    Clean, re-init directories, rebuild final layer and start"
	@echo "  dev-rebuild-all      Rebuild all CKAN layers and restart the container"
	@echo "  dev-full-rebuild     Full clean slate: clean, re-init, rebuild all, and start"
	@echo ""

# ── Directories ───────────────────────────────────────────────────────────────

init:
	mkdir -p docker_volumes/ckan_config \
	         docker_volumes/ckan_home \
	         docker_volumes/ckan_storage \
	         docker_volumes/pg_data \
	         docker_volumes/solr_data \
	         docker_volumes/jupyterhub_data \
	         docker_volumes/kg_data

chown-volumes:
	$(SUDO) chown -Rf $(shell whoami):$(shell id -gn) docker_volumes || true

chown-volume-src:
	$(SUDO) chown -Rf $(shell whoami):$(shell id -gn) docker_volumes/ckan_home || true

# ── Production ────────────────────────────────────────────────────────────────

up: init
	$(PROD) up -d

down:
	$(PROD) down

down-v:
	$(PROD) down -v

rebuild:
	bash build.sh
	$(PROD) up -d --force-recreate ckan

rebuild-all:
	bash build.sh --all
	$(PROD) up -d --force-recreate ckan

# ── Development ───────────────────────────────────────────────────────────────

dev-up: init
	$(DEV) up -d

dev-down:
	$(DEV) down

dev-down-v:
	$(DEV) down -v

dev-clean: chown-volumes dev-down-v
	rm -rf docker_volumes

dev-rebuild: chown-volume-src
	rm -rf docker_volumes/ckan_home
	$(MAKE) init
	bash build.sh
	$(DEV) up -d --force-recreate ckan

dev-rebuild-clean: dev-clean
	bash build.sh
	$(MAKE) dev-up

dev-rebuild-all: chown-volume-src
	rm -rf docker_volumes/ckan_home
	$(MAKE) init
	bash build.sh --all
	$(DEV) up -d --force-recreate ckan

dev-full-rebuild: dev-clean init
	bash build.sh --all
	$(DEV) up -d

