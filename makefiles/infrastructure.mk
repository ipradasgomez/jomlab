# Makefile para gestión de la infraestructura de entrada
# Incluye comandos para start, stop, restart, status, logs de la infraestructura
# Uso: make <comando> desde la raíz del proyecto

.PHONY: help start stop restart status logs clean

# Variables
SERVICES_DIR := services
ENV_FILE := .env

# Colores para output
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m # No Color

help: ## Muestra esta ayuda
	@echo "$(GREEN)Comandos disponibles:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-15s$(NC) %s\n", $$1, $$2}'

start: ## Inicia la infraestructura completa (redes, storage, traefik, cloudflared, adguardhome)
	@echo "$(GREEN)Iniciando infraestructura completa...$(NC)"
	@if [ ! -f $(ENV_FILE) ]; then \
		echo "$(RED)Error: Archivo .env no encontrado. Copia env.example a .env y configura las variables.$(NC)"; \
		exit 1; \
	fi
	@echo "$(YELLOW)1. Creando redes comunes...$(NC)"
	@cd $(SERVICES_DIR) && docker-compose up -d network-dummy || docker compose up -d network-dummy
	@echo "$(YELLOW)2. Iniciando Storage (PostgreSQL, Redis, MinIO)...$(NC)"
	@cd $(SERVICES_DIR) && docker-compose -f storage-postgresql.yml up -d || docker compose -f storage-postgresql.yml up -d
	@cd $(SERVICES_DIR) && docker-compose -f storage-redis.yml up -d || docker compose -f storage-redis.yml up -d
	@cd $(SERVICES_DIR) && docker-compose -f storage-minio.yml up -d || docker compose -f storage-minio.yml up -d
	@echo "$(YELLOW)3. Iniciando Traefik (con socket-proxy)...$(NC)"
	@cd $(SERVICES_DIR) && docker-compose -f traefik.yml up -d || docker compose -f traefik.yml up -d
	@echo "$(YELLOW)4. Iniciando Cloudflare Tunnel...$(NC)"
	@cd $(SERVICES_DIR) && docker-compose -f cloudflared.yml up -d || docker compose -f cloudflared.yml up -d
	@echo "$(YELLOW)5. Iniciando AdGuard Home...$(NC)"
	@cd $(SERVICES_DIR) && docker-compose -f adguardhome.yml up -d || docker compose -f adguardhome.yml up -d
	@echo "$(GREEN)✓ Infraestructura completa iniciada$(NC)"
	@echo "$(GREEN)  - Redes: entry, storage, apps$(NC)"
	@echo "$(GREEN)  - Storage: PostgreSQL, Redis, MinIO$(NC)"
	@echo "$(GREEN)  - Traefik: traefik (con socket-proxy)$(NC)"
	@echo "$(GREEN)  - Cloudflare Tunnel: cloudflared$(NC)"
	@echo "$(GREEN)  - AdGuard Home: adguardhome$(NC)"

stop: ## Detiene todos los servicios de la infraestructura
	@echo "$(YELLOW)Deteniendo infraestructura completa...$(NC)"
	@cd $(SERVICES_DIR) && docker-compose -f adguardhome.yml down || docker compose -f adguardhome.yml down
	@cd $(SERVICES_DIR) && docker-compose -f cloudflared.yml down || docker compose -f cloudflared.yml down
	@cd $(SERVICES_DIR) && docker-compose -f traefik.yml down || docker compose -f traefik.yml down
	@cd $(SERVICES_DIR) && docker-compose -f storage-minio.yml down || docker compose -f storage-minio.yml down
	@cd $(SERVICES_DIR) && docker-compose -f storage-redis.yml down || docker compose -f storage-redis.yml down
	@cd $(SERVICES_DIR) && docker-compose -f storage-postgresql.yml down || docker compose -f storage-postgresql.yml down
	@echo "$(GREEN)✓ Servicios detenidos$(NC)"

restart: stop start ## Reinicia la infraestructura de entrada

status: ## Muestra el estado de los servicios
	@echo "$(GREEN)Estado de la infraestructura:$(NC)"
	@echo ""
	@echo "$(YELLOW)Redes:$(NC)"
	@docker network inspect entry >/dev/null 2>&1 && echo "$(GREEN)  ✓ Red 'entry' existe$(NC)" || echo "$(RED)  ✗ Red 'entry' no existe$(NC)"
	@docker network inspect storage >/dev/null 2>&1 && echo "$(GREEN)  ✓ Red 'storage' existe$(NC)" || echo "$(RED)  ✗ Red 'storage' no existe$(NC)"
	@docker network inspect apps >/dev/null 2>&1 && echo "$(GREEN)  ✓ Red 'apps' existe$(NC)" || echo "$(RED)  ✗ Red 'apps' no existe$(NC)"
	@echo ""
	@echo "$(YELLOW)Storage:$(NC)"
	@docker ps --filter "name=storage-postgresql" --format "  {{.Names}}: {{.Status}}" || echo "  storage-postgresql: no está corriendo"
	@docker ps --filter "name=storage-redis" --format "  {{.Names}}: {{.Status}}" || echo "  storage-redis: no está corriendo"
	@docker ps --filter "name=storage-minio" --format "  {{.Names}}: {{.Status}}" || echo "  storage-minio: no está corriendo"
	@echo ""
	@echo "$(YELLOW)Infraestructura de entrada:$(NC)"
	@docker ps --filter "name=socket-proxy" --format "  {{.Names}}: {{.Status}}" || echo "  socket-proxy: no está corriendo"
	@docker ps --filter "name=traefik" --format "  {{.Names}}: {{.Status}}" || echo "  traefik: no está corriendo"
	@docker ps --filter "name=cloudflared" --format "  {{.Names}}: {{.Status}}" || echo "  cloudflared: no está corriendo"
	@docker ps --filter "name=adguardhome" --format "  {{.Names}}: {{.Status}}" || echo "  adguardhome: no está corriendo"

logs: ## Muestra los logs de todos los servicios
	@echo "$(GREEN)Logs de la infraestructura de entrada:$(NC)"
	@echo "$(YELLOW)--- Traefik (incluye socket-proxy) ---$(NC)"
	@cd $(SERVICES_DIR) && docker-compose -f traefik.yml logs --tail=50 || docker compose -f traefik.yml logs --tail=50
	@echo ""
	@echo "$(YELLOW)--- Cloudflared ---$(NC)"
	@cd $(SERVICES_DIR) && docker-compose -f cloudflared.yml logs --tail=50 || docker compose -f cloudflared.yml logs --tail=50
	@echo ""
	@echo "$(YELLOW)--- AdGuard Home ---$(NC)"
	@cd $(SERVICES_DIR) && docker-compose -f adguardhome.yml logs --tail=50 || docker compose -f adguardhome.yml logs --tail=50

logs-follow: ## Sigue los logs de todos los servicios en tiempo real
	@echo "$(GREEN)Siguiendo logs (Ctrl+C para salir)...$(NC)"
	@cd $(SERVICES_DIR) && docker-compose -f traefik.yml logs -f || docker compose -f traefik.yml logs -f &
	@cd $(SERVICES_DIR) && docker-compose -f cloudflared.yml logs -f || docker compose -f cloudflared.yml logs -f &
	@cd $(SERVICES_DIR) && docker-compose -f adguardhome.yml logs -f || docker compose -f adguardhome.yml logs -f &
	@wait

clean: ## Limpia contenedores detenidos y recursos no utilizados
	@echo "$(YELLOW)Limpiando recursos Docker...$(NC)"
	@docker system prune -f
	@echo "$(GREEN)✓ Limpieza completada$(NC)"

