# Organización de Directorios del Homelab

Estructura de directorios del proyecto homelab. Debe respetarse para mantener consistencia.

## Estructura

```
jomlab/
├── data/              # Volúmenes de datos persistentes
├── makefiles/         # Makefiles para comandos comunes
├── rules/             # Reglas y referencias para Cursor AI (Markdown)
├── scripts/           # Scripts .sh para gestión
└── services/          # Servicios del homelab (un directorio por servicio)
```

## Directorios

### `data/`
- Volúmenes persistentes por servicio: `data/<nombre-servicio>/`
- Ejemplo: `data/traefik/letsencrypt/`
- No versionar (excepto `.gitkeep`), datos sensibles en `.gitignore`

### `makefiles/`
- Makefiles con comandos comunes (`make up`, `make down`, etc.)
- Makefile principal en raíz o por área

### `rules/`
- Referencias rápidas de arquitectura/organización para Cursor AI
- Markdown conciso (documentación completa en `documentation/`)

### `scripts/`
- Scripts `.sh` ejecutables con shebang `#!/bin/bash`
- Numerados: `10-install-docker.sh`, `20-setup-cloudflare-tunnel.sh`, `30-generate-traefik-auth.sh`
- Comentarios descriptivos

### `services/`
**Estructura**:
```
services/
├── docker-compose.yml          # Red común 'entry' y configs compartidas
├── traefik/
│   ├── docker-compose.yml      # Usa red externa 'entry'
│   ├── config/
│   │   ├── traefik.yml
│   │   └── dynamic/*.yml
│   └── README.md               # Opcional
└── <servicio>/
    ├── docker-compose.yml
    └── <archivos>/
```

**Reglas**:
- Un directorio por servicio con su `docker-compose.yml`
- `env_file: - ../../.env` obligatorio en todos los servicios
- Redes externas: `external: true` usando red del compose común
- Rutas relativas al directorio del servicio
- Volúmenes: `../../data/<servicio>/` (relativo desde `services/<servicio>/`)
- Configuración local dentro del directorio del servicio

## Convenciones

- **Directorios**: minúsculas, guiones si necesario (`traefik`, `postgres-db`)
- **Archivos**: minúsculas, extensiones apropiadas (`traefik.yml`)
- **Scripts**: prefijo numérico (10, 20, 30...) + nombre descriptivo

## Variables y Redes

- `.env` en raíz, `env.example` como plantilla
- Red `entry` para infraestructura de entrada (Traefik, Cloudflared)
- Se crea automáticamente con compose común o manualmente: `docker network create entry`
- Apps pueden usar red `entry` (para Traefik) o redes propias aisladas

## Uso

```bash
cd services/traefik && docker-compose up -d
# O desde raíz: make traefik-up
```

## Reglas Clave

1. Config Docker en `services/`, nunca fuera de este directorio
2. Datos persistentes en `data/`, nunca en `services/`
3. Rutas relativas en docker-compose.yml
4. Un servicio = un directorio completo
