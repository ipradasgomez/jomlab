# Infraestructura de Entrada

Ref rápida. Docs: `documentation/infrastructure.md`

## Setup
```bash
cd scripts && ./20-setup-cloudflare-tunnel.sh
```

## Arquitectura
Internet → Cloudflare → Tunnel → Traefik → Servicios

## Componentes y Ubicaciones
- **cloudflared**: Túnel seguro → `services/cloudflared/config.yml`, `scripts/20-setup-cloudflare-tunnel.sh`
- **Traefik**: Reverse proxy → `services/traefik/docker-compose.yml`, `services/traefik/config/`
  - **Reglas de routing**: Todas las reglas de Traefik para aplicaciones van en `services/traefik/config/dynamic/<servicio>.yml` (NO en labels de docker-compose)

## Estructura Clave
```
services/
├── docker-compose.yml
├── traefik/
│   ├── docker-compose.yml
│   └── config/
│       ├── traefik.yml
│       └── dynamic/
└── cloudflared/
    └── docker-compose.yml
data/traefik/letsencrypt/
.env, env.example
```
